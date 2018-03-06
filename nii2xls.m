%% nii2xls
% Converts data from nii to xls format using SPM. Useful for preparing data
% for machine learning algorithms. Author -- Matthew Heard

% CHANGELOG (DD/MM/YY)
% 30/11/17  -- Initialized file. MH
% 01/12/17  -- Dr. Lee mentioned to load betas instead. Adjusting the file.
%   Major question, how to deal with both runs? Also, exclude all betas
%   from motion regs!

close all; clear all; clc

%% Parameters
isss_multi_params 
subjNum = 2; % using KN's data to start, as she had high accuracy.
numBetas = [102, 62]; 
% 4 conditions, 5 or 10 betas, 2 runs
% therefore, need 80, 40 betas for hybrid, isss

%% Pathing
thissubj = subjects{subjNum};
dir_batch = pwd;
cd ..

cd data
dir_data = pwd;

cd(thissubj)
dir_subj = pwd;

cd design
dir_des = pwd;

%% Load data
designDirs = dir;
designDirs = designDirs(3:end); % avoids '.' and '..'

for thisRun = 1:2 % hybrid and isss only
    cd(designDirs(thisRun).name)
    betaFiles = dir('beta_*.nii');
    mask = fullfile(pwd, 'mask.nii');
    hdr = spm_vol(mask);
    [~, xyz] = spm_read_vols(hdr);
    numVoxels = size(xyz, 2);
    
    if thisRun == 1 % if hybrid
        allBeta_hybrid = cell(80, 1);
        regressors = [41:50, 91:102];
    elseif thisRun == 2 % if isss
        allBeta_isss = cell(40, 1);
        regressors = [21:30, 51:62];
    end
    
    % Quick test to make sure everything loaded
    if length(betaFiles) ~= numBetas(thisRun)
        error('Check your files, betas did not load correctly!')
    end
    
    beta_idx = 1;
    
    for jj = 1:length(betaFiles) % for each beta...
        if ~find(jj == regressors)
            thisBeta = fullfile(betaFiles(thisRun).folder, betaFiles(thisRun).name);
            hdr = spm_vol(thisBeta);
            [betaMat, ~] = spm_read_vols(hdr, mask);

            betaVec = reshape(betaMat, 1, numVoxels);

            betaVec = betaVec(~isnan(betaVec));

            if thisRun == 1 % if hybrid
                allBeta_hybrid{beta_idx} = betaVec;
            elseif thisRun == 2 % if isss
                allBeta_isss{beta_idx} = betaVec;
            end
            
            beta_idx = beta_idx + 1;
            
        end
        
    end
        
    cd ..
    
end



%% Old code
% s_h = dir('swuhybrid_*.nii'); % dir for all hybrid scans
% s_i = dir('swuisss_*.nii'); % dir for all isss scans
% s_m = dir('swumultiband_*.nii'); % dir for all multiband scans
% 
% allScans = vertcat(s_h, s_i, s_m);
% bold_mat_h = cell(180, 1);
% bold_mat_i = cell(90, 1);
% bold_mat_m = cell(248, 1);
% 
% ind_h = 1;
% ind_i = 1;
% ind_m = 1;
% 
% for ii = 1:length(allScans) % for all runs...
%     % determine scan type
%     if ii <= length(s_h)
%         scanType = 'hybrid';
%     elseif ii <= length(s_h) + length(s_i)
%         scanType = 'isss';
%     elseif ii <= length(s_h) + length(s_i) + length(s_m)
%         scanType = 'multiband';
%     else
%         error('Tried to index a strange file number!')
%     end
%     
%     flag = scanType(1);
%     
%     % load data
%     mask = fullfile(dir_subj, 'design', scanType, 'mask.nii');
%     thisBeta = fullfile(allScans(ii).folder, allScans(ii).name);
%         
%     hdr = spm_vol(thisBeta);
%     [bold_mat, ~] = spm_read_vols(hdr, mask);
%         
%     bold_vec_withNaN = reshape(bold_mat, 1, numel(bold_mat));
%     
%     % transform from matrix to vector
%     bold_vec = bold_vec_withNaN(~isnan(bold_vec_withNaN));
%     
%     % transform from single vector to big matrix
%     if strcmp(flag, 'h')
%         bold_mat_h{ind_h} = bold_vec;
%         ind_h = ind_h + 1;
%     elseif strcmp(flag, 'i')
%         bold_mat_i{ind_i} = bold_vec;
%         ind_i = ind_i + 1;
%     elseif strcmp(flag, 'm')
%         bold_mat_m{ind_m} = bold_vec;
%         ind_m = ind_m + 1;
%     end
%     
% end
% 
% %% Add class tag
% 
% %% Convert to xls-friendly format
% 
% 
% 
% 
% 
% 
% %% Save data