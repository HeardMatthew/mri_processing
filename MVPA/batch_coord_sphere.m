clear all; close all; clc; 

% base_dir = '/jet/ysl/AOC2/'; %%% Where the subjects' data is kept
dir_MVPA_batch = pwd;
cd ..
isss_multi_params
dir_MVPA_data = fullfile(dir_data, 'mvpa');

numSubjs = length(subjects);


%spm_get_defaults; 

sphere_radius = 2;

for ss = 1:numSubjs % for each subject
    
    thissubj = subjects{ss};

    disp(['Premaking spheres of radius ' num2str(sphere_radius) ...
          ' for ' thissubj]);
    warning off
    
    for rr = 1:2 % hybrid and isss runs

        if rr == 1
            thisrun = 'hybrid';
        elseif rr == 2
            thisrun = 'isss';
        end
        
        dir_thisrun = fullfile(dir_data, thissubj, 'design', [thisrun, '_unsmoothed']);

        cd(dir_MVPA_batch)        
        premake_sphere_coords_list;
        cd(dir_MVPA_data)

        mat_file_name = [ thissubj(1:2) '_' thisrun '_spheres_radius' num2str(sphere_radius) '.mat']; 
        save (mat_file_name, 'sphere_XYZ_indices_cell','sphere_radius');
        
    end

end  %%% End of loop through subjects

