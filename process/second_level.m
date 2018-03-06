%% second_level

warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');

numSubjs = 7;

load('SPM_second_level_1sampleT.mat')
dir_second = fullfile(dataDir, 'secondlevel');
contrasts = {'noi_sil', 'lng_noi', 'ora_sra'};
tFiles = cell(7, 1);

for con = 1:3
    
    matlabbatch{1, 1}.spm.stats.factorial_design.dir = cellstr(fullfile(dir_second, 'multi', contrasts{con}));

    for ii = 1:numSubjs
        thissubj = subjects{ii};
        disp(['Loading subj ' thissubj ' into batch.'])

        subjDir = fullfile(dataDir, thissubj);
        designDir = fullfile(subjDir, 'design');

        tFiles{ii} = fullfile(designDir, 'multi', ['spmT_000' num2str(con) '.nii']);

    end
    
    matlabbatch{1, 1}.spm.stats.factorial_design.des.t1.scans = tFiles;
    disp(['All subjects are in the batch for ' contrasts{con} '.'])
    filename = fullfile(dir_second, 'multi', contrasts{con}, ['second_level_' contrasts{con}]);
    save(filename, 'matlabbatch')
    disp('SPM file saved')
    
    disp('Starting jobman')
    spm_jobman('run', matlabbatch)
    
    load('GLM_estimate.mat')
    matlabbatch{1, 1}.spm.stats.fmri_est.spmmat = cellstr(fullfile(dir_second, 'multi', contrasts{con}, 'SPM.mat'));
    spm_jobman('run', matlabbatch)
    
end
