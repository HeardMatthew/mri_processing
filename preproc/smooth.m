%% realign_unwarp_smooth
close all; 
cd ..

% Select files using SPM
warning off;

spm('defaults', 'FMRI');
spm_jobman('initcfg');
multibandRun = 0; % Fixes strange bug that sometimes causes multi runs to 
                  % break due to renaming. After loading multiband_run1, 
                  % increases to 2 so that the next file is renamed to 
                  % multiband_run2. 

%% GLM
load(fullfile(dir_preproc, 'SPM_smooth_GLM.mat'))
allBoldFiles = [];
for rr = 1:numRuns
        thisrun = thissubjruns{rr};
    if strcmp(thisrun(1), 'h')
        numTRs = 180;
    elseif strcmp(thisrun(1), 'i')
        numTRs = 90;
    elseif strcmp(thisrun(1), 'm')
        multibandRun = multibandRun + 1;
        thisrun = ['multiband_run' num2str(multibandRun)];
        numTRs = 248;
    elseif strcmp(thisrun(1), 'r')
        numTRs = 211;
    end 
    [boldFiles, ~] = spm_select('List', dir_func, ['^wu' thisrun '_00*.*\.nii$']);
    boldFiles = [repmat([dir_func filesep],numTRs,1), boldFiles];
    boldFiles = cellstr(boldFiles);
    allBoldFiles = vertcat(allBoldFiles, boldFiles);
    
end
matlabbatch{1}.spm.spatial.smooth.data = allBoldFiles;

cd(dir_thissubj_batch)
save('smooth_GLM.mat', 'matlabbatch')
cd(dir_func)

spm_jobman('run',matlabbatch);
disp('Done with GLM smoothing!')

%% Move files
disp('Moving files to correct FUNC directory')
dir_newFunc = fullfile(dir_subj, 'FUNC_GLM');

cd(dir_func)
for ii = 1:numRuns
    thisrun = thissubjruns{ii};
    if strcmp(thisrun(1), 'm')
        thisrun(1:5) = [];
        thisrun = ['multiband' thisrun];
    end
    
    source = ['swu' thisrun '_00*.nii'];
    
    copyfile(source, dir_newFunc)
    
end

%% MVPA
load(fullfile(dir_preproc, 'SPM_smooth_MVPA.mat'))
matlabbatch{1}.spm.spatial.smooth.data = allBoldFiles;

cd(dir_thissubj_batch)
save('smooth_MVPA.mat', 'matlabbatch')
cd(dir_func)

spm_jobman('run',matlabbatch);
disp('Done with MVPA smoothing!')

%% Move files
disp('Moving files to correct FUNC directory')
dir_newFunc = fullfile(dir_subj, 'FUNC_MVPA');

cd(dir_func)
for ii = 1:numRuns
    thisrun = thissubjruns{ii};
    if strcmp(thisrun(1), 'm')
        thisrun(1:5) = [];
        thisrun = ['multiband' thisrun];
    end
    
    source = ['swu' thisrun '_00*.nii'];
    
    copyfile(source, dir_newFunc)
    
end