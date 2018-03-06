%% build_contrasts_window
% Builds contrasts for 1st level analysis for one subject
% This is the fork for window analysis

% CHANGELOG (DD/MM/YY)
% 15/11/17  Initialized file
% 28/08/18  Forked for window analysis

%% Parameters
warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');

load('SPM_build_contrasts_window.mat')
runtype = 'hybrid';
col = 10; % number of columns in design matrix

idx = [1:10; 11:20; 21:30];

%% Actual code
for con = 1:3
    for ww = 1:10
        
        extra = 10 - ww; % extra zeros to add after the ones columns
        pattern = [ones(1, ww), zeros(1, extra)];

        dir_design = fullfile(dir_subj, 'design');
        matlabbatch{1}.spm.stats.con.spmmat = ...
            cellstr(fullfile(dir_design, runtype, 'SPM.mat'));
        
        if con == 1 % NOI > SIL
            pattern_full = [pattern, -1*pattern];
        elseif con == 2 % LNG > NOI
            pattern_full = [-2*pattern, zeros(1, col), pattern, pattern];
        elseif con == 3 % ORA > SRA
            pattern_full = [zeros(1, 2*col), pattern, -1*pattern];
        end

        matlabbatch{1}.spm.stats.con.consess{idx(con, ww)}.tcon.weights = ...
            pattern_full;

    end
end

% Save files
filename = fullfile(dir_thissubj_batch, ['build_contrasts_window' runtype '.mat']);
save(filename, 'matlabbatch');

% Run job
spm_jobman('run', matlabbatch);
