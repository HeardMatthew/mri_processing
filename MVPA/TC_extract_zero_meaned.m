%%%% This program gets called by TC_extract_batch.v
%%%% This prgoram itself doesn't contain any cd commands,
%%%% so it simply reads the mask.img and writes the .mat file
%%%% into whichever directory TC_exctract_batch puts it into
%%%% That should be GLM_unsmoothed

%Turn off annoying warnings
% warning off MATLAB:divideByZero;

%% Debugging: these are defined in TC_extract_isss_multi
% runs(1).name = 'hybrid';
% runs(1).num_TC_per_run = 180;
% 
% runs(2).name = 'isss';
% runs(2).num_TC_per_run = 90;
% 
% rr = 1;

%%
warning off
cd(dir_GLM)

%%%% Only do the calculation for voxels in the mask image
mask_hdr = spm_vol('mask.nii');
mask_matrix = spm_read_vols(mask_hdr);
mask_inds = find(mask_matrix);     %%% The indices of where mask=1
mask_voxel_num = length(mask_inds);

[mask_x, mask_y, mask_z] = ind2sub(size(mask_matrix), mask_inds);

%%% XYZ has three rows, and one col for every voxel in the mask
XYZ = [mask_x, mask_y, mask_z]';

load SPM.mat % only needs to extract the linear drift filter!

% num_TC_per_run = 240;
% num_runs=6;

zero_meaned_tc_total = zeros(runs(rr).num_TC_per_run * runs(rr).num_runs, mask_voxel_num);
TC_matrix = zeros(size(mask_matrix, 1), size(mask_matrix, 2), size(mask_matrix, 3), runs(rr).num_TC_per_run);

for runNum = 1:2 % two runs of each protocol
    disp(['Run: ' num2str(runNum) ]);
    
    images = spm_select('List', dir_func, ['^wu' runs(rr).name '_run' num2str(runNum) '_.*\.nii$']);
    path = repmat([dir_func filesep], runs(rr).num_TC_per_run, 1);
    images_full = [path images];
    unfiltered_TC = spm_get_data(images_full ,XYZ);
    filtered_TC = spm_filter(SPM.xX.K(1), unfiltered_TC); % removes linear drift with filter of 128s
    
    %initialize the zero meaned betas
        
    mean_filtered_TC = mean(filtered_TC,1);
    %std_TC_in_this_run=std(TC_in_this_run,1);
     
    zero_meaned_TC = bsxfun(@minus, filtered_TC, mean_filtered_TC); 
    % subtracts the mean filtered time course from each filtered time
    % course, to create the zero meaned time course!
    
    zero_meaned_tc_total(runs(rr).num_TC_per_run * (runNum-1) + 1 : runs(rr).num_TC_per_run*(runNum), :)= zero_meaned_TC;
    % i.e. first volume of run (either 1 or 181) : 
    % last volume of run (either 180 or 360)
    
    
end






