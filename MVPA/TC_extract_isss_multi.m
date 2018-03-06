clear all; close all; clc; 

% base_dir = '/jet/ysl/AOC2/'; %%% Where the subjects' data is kept
dir_MVPA_batch = pwd;
cd ..
isss_multi_params

dir_MVPA_data = fullfile(dir_data, 'mvpa');
numSubjs = length(subjects);

%% Run data
runs(1).name = 'hybrid';
runs(1).num_TC_per_run = 180;
runs(1).num_runs = 2;

runs(2).name = 'isss';
runs(2).num_TC_per_run = 90;
runs(2).num_runs = 2;

%% The hard work
for ss = 1:numSubjs
    thissubj = subjects{ss};
    disp(['extracting time-courses for ' thissubj]);

    dir_thisSubj = fullfile(dir_data, thissubj);
    dir_func = fullfile(dir_thisSubj, 'FUNCTIONAL');
    
    for rr = 1:length(runs) % hybrid and isss
        dir_GLM = fullfile(dir_thisSubj, 'design', [runs(rr).name '_unsmoothed']);

        %AOC2_get_time_courses_of_mask_voxels
        cd(dir_MVPA_batch)
        extract_zero_meaned_tc
        
        mat_file_name = [thissubj(1:2) '_' runs(rr).name, '_zero_meaned_tc.mat'];

        %save (mat_file_name, 'mask_time_courses');
        cd(dir_MVPA_data)
        save(mat_file_name, 'zero_meaned_tc_total'); % saves in data/mvpa dir
        clear zero_meaned_tc_total; clear XYZ; 
    end
end  %%% End of loop through subjects

