%% lang_spec_est_GLM
% Specifies and estimates first level GLM for isss_multi

% CHANGELOG (DD/MM/YY)
% 13/11/17  Changelog initialized -- MH
% 13/11/17  Updated to match new file conventions, added exception for
%   physio-less subjects, removed ART from code, added code to save 
%   functions -- MH

close all; clc; 
cd ..

%% Parameters (CHECK THESE BEFORE RUNNING)
numCons = 4; % NOI, SIL, ORA, SRA
numLangRuns = 6; 
numRegs = 2; % motion, physio

% Prepare SPM and paths
warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_figure('GetWin','Graphics'); % Thanks Guillaume

numTRs = zeros(1, numLangRuns);
for ii = 1:numLangRuns
    if strcmp(thissubjruns{ii}(1), 'h')
        numTRs(ii) = 180;
    elseif strcmp(thissubjruns{ii}(1), 'i')
        numTRs(ii) = 90;
    elseif strcmp(thissubjruns{ii}(1), 'm')
        numTRs(ii) = 248;
    end
end

designRootDir = fullfile(subjDir, 'design');
load(fullfile(subjDir, 'onsets_lang.mat'))
load(fullfile(subjDir, 'durations_lang.mat'))

%% Hybrid runs    
hybridRuns = find(numTRs == 180);
TRs = 180;
disp(['Making GLM-specifying .mat files for all hybrid runs for subject ' thissubj]);
load(fullfile(mlbDir, 'FIR_hybrid_template.mat'));

for rr = 1:length(hybridRuns)
    % Extract names for all bold files and put into job struct
    % File names
    [boldFiles, ~] = spm_select('List', funcDir, ['^wuhybrid_run' num2str(rr) '_00*.*\.nii$']);
    boldFiles = [repmat([funcDir filesep], TRs, 1), boldFiles]; %#ok<AGROW>
    boldFiles = cellstr(boldFiles);
    matlabbatch{1}.spm.stats(1).fmri_spec.sess(rr).scans = boldFiles;

    % Condition names, durations, and onsets
    for cc=1:numCons
        matlabbatch{1}.spm.stats.fmri_spec.sess(rr).cond(cc).onset = onsets.h_scans{cc, rr};
    end

    clear multiRegs
    multiRegs(1) = string([regDir '\rp_hybrid_run' num2str(rr) '_00001.txt']);
%     multiRegs(2) = string([regDir '\art_regression_outliers_uhybrid_run' num2str(rr) '_00001.mat']);
    if ~strcmp(thissubj, 'ZG_03Nov17')
        multiRegs(2) = string([regDir '\physio_1st_hybrid_run' num2str(rr) '_00001.txt']);
    end
    multiRegs = cellstr(multiRegs');
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(rr).multi_reg = multiRegs;

end
designDir = fullfile(designRootDir, 'hybrid_unsmoothed');
mkdir(designDir);
matlabbatch{1}.spm.stats.fmri_spec.dir = {designDir} ;

% Run the GLM-specify job
cd(fullfile(subjDir, 'batch'))
save('specify_GLM_FIR_hybrid.mat', 'matlabbatch')
cd(designDir)
spm_jobman('run',matlabbatch);
fg = spm_figure('FindWin','Graphics');
saveas(fg, 'design_hybrid.ps')
movefile(fullfile(designDir, 'design_hybrid.ps'), fullfile(psDir, 'designs'));

% Now estimate the model
load(fullfile(mlbDir, 'GLM_estimate.mat'));
matlabbatch{1}.spm.stats(1).fmri_est.spmmat = {[designDir '\SPM.mat']};
cd(fullfile(subjDir, 'batch'))
save('estimate_GLM_FIR_hybrid.mat', 'matlabbatch')
cd(designDir)
spm_jobman('run',matlabbatch);

%% ISSS runs    
isssRuns = find(numTRs == 90);
disp(['Making GLM-specifying .mat files for all isss runs for subject ' thissubj]);
load(fullfile(mlbDir, 'FIR_isss_template.mat'));

for rr = 1:length(isssRuns)
    % Extract names for all bold files and put into job struct
    % File names
    [boldFiles, ~] = spm_select('List', funcDir, ['^wuisss_run' num2str(rr) '_00*.*\.nii$']);
    boldFiles = [repmat([funcDir filesep],90,1), boldFiles]; %#ok<AGROW>
    boldFiles = cellstr(boldFiles);
    matlabbatch{1}.spm.stats(1).fmri_spec.sess(rr).scans = boldFiles;

    % Condition names, durations, and onsets
    for cc=1:numCons
        matlabbatch{1}.spm.stats.fmri_spec.sess(rr).cond(cc).onset = onsets.i_scans{cc, rr};
    end

    clear multiRegs
    multiRegs(1) = string([regDir '\rp_isss_run' num2str(rr) '_00001.txt']);
%     multiRegs(2) = string([regDir '\art_regression_outliers_uisss_run' num2str(rr) '_00001.mat']);
    if ~strcmp(thissubj, 'ZG_03Nov17')
        multiRegs(2) = string([regDir '\physio_1st_isss_run' num2str(rr) '_00001.txt']);
    end
    multiRegs = cellstr(multiRegs');
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(rr).multi_reg= multiRegs;

end
designDir = fullfile(designRootDir, 'isss_unsmoothed');
mkdir(designDir)
matlabbatch{1}.spm.stats.fmri_spec.dir = {designDir};

% Run the GLM-specify job
cd(fullfile(subjDir, 'batch'))
save('specify_GLM_FIR_isss.mat', 'matlabbatch')
cd(designDir)
spm_jobman('run',matlabbatch);
fg = spm_figure('FindWin','Graphics');
saveas(fg, 'design_isss.ps')
movefile(fullfile(designDir, 'design_isss.ps'), fullfile(psDir, 'designs'));

% Now estimate the model
load(fullfile(mlbDir, 'GLM_estimate.mat'));
matlabbatch{1}.spm.stats(1).fmri_est.spmmat = {[designDir '\SPM.mat']};
cd(fullfile(subjDir, 'batch'))
save('estimate_GLM_FIR_isss.mat', 'matlabbatch')
cd(designDir)
spm_jobman('run',matlabbatch);


%% Multiband runs    %%% NOT RUNNING MVPA ON THESE FILES
% multiRuns = find(numTRs == 248);
% disp(['Making GLM-specifying .mat files for all multiband runs for subject ' thissubj]);
% load(fullfile(mlbDir, 'GLM_multi_template.mat'))
% 
% for rr = 1:length(multiRuns)
%     % Extract names for all bold files and put into job struct
%     % File names
%     [boldFiles, ~] = spm_select('List', GLMfuncDir, ['^swumultiband_run' num2str(rr) '_00*.*\.nii$']);
%     boldFiles = [repmat([funcDir filesep],248,1), boldFiles]; %#ok<AGROW>
%     boldFiles = cellstr(boldFiles);
%     matlabbatch{1}.spm.stats(1).fmri_spec.sess(rr).scans = boldFiles;
% 
%     % Condition names, durations, and onsets
%     for cc=1:numCons
%         matlabbatch{1}.spm.stats.fmri_spec.sess(rr).cond(cc).onset = onsets.m_seconds{cc, rr};
%         matlabbatch{1}.spm.stats.fmri_spec.sess(rr).cond(cc).duration = durations.m_seconds{cc, rr};
%     end
% 
%     clear multiRegs
%     multiRegs(1) = string([regDir '\rp_multiband_run' num2str(rr) '_00001.txt']);
% %     multiRegs(2) = string([regDir '\art_regression_outliers_umultiband_run' num2str(rr) '_00001.mat']);
%     if ~strcmp(thissubj, 'ZG_03Nov17')
%         multiRegs(2) = string([regDir '\physio_1st_multiband_run' num2str(rr) '_00001.txt']);
%     end
%     multiRegs = cellstr(multiRegs');
%     
%     matlabbatch{1}.spm.stats.fmri_spec.sess(rr).multi_reg= multiRegs;
% 
% end
% designDir = fullfile(designRootDir, 'multi');
% matlabbatch{1}.spm.stats.fmri_spec.dir = {designDir};
% 
% % Run the GLM-specify job
% cd(fullfile(subjDir, 'batch'))
% save('specify_GLM_HRF_multi.mat', 'matlabbatch')
% cd(designDir)
% spm_jobman('run',matlabbatch);
% fg = spm_figure('FindWin','Graphics');
% saveas(fg, 'design_multi.ps')
% movefile(fullfile(designDir, 'design_multi.ps'), fullfile(psDir, 'designs'));
% 
% % Now estimate the model
% load(fullfile(mlbDir, 'GLM_estimate.mat'));
% matlabbatch{1}.spm.stats(1).fmri_est.spmmat = {[designDir '\SPM.mat']};
% cd(fullfile(subjDir, 'batch'))
% save('estimate_GLM_FIR_multi.mat', 'matlabbatch')
% cd(designDir)
% spm_jobman('run',matlabbatch);
