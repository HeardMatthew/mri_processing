close all; clc;

disp(['Making contrast images for subject ' thissubj]);

dir_thisdesign = fullfile(dir_design, 'hybrid');
cd(dir_thisdesign);

for ww = 3:10 % the first two were garbage
    
    V1 = spm_vol(['AUE_NOI_run1_window' num2str(ww) '.nii']);
    V2 = spm_vol(['AUE_NOI_run2_window' num2str(ww) '.nii']);
    V3 = spm_vol(['AUE_SIL_run1_window' num2str(ww) '.nii']);
    V4 = spm_vol(['AUE_SIL_run2_window' num2str(ww) '.nii']);
    V5 = spm_vol(['AUE_ORA_run1_window' num2str(ww) '.nii']);
    V6 = spm_vol(['AUE_ORA_run2_window' num2str(ww) '.nii']);
    V7 = spm_vol(['AUE_SRA_run1_window' num2str(ww) '.nii']);
    V8 = spm_vol(['AUE_SRA_run2_window' num2str(ww) '.nii']);

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
    V_merge.fname = ['AUE_NOI_SIL_window' num2str(ww) '.nii'];  
    spm_write_vol(V_merge, merge);
    
    %% LNG > NOI
    merge = (Img5+Img6+Img7+Img8)/4 - (Img1+Img2)/2;
    V_merge = V1;
    V_merge.fname = ['AUE_LNG_NOI_window' num2str(ww) '.nii'];  
    spm_write_vol(V_merge, merge);
    
    %% ORA > SRA
    merge = (Img5+Img6)/2 - (Img7+Img8)/2;
    V_merge = V1;
    V_merge.fname = ['AUE_ORA_SRA_window' num2str(ww) '.nii'];  
    spm_write_vol(V_merge, merge);

end
