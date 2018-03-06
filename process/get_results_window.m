%% get_results_window
warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');

thresh = 'none';
p = 0.01;
k = 20;

for ww = 3:10
    load(fullfile(dir_process, 'SPM_get_results_window.mat'))
    
    thiswindowmat = fullfile(dir_second, 'hybrid_window', 'lng_noi', ['window' num2str(ww)], 'SPM.mat');
    matlabbatch{1}.spm.stats.results.spmmat = cellstr(thiswindowmat);
    
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = thresh;
    matlabbatch{1}.spm.stats.results.conspec.thresh = p;
    matlabbatch{1}.spm.stats.results.conspec.extent = k;
    
    filename = fullfile(dir_second, 'hybrid_window', 'lng_noi', ['window' num2str(ww)], ['get_results_window' num2str(ww) '.mat']);
    save(filename, 'matlabbatch')
    
    spm_jobman('run', matlabbatch)
    
end