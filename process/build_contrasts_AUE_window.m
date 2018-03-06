%% build_contrasts
% Builds contrasts for 1st level analysis for one subject hybrid run
% This is only for window analysis, right now...

% CHANGELOG (DD/MM/YY)
% 15/11/17  Initialized file
% 28/02/18  Forked into window analysis file
% 28/02/18  Forked into AUE window analysis file

%% Parameters
warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');

%% Actual code
cd(fullfile(dir_second, 'hybrid_window'))

% For now, only working with lng_noi
files_con = dir;
files_con = files_con(3:end);

for cc = 1 %:3
    cd(files_con(cc).name)
    files_window = dir;
    files_window = files_window(3:end);
    
    for ww = 1:length(files_window)
        cd(files_window(ww).name)

        load(fullfile(dir_process, 'SPM_build_contrasts_AUE.mat'))

        matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(pwd, 'SPM.mat'));

        % Determine contast
        conName = ['hybrid_' files_con(cc).name '_' files_window(ww).name];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = conName;

        % Save files
        filename = fullfile(pwd, ['build_contrasts_' files_con(cc).name '_' files_window(ww).name '.mat']);
        save(filename, 'matlabbatch');

        % Run job
        spm_jobman('run', matlabbatch);
        
        cd ..

    end
end