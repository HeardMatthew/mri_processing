%%% beta plot
%%% written by ysl 06/27/2014
%%% updated by mjh 11/22/2017
close all; clc;

%% Paths and parameters
[MNI_XYZ,Region] = xlsread([pwd '\roi_list.xls']);

processDir = pwd;
cd ..
isss_multi_params
% This is a helper function I run to quickly generate information regarding
% my experiment (e.g. subject list, order of scanning protocols). In
% particular, this script uses data about which subject is being processed.
% Anytime you see code referring to a cell called "subjects", you can
% probably take it out. 

numROI = size(MNI_XYZ,1);
numCond = 4; %NOI, SIL, ORA, SRA

for ROI=1:numROI % For each ROI...
    %% Loading the brain data
    
    this_vox = MNI_XYZ(ROI,:);
    this_region = Region{ROI};  
    
    % How many TRs? 
    % This code was put in place to determine the imaging protocol I used.
    % Geoff, you can probably take out these statements and set the number
    % of TRs to a consistent number.
    if strcmp(this_region(1), 'h')
        numTRs = 10;
    elseif strcmp(this_region(1), 'i')
        numTRs = 5;
    elseif strcmp(this_region(1), 'm')
        break
    end
        
    betas_total = zeros(numTRs, numCond, length(subjects));
    
    for ss = 1:length(subjects) % For each subject...
        
        thissubj = subjects{ss};        
        disp(['Making contrast images for subject ' thissubj ]);
        subjDir = fullfile(dataDir, thissubj);
        
        % Location of brain data
        if strcmp(Region{ROI}(1), 'h') 
            designDir = fullfile(subjDir, 'design', 'hybrid');
        elseif strcmp(Region{ROI}(1), 'i')
            designDir = fullfile(subjDir, 'design', 'isss');
        end 
                
        cd(designDir);
        
        for rr = 1:2 % For each run of the hybrid and ISSS conditions ...
            % This code is a solution I figured out for processing multiple
            % runs of MRI data. The design of each GLM I pulled data from
            % had a variety of regressors and this was put in place to fix
            % problems I had for each run. The variable runIdx specifies
            % the first regressor of a run (THE FIRST RUN IS REPRESENTED BY
            % ZERO).
            if rr == 1
                runIdx = 0;    
            elseif rr == 2
                if strcmp(thissubj, 'ZG_03Nov17') 
                    % ZG has no physio, so he has fewer regressors. 
                    runIdx = numCond * numTRs + 6;
                else
                    runIdx = numCond * numTRs + 10;
                end
            end
            
            
            for cond = 1:numCond % For each condition... (NOI, SIL, ORA, SRA)
                imgIdx = (cond-1)*numTRs + runIdx;
                % I use imgIdx to begin the following loop through each TR
                % of the scan. Its value depends on which condition I am
                % looking at (NOI, SIL, ORA, SRA) and which run (run1,
                % run2) is being analyzed. 

                for TR=1:numTRs % For each TR... 
                    thisTR = imgIdx + TR;
                    if thisTR < 10
                        thisTR = ['000' num2str(thisTR)];
                    elseif thisTR < 100
                        thisTR = ['00'  num2str(thisTR)];
                    end

                    Vol=spm_vol(['beta_' thisTR '.nii']);

                    XYZ = mni2vox_matrix(this_vox,Vol);

                    Img=spm_read_vols(Vol);

                    betas_total(TR, cond, ss)=Img(XYZ(1), XYZ(2),XYZ(3));
                end
            end
        end
    end
    
    %% Calculating mean and std dev
    
    avg = mean(betas_total, 3);
    
    std_dev = zeros(numTRs, numCond);
    
    for cond = 1:numCond
        for TR = 1:numTRs
            std_dev(TR,cond) = std(betas_total(TR, cond, :));
        end
    end
    
    std_error = std_dev/sqrt(length(subjects));
        
    %% Plotting results
    
    figure;
    hold on;
    
    h1=plot(avg(:,1),'b'); %NOI
    errorbar(avg(:,1),std_error(:,1), 'b');
    
    h2= plot(avg(:,2),'b','LineStyle','--'); %SIL
    errorbar(avg(:,2),std_error(:,2), 'b','LineStyle','--');
    
    h3=plot(avg(:,3),'r'); %ORA
    errorbar(avg(:,3),std_error(:,3), 'r');

    h4=plot(avg(:,4),'r','LineStyle','--'); %SRA
    errorbar(avg(:,4),std_error(:,4), 'r','LineStyle','--');
    
% hold off; 
% axis off;
    
   %%for getting EPS without any labeling/ axis comments out below  
    set(gca,'XTick',1:1:6)
    
    set(gca,'XTickLabel',{'2','4', '6', '8', '10'})
    
    title(this_region,'FontWeight', 'bold', 'Fontsize', 14)
    
   
    hleg1=legend([h3,h4,h1,h2],'ORA','SRA','NOI','SIL','Location','NorthEast');

    xlabel ('Post Stimulus (sec.)', 'Fontsize', 14);
    ylabel ('Beta Estimates', 'Fontsize', 14);
    
      cd (processDir);
      
     %save in png format 
     saveas(gcf,['beta_plot_' Region{ROI}], 'png');
     
     %save in eps format 
%      saveas(gcf, ['beta_plot_' Region{ROI}], 'eps')
     
%         clf;
%     
    
    clear std_dev; 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    
end




