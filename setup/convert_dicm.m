%% convert_dicm
% Converts all dicm (including physio) to nii, and put them in their proper
% places

function convert_dicm(subj)
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

%% Convert dicms to nii for scan
dir_nii = fullfile(dir_subj, 'nii');
dir_dicm = fullfile(dir_subj, 'dicm');
dir_physio = fullfile(dir_subj, 'PHYSIO');

disp(['Converting scan dicms for ' subj '...'])
dicm2nii(dir_dicm, dir_nii, '.nii 3D')
disp('Done!')

%% Move niis to proper locations
cd(dir_nii)
mprage = dir('MPRAGE.nii');
fmap = dir('fieldmap*.nii');
hybrid = dir('hybrid_*.nii');
isss = dir('isss_*.nii');
multi = dir('multiband_*.nii');
rhythm = dir('rhythm_*.nii');

if length(fmap) ~= 3
    warning('Check number of fieldmap files')
elseif length(hybrid) ~= 362
    warning('Check number of hybrid files')
elseif length(isss) ~= 180
    warning('Check number of isss files')
elseif length(multi) ~= 498
    warning('Check number of multi files')
elseif length(rhythm) ~= 424
    warning('Check number of rhythm files')
end

allScans = [hybrid; isss; multi; rhythm];

dir_anat = fullfile(dir_subj, 'ANATOMICAL');
dir_func = fullfile(dir_subj, 'FUNCTIONAL');
dir_real = fullfile(dir_subj, 'realign');

disp(['Moving scans into proper folders for ' subj])
copyfile(mprage.name, dir_anat);
for ii = 1:length(allScans)
    copyfile(allScans(ii).name, dir_func);
end
for ii = 1:length(fmap)
    copyfile(fmap(ii).name, dir_real);
end
disp('Done!')

%% Convert physio dicms to nii
if ~strcmp(subj(1:2), 'ZG') % NO PHYSIO FOR ZG
    cd(dir_physio)
    dcms = dir('*.dcm');
    if isempty(dcms)
        error('There are no .dcm to extract in PHYSIO. Have you unzipped?')
    end
    disp(['Converting physio dicms for ' subj '...'])
    for ii = 1:length(dcms)
        dcm = fullfile(dcms(ii).folder, dcms(ii).name);
        dicm2nii(dcm, dir_physio, '.nii 3D')

        temp = fullfile(pwd, 'PulseRespiratoryRegressors.nii');
        if ii < 10
            final = fullfile(pwd, ['physio_reg_0', num2str(ii), '.nii']);
        else
            final = fullfile(pwd, ['physio_reg_', num2str(ii), '.nii']);
        end
        movefile(temp, final)

        temp = fullfile(pwd, 'dcmHeaders.mat');
        if ii < 10
            final = fullfile(pwd, ['header_0' num2str(ii) '.mat']);
        else
            final = fullfile(pwd, ['header_' num2str(ii) '.mat']);
        end
        movefile(temp, final)

    end
end

disp('Done!')

cd(dir_batch)

end