%% second_level_AUE_window

warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');

dir_process = pwd;
cd ..
isss_multi_params

dir_second = fullfile(dir_data, 'secondlevel');
contrasts = {'noi_sil', 'lng_noi', 'ora_sra'};

cond{1} = 'NOI_SIL';
cond{2} = 'LNG_NOI';
cond{3} = 'ORA_SRA';
       
for cc = 1:length(cond) % each contrast
    mkdir(fullfile(dir_second, 'hybrid_window', contrasts{cc}));
    cd(fullfile(dir_second, 'hybrid_window', contrasts{cc}))
    
    for ww = 3:10 % for each window within the contrast

        mkdir(fullfile(dir_second, 'hybrid_window', contrasts{cc}, ['window' num2str(ww)]));
        
        cd(dir_process)
        
        load('SPM_second_level_1sampleT_window.mat')

        matlabbatch{1, 1}.spm.stats.factorial_design.dir = ... 
            cellstr(fullfile(dir_second, 'hybrid_window', contrasts{cc}, ['window' num2str(ww)]));

        AUEfiles = cell(7, 1); % one per subject

        for ii = 1:7 % each subject
            thissubj = subjects{ii};
            disp(['Loading subj ' thissubj ' into batch.'])

            dir_design = fullfile(dir_data, thissubj, 'design');

            AUEfiles{ii} = fullfile(dir_design, 'hybrid', ['AUE_' cond{cc} '_window' num2str(ww) '.nii']);

        end

        matlabbatch{1, 1}.spm.stats.factorial_design.des.t1.scans = AUEfiles;
        disp(['All subjects are in the batch for ' contrasts{cc} ' window ' num2str(ww) '.'])
        filename = fullfile(dir_second, 'hybrid_window', contrasts{cc}, ['window' num2str(ww)], ['second_level_' contrasts{cc} '_window' num2str(ww) '.mat']);
        save(filename, 'matlabbatch')
        disp('SPM file saved')

        disp('Starting jobman')
        spm_jobman('run', matlabbatch)

        load('GLM_estimate.mat')
        matlabbatch{1, 1}.spm.stats.fmri_est.spmmat = cellstr(fullfile(dir_second, 'hybrid_window', contrasts{cc}, ['window' num2str(ww)], 'SPM.mat'));
        spm_jobman('run', matlabbatch)
    end

end
    


