%% make_dir
% Creates directories for a subject

function make_dir(subj)
if ~ischar(subj)
    err('Input (subj) where subj is a string')
end

%% Pathing
cd ..
isss_multi_params
cd(dir_data)

try
    dir_newSubj = fullfile(pwd, subj);
    cd(dir_newSubj)
    disp(['Directories already exist for ' subj])
    cd ..
catch
    disp(['Creating directory for ' subj])
    mkdir(dir_data, subj)

    cd(subj)

    mkdir('ANATOMICAL')
    mkdir('art')
    mkdir('batch')

    mkdir('behav')
    cd('behav')
    mkdir('analysis')
    mkdir('presc')
    mkdir('scan')
    cd ..

    mkdir('design')
    cd('design')
    mkdir('hybrid')
    mkdir('multi')
    mkdir('isss')
    mkdir('rhythm')
    cd ..

    mkdir('dicm')
    mkdir('FUNC_GLM')
    mkdir('FUNC_MVPA')
    mkdir('FUNCTIONAL')
    mkdir('nii')

    mkdir('PHYSIO')

    mkdir('ps')
    cd('ps')
    mkdir('contrast')
    mkdir('designs')
    mkdir('preproc')
    cd ..

    mkdir('realign')
    mkdir('reg')
    mkdir('SNR')
    mkdir('zip')

end

cd(dir_batch)

end