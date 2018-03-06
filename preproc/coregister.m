%% coregister
close all; 
load SPM_coregister.mat
spm('defaults', 'FMRI');
spm_jobman('initcfg'); %initialize batch system 

cd(dir_thissubj_batch)
matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(fullfile(dir_anat, 'MPRAGE.nii'));
save('coregister_temp.mat', 'matlabbatch')

for rr = 1:numRuns
    thisrun = thissubjruns{rr};
    if strcmp(thisrun(1), 'm')
        thisrun(1:5) = [];
        thisrun = ['multiband' thisrun];
    end
    disp(['Coregistering ' thisrun])
    load coregister_temp.mat
    
    runtype = thissubjruns{rr}(1);
    cd(dir_func)
    reference = dir(['meanu' thisrun '*.nii']);
        
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(fullfile(reference.folder, reference.name));

    batchname = ['coregister_' thisrun '.mat'];
    cd(dir_thissubj_batch)
    save(batchname, 'matlabbatch')
    
    spm_jobman('run',matlabbatch);
    
end
    
    