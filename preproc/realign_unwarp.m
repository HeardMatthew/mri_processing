%% realign_unwarp
close all; 
cd ..

% Prepare SPM and paths
warning off;
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_figure('GetWin','Graphics'); % Thanks Guillaume

load(fullfile(dir_preproc, 'SPM_realign.mat'))

dir_realign = fullfile(dir_subj, 'realign');
dir_reg = fullfile(dir_subj, 'reg');
dir_motionps = fullfile(dir_subj, 'ps', 'preproc');

allBoldFiles = [];
regNames = cell(1, numRuns);
imgNames = cell(1, numRuns);
multibandRun = 1; % Fixes strange bug that sometimes causes multi runs to 
                  % break due to renaming. After loading multiband_run1, 
                  % increases to 2 so that the next file is renamed to 
                  % multiband_run2. 

for rr = 1:numRuns
    thisrun = thissubjruns{rr};
    if strcmp(thisrun(1), 'h')
        numTRs = 180;
    elseif strcmp(thisrun(1), 'i')
        numTRs = 90;
    elseif strcmp(thisrun(1), 'm')
        thisrun = ['multiband_run' num2str(multibandRun)];
        numTRs = 248;
        multibandRun = multibandRun + 1;
    elseif strcmp(thisrun(1), 'r')
        numTRs = 211;
    end 
    
    disp(['Found ' thisrun ' and starting to load files into matlabbatch'])
    
    %% Load names and put into mattlabbatch
    [boldFiles, ~] = spm_select('List', dir_func, ['^' thisrun '_00*.*\.nii$']);
    boldFiles = [repmat([dir_func filesep],numTRs,1), boldFiles];
    boldFiles = cellstr(boldFiles);
    matlabbatch{1}.spm.spatial.realignunwarp.data.scans = boldFiles;
    
    dir_vdm = fullfile(dir_realign, thisrun);
    [vdmFiles, ~] = spm_select('List', dir_vdm, '^vdm5_*.*\.nii$');
    vdmFiles = cellstr([dir_vdm filesep vdmFiles]);
    matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan = vdmFiles;
    
    regNames{rr} = fullfile(dir_func, ['rp_' thisrun '_00001.txt']);
    
    if strcmp(matlabbatch{1}.spm.spatial.realignunwarp.data.scans, '<UNDEFINED>')
        matlabbatch{1}.spm.spatial.realignunwarp.data = [];
    end
    
    cd(dir_thissubj_batch)
    filename = ['realign_unwarp_', thisrun, '.mat'];
    save(filename, 'matlabbatch')
    
    cd(dir_func)
    disp('Starting realign_unwarp...')
    spm_jobman('run',matlabbatch);
    
end

%% Move regressors and motion graph to their proper directory
for ii = 1:length(regNames)
    copyfile(regNames{ii}, dir_reg);
end

psfile = date;
psfile = [psfile(8:end) psfile(4:6) psfile(1:2)];
psfile = fullfile(dir_func, ['spm_', psfile '.ps']);
movefile(psfile, fullfile(dir_ps, 'preproc'));
