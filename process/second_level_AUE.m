%% second_level_AUE

warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');

processDir = pwd;
cd ..
isss_multi_params

secondDir = fullfile(dataDir, 'secondlevel');
contrasts = {'noi_sil', 'lng_noi', 'ora_sra'};

scan{1} = 'isss';
scan{2} = 'hybrid';

cond{1} = 'NOI_SIL';
cond{2} = 'LNG_NOI';
cond{3} = 'ORA_SRA';

for ss = 1:length(scan) % each scan type
       
    for cc = 1:length(cond) % each contrast

        cd(processDir)
        load('SPM_second_level_1sampleT.mat')
                
        matlabbatch{1, 1}.spm.stats.factorial_design.dir = cellstr(fullfile(secondDir, scan{ss}, contrasts{cc}));

        AUEfiles = cell(7, 1);
        
        for ii = 1:7 % each subject
            thissubj = subjects{ii};
            disp(['Loading subj ' thissubj ' into batch.'])

            subjDir = fullfile(dataDir, thissubj);
            designDir = fullfile(subjDir, 'design');

            AUEfiles{ii} = fullfile(designDir, scan{ss}, ['AUE_' cond{cc} '.nii']);

        end

        matlabbatch{1, 1}.spm.stats.factorial_design.des.t1.scans = AUEfiles;
        disp(['All subjects are in the batch for ' contrasts{cc} '.'])
        filename = fullfile(secondDir, scan{ss}, contrasts{cc}, ['second_level_' contrasts{cc}]);
        save(filename, 'matlabbatch')
        disp('SPM file saved')

        disp('Starting jobman')
        spm_jobman('run', matlabbatch)

        load('GLM_estimate.mat')
        matlabbatch{1, 1}.spm.stats.fmri_est.spmmat = cellstr(fullfile(secondDir, scan{ss}, contrasts{cc}, 'SPM.mat'));
        spm_jobman('run', matlabbatch)

    end
    
end

