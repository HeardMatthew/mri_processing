%% process_allsubj
% Builds models for each subject

% CHANGELOG (DD/MM/YY)
% 13/11/17  Initialized file -- MH
% 28/02/17  Running an analysis to see which acquisition window is best

%% Initialize
clc; clear all
dir_batch = pwd;
dir_setup = fullfile(pwd, 'setup');
dir_process = fullfile(dir_batch, 'process');
dir_mlb = fullfile(dir_batch, 'matlabbatch');

isss_multi_params

dir_second = fullfile(dir_data, 'secondlevel');

for subjnum = 1:7
    thissubj = subjects{subjnum};
    disp(['Starting to process subj ' thissubj '.'])
    thissubjruns = masterRuns{subjnum};
    numRuns = length(thissubjruns);
    subjruns_fullName = allRuns;
    subjruns_fullName(~runsMask(subjnum, :)) = [];
    
    dir_subj = fullfile(dir_data, thissubj);
    dir_func = fullfile(dir_subj, 'FUNCTIONAL');
    dir_func_GLM = fullfile(dir_subj, 'FUNC_GLM');
    dir_func_MVPA = fullfile(dir_subj, 'FUNC_MVPA');
    dir_design = fullfile(dir_subj, 'design');
    dir_anat = fullfile(dir_subj, 'ANATOMICAL');
    dir_reg = fullfile(dir_subj, 'reg');
    dir_ps = fullfile(dir_subj, 'ps');
    dir_thissubj_batch = fullfile(dir_subj, 'batch');
        
    %% Specify and estimate GLMs for language
%     cd(dir_process)
%     disp(['Specifying 1st level GLM for subject ' thissubj '.'])
%     lang_spec_est_GLM
%     disp('Done!')
    
    %% Specify and estimate GLMs for language (unsmoothed)
%     cd(dir_process)
%     disp(['Specifying 1st level GLM for subject ' thissubj '.'])
%     lang_spec_est_GLM_unsmoothed
%     disp('Done!')

    %% Calculate AUE
%     cd(dir_process)
%     SPA_calculate
%     disp('Done!')
    
    %% Build contrasts
%     cd(dir_process)
%     disp(['Building contrasts for subject ' thissubj '.'])
%     build_contrasts
%     disp('Done!')

%     cd(dir_process)
%     SPA_manipulate
%     disp('Done!')  

    %% Calculate AUE for windows
    cd(dir_process)
    SPA_calculate_window
    disp('Done!')

    %% Window analysis
%     cd(dir_process)
%     disp(['Building window contrasts for subject ' thissubj '.'])
%     build_contrasts_window
%     disp('Done!')
    
    cd(dir_process)
    SPA_manipulate_window
    disp('Done!')  
    
end

%% Second-level analysis
    
% Build contrasts for hybrid window analysis
cd(dir_process)
disp('Building contrasts for hybrid window analysis.')
build_contrasts_AUE_window
disp('Done!')

% Get report for hybrid window analysis
cd(dir_process)
disp('Getting results from hybrid window analysis.')
get_results_window
disp('Done!')

% Make montages for hybrid window analysis











