%% analyze_subj
% Performs all preparation, preprocessing, and data analysis for one
% subject.
%
% CHANGELOG DD/MM/YY
% 28/09/17  File started. Made sure input convention for subjects was
%   identical. -- MH
% 29/09/17  First time testing! -- MH
% 07/11/17  Introduced normalization. -- MH

% clear all; close all; clc;

%% Load parameters
batchDir = pwd;
resp = inputdlg({'Subject initials:', 'Setup?', 'Unpack?', 'Pre-process?'});
subjinit = resp{1};
setup = str2double(resp{2});
unpack = str2double(resp{3});
preprocess = str2double(resp{4});

isss_multi_params
for ii = 1:length(subjects)
    if strcmp(subjinit, subjects{ii}(1:2))
        subjnum = ii;
    end
end

thissubj = subjects{subjnum};
thissubjruns = masterRuns{subjnum};
subjDir = fullfile(dataDir, thissubj);
numRuns = length(thissubjruns);
subjruns_fullName = allRuns;
subjruns_fullName(~runsMask(subjnum, :)) = [];

%% Set up data
if setup
    clc;
    disp('SETUP')
    setupDir = fullfile(batchDir, 'setup');
    disp(['Setting up ' thissubj '...'])

    % Make directories
    cd(setupDir)
    disp('Making directories...')
    make_dir(thissubj)
    disp('Done! Now, go download the functional, physio, and behavioral data.')
    input('Did you download the entire patient file and put it into \\zip? ');
    input('What about the entire physio regressor, did you put it into \\PHYSIO? ');
    input('And the behavioral data has been moved into \\behav\\scan? ');
    disp('Great!')
    
    disp(['Completed initial setup for ' thissubj '.'])
end

%% Unpack
if unpack
    clc;
    disp('UNPACK')
    setupDir = fullfile(pwd, 'setup');
    disp(['Unpacking ' thissubj '...'])
    
    % Unzip files
    disp('Unzipping all files now...')
    cd(setupDir)
    unzip_data(thissubj)
    disp('Done!')

    % Convert dicms
    disp('Converting all dicms...')
    cd(setupDir)
    convert_dicm(thissubj)
    disp('Done!')
        
    % Make physio regressors
    disp('Making physio regressors...')
    cd(setupDir)
    make_phys_reg(thissubj)
    disp('Done!')

    % Extract timing
    disp('Extracting timing from behav for lang...')
    cd(setupDir)
    extract_timing_lang(thissubj);

    disp('And now for rhythm...')
    cd(setupDir)
    extract_timing_rhythm(thissubj);

    disp(['Finished unpacking ' thissubj '.'])
end   

%% Preprocessing
if preprocess
    clc;
    disp('PREPROCESSING')
    funcDir = fullfile(subjDir, 'FUNCTIONAL');
    anatDir = fullfile(subjDir, 'ANATOMICAL');
    regDir = fullfile(subjDir, 'reg');
    psDir = fullfile(subjDir, 'ps');
    thissubj_batchDir = fullfile(subjDir, 'batch');
    
    preprocDir = fullfile(batchDir, 'preproc');
    
    % Make fieldmap
    disp('Creating fieldmaps...')
    cd(setupDir)
    make_fieldmap
    disp('Done!')
    
    % Unwarp and realignment
    disp('Starting to unwarp and realign data')
    cd(preprocDir)
    realign_unwarp
    disp('Done unwarping and realigning data!')
    
    % Coregistration
    disp('Coregistration begins')
    cd(preprocDir)
    coregister
    disp('Done coregistering!')

    % Normalization
    disp('Normalizing to MNI-space')
    cd(preprocDir)
    normalize
    disp('Done normalizing')

    % Smoothing
    disp('Smoothing data now')
    cd(preprocDir)
    smooth
    disp('Done smoothing!')

    % SNR
    disp('Running SNR scripts')
    cd(batchDir)
    cd ..
    cd ..
    cd('Noise_script')
    snr_sd('isss_multiband', {thissubj}, subjruns_fullName)
    disp('Done with SNR!')
    cd(batchDir)
    
    disp(['Completed preprocessing EPIs for ' thissubj '.'])
end

%% Group-level analysis (normalization, smoothing)

% %% First level analyses
% clc;
% disp('Specifying and estimating first level...')
% processDir = fullfile(batchDir, 'process');
% mlbDir = fullfile(batchDir, 'matlabbatch');
% cd(processDir)
% lang_spec_est_GLM
% disp('Done with lang!')
% cd(processDir)
% rhythm_spec_est_GLM
% disp('Done with rhythm!')
% 
% disp('End of the pipeline. Great work!')