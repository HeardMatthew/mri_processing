%% rename_files
% Run this if there was a terminated run that left unseemly, strange names.
% Add new subjects by hand. 

name = struct('subj', [], 'delete', [], 'old', [], 'new', []);

name(1).subj = 'AB_09Oct17';
name(1).delete = 'hybrid_run1_s010_*.nii';
name(1).old = 'hybrid_run1_s018_*.nii';
name(1).new = 'hybrid_run1_';

name(2).subj = 'KN_27Oct17';
name(2).delete = 'isss_run1_s011_*.nii';
name(2).old = 'isss_run1_s012_*.nii';
name(2).new = 'isss_run1_';

%% Actual code
for ii = 1:length(name)
    if strcmp(thissubj, name(ii).subj)
        tg = ii;
    end
end

cd(fullfile(dir_subj, 'FUNCTIONAL'))

deletefiles = dir(name(tg).delete);
badfiles = dir(name(tg).old);

for ii = 1:length(deletefiles)
    delete(deletefiles(ii).name)
end

for ii = 1:length(badfiles)
    runnum = badfiles(ii).name(end-8:end);
    dest = [name(tg).new, runnum];
    source = badfiles(ii).name;
    movefile(source, dest)
end