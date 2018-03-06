%% normalize
load SPM_normalize.mat

spm('defaults', 'FMRI');
spm_jobman('initcfg');
warning off 

matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {fullfile(dir_anat,'MPRAGE.nii')};

cd(dir_func)

kk = 0; clear files

for ii = 1:numRuns
    thisrun = thissubjruns{ii};
    if strcmp(thisrun(1), 'm')
        thisrun(1:5) = [];
        thisrun = ['multiband' thisrun];
    end
    niis = dir(['u' thisrun '_00*.nii']);
    for jj = 1:length(niis)
        kk = kk + 1;
        files{kk} = fullfile(niis(jj).folder, niis(jj).name);
    end
end

files = files';
cellstr(files);

matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = files;

cd(dir_thissubj_batch)
save('normalize.mat', 'matlabbatch')
cd(dir_func)

spm_jobman('run',matlabbatch);

