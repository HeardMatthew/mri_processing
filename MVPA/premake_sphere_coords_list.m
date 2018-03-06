%%%% Premake the sphere coords and store them

%%%% We need to get the volume info for the analysis images.
%%%% We can use the mask image

%%% Script is called by batch_coord_sphere, make sure to run that first!

cd(dir_thisrun) % declared in batch_coord_sphere

Vmask = spm_vol('mask.nii');
mask_matrix = spm_read_vols(Vmask);
mask_inds = find(mask_matrix);     %%% The indices of where mask=1
num_mask_voxels = length(mask_inds);

x_size = Vmask.dim(1);
y_size = Vmask.dim(2);
z_size = Vmask.dim(3);

x_coord_vec = [1:x_size];
y_coord_vec = [1:y_size];
z_coord_vec = [1:z_size];

%%%%%%%%%%%%%%% Now make a 3D mesh-grid of x,y and z coords
%%% x-coord is the row in this grid
x_coord_grid = x_coord_vec' * ones(1,y_size);
%%% y-coord is the col in this grid
y_coord_grid = ones(x_size,1) * y_coord_vec;
%%% Now stack these in the 3rd dimension, to make coords cubes
x_coord_cube = [];
y_coord_cube = [];
z_coord_cube = [];

for z_slice = 1:z_size,
    x_coord_cube = cat(3,x_coord_cube,x_coord_grid);
    y_coord_cube = cat(3,y_coord_cube,y_coord_grid);
    z_coord_cube = cat(3,z_coord_cube,z_slice*ones(size(x_coord_grid)));
end;




%%%% Now go through the volume and calculate sphere coords
sphere_XYZ_indices_cell = cell(num_mask_voxels,1);

%%% The ordering of x,y and z in zero_meaned_time_courses is this:
[x_in_mask,y_in_mask,z_in_mask]=ind2sub(size(mask_matrix),mask_inds);
%%% XYZ has three rows, and one col for every voxel in the mask
XYZ = [x_in_mask,y_in_mask,z_in_mask]';

%%% Make a predefined lookup-table of XYZ x-locations,
%%% to save time in the loop below
X_max = max(XYZ(1,:));
X_index_lookup_table = cell(X_max,1);
for x = 1:X_max
    X_index_lookup_table{x,1} = find( XYZ(1,:)==x );
end

    
for voxel_num =1:length(mask_inds)

    if rem(voxel_num,2000)==0
        disp([ 'Voxel number ' num2str(voxel_num) ' out of ' num2str(num_mask_voxels) ]);
    end

    [ center_x center_y center_z ] = ind2sub(size(mask_matrix),mask_inds(voxel_num));

    distance_cube = sqrt( (x_coord_cube - center_x).^2 + ...
        (y_coord_cube - center_y).^2 + ...
        (z_coord_cube - center_z).^2  );

    within_sphere = ( distance_cube <= sphere_radius );
    within_sphere_and_mask = within_sphere.*mask_matrix;
    sphere_inds = find(within_sphere_and_mask);
%     within_sphere_inds = find( distance_cube <= sphere_radius );
%     sphere_inds = intersect(within_sphere_inds,mask_inds);
    
    [ sphere_x_coords  sphere_y_coords  sphere_z_coords ] = ind2sub( size(mask_matrix), sphere_inds);

    num_sphere_voxels = length(sphere_inds);
    XYZ_index_list = zeros(1,num_sphere_voxels);
    
    for sphere_vox_num = 1:num_sphere_voxels,

        x = sphere_x_coords(sphere_vox_num);
        y = sphere_y_coords(sphere_vox_num);
        z = sphere_z_coords(sphere_vox_num);

        X_matches = X_index_lookup_table{x,1};
        XY_matches = X_matches( find(XYZ(2,X_matches)==y) );
        XYZ_index = XY_matches( find(XYZ(3,XY_matches)==z) );

        XYZ_index_list(sphere_vox_num) = XYZ_index;
    end;   %%% End of loop through voxels within this sphere
          
    sphere_XYZ_indices_cell{voxel_num} = XYZ_index_list;

end;

