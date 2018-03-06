close all; clc;

clear sc
sc{1} = 'isss';
sc{2} = 'hybrid';

disp(['Making contrast images for subject ' thissubj]);


    thisDesignDir = fullfile(designDir, 'hybrid');
    cd(thisDesignDir);

    V1 = spm_vol('AUE_NOI_run1.nii');
    V2 = spm_vol('AUE_NOI_run2.nii');
    V3 = spm_vol('AUE_SIL_run1.nii');
    V4 = spm_vol('AUE_SIL_run2.nii');
    V5 = spm_vol('AUE_ORA_run1.nii');
    V6 = spm_vol('AUE_ORA_run2.nii');
    V7 = spm_vol('AUE_SRA_run1.nii');
    V8 = spm_vol('AUE_SRA_run2.nii');

    Img1 = spm_read_vols(V1);
    Img2 = spm_read_vols(V2);
    Img3 = spm_read_vols(V3);
    Img4 = spm_read_vols(V4);
    Img5 = spm_read_vols(V5);
    Img6 = spm_read_vols(V6);
    Img7 = spm_read_vols(V7);
    Img8 = spm_read_vols(V8);
    
    %% NOI > SIL
    merge = (Img1+Img2)/2 - (Img3+Img4)/2;
    V_merge = V1;
    V_merge.fname ='AUE_NOI_SIL.nii';  %%% Give this a new name
    spm_write_vol(V_merge, merge);
    
    %% LNG > NOI
    merge = (Img5+Img6+Img7+Img8)/4 - (Img1+Img2)/2;
    V_merge = V1;
    V_merge.fname ='AUE_LNG_NOI.nii';  %%% Give this a new name
    spm_write_vol(V_merge, merge);
    
    %% ORA > SRA
    merge = (Img5+Img6)/2 - (Img7+Img8)/2;
    V_merge = V1;
    V_merge.fname ='AUE_ORA_SRA.nii';  %%% Give this a new name
    spm_write_vol(V_merge, merge);
    
end