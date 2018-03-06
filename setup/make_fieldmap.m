%% create_fieldmap

dir_fmap = fullfile(dir_subj, 'realign');

for rr = 1:numRuns

    thisrun = allRuns{rr};
    phaseDefs = [ ...
        5.1700 % te1 (ms?)
        7.6300 % te2 (ms?)
        0 % epi-based fm?
        nan % total echo readout time (39.6 for hybrid, 39.6 for multi, 39.6 for rhythm, 19.525 for isss)
        -1 % k-space dir (+-1)
        0 % mask?
        0 % match?
        ];

    if strcmp(thisrun(1), 'i') % if isss
        phaseDefs(4) = 19.525;
    else % if otherwise
        phaseDefs(4) = 39.6;
    end
    
    cd(dir_fmap)
    VDM = FieldMap_preprocess_isss_multi(dir_fmap, dir_func, phaseDefs, [], thisrun);

    % move new files or else code above breaks because it's terrible code
    % and it's not my fault.
    mkdir(thisrun)
    movefile(fullfile(dir_fmap, 'fpm_scfieldmap_phase.nii'), thisrun);
    movefile(fullfile(dir_fmap, 'scfieldmap_phase.nii'), thisrun);
    movefile(fullfile(dir_fmap, 'vdm5_scfieldmap_phase.nii'), thisrun);


end