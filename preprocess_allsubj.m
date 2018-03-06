%% preprocess_allsubj
% Pre-processes all subjects at once. 

% CHANGELOG (DD/MM/YY)
% 08/11/17  File initialized

%% Initialize
clc; clear all
dir_batch = pwd;
dir_setup = fullfile(pwd, 'setup');

isss_multi_params

for ii = 8 %1:6
    %% Subject-specific parameters
    thissubj = subjects{ii};
    % thissubj = [thissubj, '_manual'];
    disp(['Starting to preprocess subj ' thissubj '.'])
    thissubjruns = masterRuns{ii};
    dir_subj = fullfile(dir_data, thissubj);
    numRuns = length(thissubjruns);
    subjruns_fullName = allRuns;
    subjruns_fullName(~runsMask(ii, :)) = [];

    dir_func = fullfile(dir_subj, 'FUNCTIONAL');
    dir_anat = fullfile(dir_subj, 'ANATOMICAL');
    dir_reg = fullfile(dir_subj, 'reg');
    dir_ps = fullfile(dir_subj, 'ps');
    dir_thissubj_batch = fullfile(dir_subj, 'batch');

    dir_preproc = fullfile(dir_batch, 'preproc');

    %% Make fieldmap
    disp('Creating fieldmaps...')
    cd(dir_setup)
    make_fieldmap
    disp('Done!')

    %% Unwarp and realignment
    disp('Starting to unwarp and realign data')
    cd(dir_preproc)
    realign_unwarp
    disp('Done unwarping and realigning data!')

    %% Coregistration
    disp('Coregistration begins')
    cd(dir_preproc)
    coregister
    disp('Done coregistering!')

    %% Normalization
    disp('Normalizing to MNI-space')
    cd(dir_preproc)
    normalize
    disp('Done normalizing!')

    %% Smoothing
    disp('Smoothing data now')
    cd(dir_preproc)
    smooth
    disp('Done smoothing!')

    %% SNR
    disp('Running SNR scripts')
    cd(dir_batch)
    cd ..
    cd ..
    cd('Noise_script')
    snr_sd('isss_multiband', {thissubj}, subjruns_fullName)
    disp('Done with SNR!')
    cd(dir_batch)    

end
