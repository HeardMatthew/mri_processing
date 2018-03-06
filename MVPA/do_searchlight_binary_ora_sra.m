%% do_searchlight_binary
% Does a binary classification using searchlight-based SVM (I think).
% Adapted from Yune's code on 14/12/2017

close all; clear all; clc; 

%% Paths and parameters
dir_MVPA_batch = pwd;
cd ..
isss_multi_params

dir_MVPA_data = fullfile(dir_data, 'mvpa');
numSubjs = length(subjects);

%%%%%%%%%%%%%%%% 
% whichRun = 1; % SELECT 1 FOR HYBRID, 2 FOR ISSS
% timepoints  = 1:10; % CHOOSE WHICH TIME POINTS TO FEED INTO MACHINE
%%%%%%%%%%%%%%%%

sphere_radius = 2;  %%% Radius = 3 originally, but the code says 2 in batch_coord_sphere
num_folds = 2; % Two-fold cross-validation. Use odds to train, evens to test; evens to train, odds to test

%% FOR all subjects and runs...
for ss = 1:numSubjs-1 % ignore the last subject for now
    thissubj = subjects{ss};
    dir_thissubj = fullfile(dir_MVPA_data, thissubj);
    disp(['Processing subject ' num2str(ss) ': ' thissubj ]);
    
    dir_design = fullfile(dir_data, thissubj, 'design');
    
    for rr = 1%:2 % for hybrid and isss...
        if rr == 1 % if hybrid
            thisrun = 'hybrid';
            numTRs = 10;
            timepoints  = 3:8;
        elseif rr == 2 % if isss
            thisrun = 'isss';
            numTRs = 5;
            timepoints  = 1:5;
        end
        
        %% Load mask
        disp('Loading mask...')
        dir_thisrun = fullfile(dir_design, [thisrun '_unsmoothed']);
        cd(dir_thisrun)
        
        Vmask = spm_vol('mask.nii');
        mask_matrix = spm_read_vols(Vmask);
        mask_inds = find(mask_matrix);     %%% The indices of where mask=1
        num_mask_voxels = length(mask_inds);

        x_size = Vmask.dim(1);
        y_size = Vmask.dim(2);
        z_size = Vmask.dim(3);

%         svm_p_correct_values = zeros(x_size,y_size,z_size); % Not used during GNB creation

        %% Load SPM.mat
        disp('Loading SPM file...');
        load SPM.mat
        num_time_points = size( SPM.xY.VY, 1 );
        
        %% Load TC and spheres
        disp('Loading TC and spheres data...');
        
        filename = fullfile(dir_thissubj, [thissubj(1:2) '_' thisrun '_zero_meaned_tc.mat']);
        load(filename)

        filename = fullfile(dir_thissubj, [thissubj(1:2) '_' thisrun '_spheres_radius' num2str(sphere_radius) '.mat']);  
        load(filename);  %%% This is the premade sphere voxel-coords
        disp('Finished loading');
        clear filename

        %% Read design matrix
        %%%% Read the column-names from the design matrix, to figure out which
        %%%% regressors to use for defining our time-points
        all_column_cond_names = char(SPM.xX.name);
        num_cols = size(SPM.xX.X,2);

        cross_validation_mats_ora_HIT = zeros(x_size, y_size, z_size, num_folds);
        cross_validation_mats_sra_HIT = zeros(x_size, y_size, z_size, num_folds);

        cross_validation_mats_ora_FA = zeros(x_size, y_size, z_size, num_folds);
        cross_validation_mats_sra_FA = zeros(x_size, y_size, z_size, num_folds);

        cross_validation_mats_acc = zeros(x_size, y_size, z_size, num_folds);

        for fold = 1:num_folds % for each fold... we'll have two.
            %% Build train and test sets
            %%%% For 2-fold cross-validation, we will use each run as a testing set
            cd(dir_MVPA_batch)
            creating_2fold_sets_ora_sra; % creates unique sets based on fold
            
            disp(['Cross-validation fold ' num2str(fold) ]);

            ora_trn_reg = nonzeros(ora_trn_set);
            sra_trn_reg = nonzeros(sra_trn_set);

            ora_tst_reg = nonzeros(ora_tst_set);
            sra_tst_reg = nonzeros(sra_tst_set);

            %%% Say that the cond is present when the regressor is greater
            %%% than its mean value (this worked for continuous imaging)
            % Now things are different. We have the selection of timepoints
            % already present! We need to instead select which ones from
            % the list...
            
            ora_trn_times_idx = find(ora_trn_set); % > mean(ora_trn_reg) );
            sra_trn_times_idx = find(sra_trn_set); % > mean(sra_trn_reg) );

            ora_tst_times_idx = find(ora_tst_set); % > mean(ora_tst_reg) );
            sra_tst_times_idx = find(sra_tst_set); % > mean(sra_tst_reg) );
            
            ora_trn_times = [];
            sra_trn_times = [];
            
            ora_tst_times = [];
            sra_tst_times = [];
            
            for ii = 0:numTRs:3*numTRs % There are four events...
                %% Select which time points to feed into machine
                ora_trn_times = vertcat(ora_trn_times, ora_trn_times_idx(timepoints + ii));
                sra_trn_times = vertcat(sra_trn_times, sra_trn_times_idx(timepoints + ii));
                
                ora_tst_times = vertcat(ora_tst_times, ora_tst_times_idx(timepoints + ii));
                sra_tst_times = vertcat(sra_tst_times, sra_tst_times_idx(timepoints + ii));
            end
                        
            %% PICK UP HERE

            for voxel_num = 1:size(sphere_XYZ_indices_cell)

                sphere_inds_for_this_voxel = sphere_XYZ_indices_cell{voxel_num};

                [center_x, center_y, center_z] = ...
                    ind2sub(size(mask_matrix),mask_inds(voxel_num));

                %%% Extract the time-courses of the voxels in the sphere
                timecourse_matrix = ...
                    zero_meaned_tc_total(:,sphere_inds_for_this_voxel);
                
                %%% Now extract just the time-points when the cond is present
                timecourse_ora_trn = timecourse_matrix(ora_trn_times,:);
                timecourse_sra_trn = timecourse_matrix(sra_trn_times,:);

                timecourse_ora_tst = timecourse_matrix(ora_tst_times,:);
                timecourse_sra_tst = timecourse_matrix(sra_tst_times,:);
                                
                %% Load data into machine

                %%% Each data-point is one time-slice, i.e. one row of this
                Instances_trn = [ timecourse_ora_trn; ...
                    timecourse_sra_trn]; 
                Instances_tst = [ timecourse_ora_tst; ...
                    timecourse_sra_tst];

                Labels_trn = [ 1*ones(size(timecourse_ora_trn,1),1); ...
                    -1*ones(size(timecourse_sra_trn,1),1)];
                Labels_tst = [ 1*ones(size(timecourse_ora_tst,1),1); ...
                    -1*ones(size(timecourse_sra_tst,1),1)];
                
                %%% PICK UP HERE

                %             %%%%%%%%LibSVM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %             model = svmtrain(Instances_trn,Instances_training);
                %             [predict_label, accuracy, dec_values] = svmpredict(Labels_testing, Instances_testing, model);
                %             testing_Prop_correct=accuracy(1,1);
                %             cross_validation_mats(center_x,center_y,center_z,fold) = (testing_Prop_correct -12.5)/100;
                %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%%%%%GNB%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                nb = fitcnb(Instances_trn, Labels_trn);
%                 nb = NaiveBayes.fit(Instances_trn,Labels_trn);
                Outputs_testing = predict(nb,Instances_tst);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Accuracy
                Predicting_ora = Outputs_testing(Labels_tst==1); % All data that should be OR
                Predicting_sra = Outputs_testing(Labels_tst==-1); % All data that should be SR

                % Accuracies of prediction
                Hit_ora = sum(Predicting_ora==Labels_tst(Labels_tst==1))/length(Predicting_ora);
                Hit_sra = sum(Predicting_sra==Labels_tst(Labels_tst==-1))/length(Predicting_sra);

                % False alarm rate
                Predicting_non_ora=Outputs_testing(~(Labels_tst==1)); % All data that should NOT be OR
                Predicting_non_sra=Outputs_testing(~(Labels_tst==-1)); % All data that should NOT be SR

                % False alarm
                FA_ora = sum(Predicting_non_ora==1*ones(length(Predicting_non_ora),1))/ length(Predicting_non_ora);
                FA_sra = sum(Predicting_non_sra==-1*ones(length(Predicting_non_sra),1))/ length(Predicting_non_sra);

                num_testing_points = size(Instances_tst,1);
                testing_Prop_correct = sum(Outputs_testing==Labels_tst)/num_testing_points;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% store then in the matrix

                if Hit_ora ~=0
                    cross_validation_mats_ora_HIT(center_x, center_y, center_z,fold)=Hit_ora;
                elseif Hit_ora ==0
                    cross_validation_mats_ora_HIT(center_x, center_y, center_z,fold)=1/length(Predicting_ora);
                elseif Hit_ora ==1
                    cross_validation_mats_ora_HIT(center_x, center_y, center_z,fold)=(length(Predicting_ora)-1)/length(Predicting_ora);
                end

                if Hit_sra ~=0
                    cross_validation_mats_sra_HIT(center_x, center_y, center_z,fold)=Hit_sra;
                elseif Hit_sra ==0
                    cross_validation_mats_sra_HIT(center_x, center_y, center_z,fold)=1/length(Predicting_sra);
                elseif Hit_sra ==1
                    cross_validation_mats_sra_HIT(center_x, center_y, center_z,fold)=(length(Predicting_sra)-1)/length(Predicting_sra);
                end

                %%% beginning of FA

                if FA_ora ~=0
                    cross_validation_mats_ora_FA(center_x, center_y, center_z,fold)=FA_ora;
                elseif FA_ora ==0
                    cross_validation_mats_ora_FA(center_x, center_y, center_z,fold)=1/length(Predicting_non_ora);
                elseif FA_ora ==1
                    cross_validation_mats_ora_FA(center_x, center_y, center_z,fold)=(length(Predicting_non_ora)-1)/length(Predicting_non_ora);
                end


                if FA_sra ~=0
                    cross_validation_mats_sra_FA(center_x, center_y, center_z,fold)=FA_sra;
                elseif FA_sra ==0
                    cross_validation_mats_sra_FA(center_x, center_y, center_z,fold)=1/length(Predicting_non_sra);
                elseif FA_sra ==1
                    cross_validation_mats_sra_FA(center_x, center_y, center_z,fold)=(length(Predicting_non_sra)-1)/length(Predicting_non_sra);
                end

                cross_validation_mats_acc(center_x, center_y, center_z,fold)=testing_Prop_correct-0.5;

                if rem(voxel_num,2000)==0
                    disp([  'Test-set accuracy  ' num2str(voxel_num) ...
                        ' out of ' num2str(num_mask_voxels) ...
                        'for subject num' num2str(ss) ...
                        ' = ' num2str(testing_Prop_correct)  ]);

                end

            end  %%% End of loop through voxel spheres

        end  %%% End of loop through folds

        %%% Save the average across folds
        cd(dir_thisrun)
        
        Vbeta = spm_vol('beta_0001.nii');
                
        cd(dir_thissubj)
        
        dir_tp = fullfile(dir_thissubj, [thisrun, '_', num2str(timepoints(1)), '_' num2str(timepoints(end))]);
        mkdir(dir_tp)
        cd(dir_tp)
        
        V_GNB = Vbeta;
        V_GNB.fname = [ thissubj(1:2) '_' thisrun '_search_GNB_binary_ora_against_sra_HIT_rad' num2str(sphere_radius) '.nii'];  %%% Give this a new name
        spm_write_vol(V_GNB,mean(cross_validation_mats_ora_HIT,4));

        V_GNB = Vbeta;
        V_GNB.fname = [ thissubj(1:2) '_' thisrun '_search_GNB_binary_sra_against_ora_HIT_rad' num2str(sphere_radius) '.nii'];  %%% Give this a new name
        spm_write_vol(V_GNB,mean(cross_validation_mats_sra_HIT,4));

        V_GNB = Vbeta;
        V_GNB.fname = [ thissubj(1:2) '_' thisrun '_search_GNB_binary_ora_for_sra_FA_rad' num2str(sphere_radius) '.nii'];  %%% Give this a new name
        spm_write_vol(V_GNB,mean(cross_validation_mats_ora_FA,4));

        V_GNB = Vbeta;
        V_GNB.fname = [ thissubj(1:2) '_' thisrun '_search_GNB_binary_sra_for_ora_FA_rad' num2str(sphere_radius) '.nii'];  %%% Give this a new name
        spm_write_vol(V_GNB,mean(cross_validation_mats_sra_FA,4));

        V_GNB = Vbeta;
        V_GNB.fname = [ thissubj(1:2) '_' thisrun '_search_GNB_ora_sra_rad' num2str(sphere_radius) '.nii'];  %%% Give this a new name
        spm_write_vol(V_GNB,mean(cross_validation_mats_acc,4));

        clear Labels_testing; clear Labels_training; clear Instances_testing ; clear Instances_training;
        clear SPM; clear zero_meaned_TC_total; clear Vmask; clear XYZ;
        
        cd(dir_MVPA_batch)
    
    end % end loop through runs

    
end %%% End of loop through subjects
