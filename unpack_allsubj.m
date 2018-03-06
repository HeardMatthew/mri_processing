%% unpack_allsubj
% Unpacks data for all subjects. 

% CHANGELOG (DD/MM/YY)
% 08/11/17  File initialized

%% Initialize
clc; clear all
dir_batch = pwd;
dir_setup = fullfile(pwd, 'setup');

isss_multi_params

for ii = 9 %:6
    %% Subject-specific parameters
    thissubj = subjects{ii};
    thissubjruns = masterRuns{ii};
    dir_subj = fullfile(dir_data, thissubj);
    numRuns = length(thissubjruns);
    subjruns_fullName = allRuns;
    subjruns_fullName(~runsMask(ii, :)) = [];
        
    %% Unpacking begins
    disp(['Unpacking ' thissubj '...'])
    
    % Make directories
    disp('Making directories')
    cd(dir_setup)
    make_dir(thissubj)
    disp('Done!')
    
    % Unzip files
    disp('Unzipping all files now...')
    cd(dir_setup)
    unzip_data(thissubj)
    disp('Done!')

    % Convert dicms
    disp('Converting all dicms...')
    cd(dir_setup)
    convert_dicm(thissubj)
    disp('Done!')
    
    % Rename files
    if any(strcmp(thissubj(1:2), {'AB', 'KN'}))
        disp('Renaming necessary runs...')
        cd(dir_setup)
        rename_files
        disp('Done!')
    end
            
    % Make physio regressors
    if ~any(strcmp(thissubj(1:2), {'ZG', 'CC'}))  % NO PHYSIO DATA FOR SUBJECT ZG
        disp('Making physio regressors...')
        cd(dir_setup)
        make_phys_reg(thissubj)
        disp('Done!')
    end

    % Extract timing
    disp('Extracting timing from behav for lang...')
    cd(dir_setup)
    extract_timing_lang(thissubj);

    if ~any(strcmp(thissubj(1:2), {'CC'}))
        disp('And now for rhythm...')
        cd(dir_setup)
        extract_timing_rhythm(thissubj);
    end

    disp(['Finished unpacking ' thissubj '.'])
end