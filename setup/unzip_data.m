%% unzip_data
% Unzips all scans and physio regressors

function unzip_data(subj)
if ~ischar(subj)
    error('Input (subj) where subj is a string')
end

cd .. 
isss_multi_params

cd(dir_data)
try
    cd(subj)
    dir_subj = pwd;
catch err
    disp(['Could not change to subj dir ', subj, '. Does the folder exist?'])
    rethrow(err)
end

cd('zip')
file = dir('*.zip');
if length(file) ~= 1
    error(['Check how many .zip are in ' subj '\zip. There should only be one'])
end

dir_dicm = fullfile(dir_subj, 'dicm');
disp(['Unzipping ' subj ' dicm zip now...'])
unzip(file.name, dir_dicm);
disp('Done!')

if ~strcmp(subj(1:2), 'ZG') % NO PHYSIO FOR SUBJECT ZG
    dir_physio = fullfile(dir_subj, 'PHYSIO');
    cd(dir_physio)
    file = dir('*.zip');
    if length(file) ~= 1
        error(['Check how many .zip are in ' subj '\PHYSIO. There should only be one'])
    end
    disp(['Unzipping ' subj ' physio zip now...'])
    unzip(file.name, dir_physio);
    disp('Done!')
end
    
cd(dir_batch)

end