%% build_contrasts
% Builds contrasts for 1st level analysis for one subject

% CHANGELOG (DD/MM/YY)
% 15/11/17  Initialized file
% 28/02/18  Forked into window analysis file

%% Parameters
warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');

%% Actual code
for rr = 1:3
    load('SPM_build_contrasts.mat')
    if rr == 1 % hybrid
        runtype = 'hybrid';
        col = 10; % number of columns in design matrix
    elseif rr == 2 % isss
        runtype = 'isss';
        col = 5; % number of columns in design matrix
    elseif rr == 3 % multi
        runtype = 'multi';
        col = 1; % number of columns in design matrix
    end
        
    designDir = fullfile(subjDir, 'design');
    matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(designDir, runtype, 'SPM.mat'));
    
    % NOI > SIL
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = ... 
        [ones(1, col), -1*ones(1, col)];
    
    % LNG > NOI
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = ...
        [-2*ones(1, col), zeros(1, col), ones(1, 2*col)];
    
    % ORA > SRA
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = ...
        [zeros(1, 2*col) ones(1, col), -1*ones(1, col)];
    
    % Save files
    filename = fullfile(thissubj_batchDir, ['build_contrasts_' runtype '.mat']);
    save(filename, 'matlabbatch');
    
    % Run job
    spm_jobman('run', matlabbatch);
    
end