close all; clc;

sc(1).type = 'isss';
sc(1).TRs = 5;
sc(1).index = [1:5:20];

sc(2).type = 'hybrid';
sc(2).TRs = 10;
sc(2).index = [1:10:40];

numCon = 4; %NOI, SIL, ORA, SRA

disp(['Making contrast images for subject ' thissubj ]);

for ii = 1:length(sc) % For each scan...
    disp(['Working on ' sc(ii).type '...'])
    thisDesignDir = fullfile(designDir, sc(ii).type);
    cd(thisDesignDir);

    Vmask = spm_vol('mask.nii'); % loads header for mask
    mask_matrix = spm_read_vols(Vmask);
    mask_inds = find(mask_matrix);     %%% The indices of where mask=1
    num_mask_voxels = length(mask_inds);
    
    [x_in_mask,y_in_mask,z_in_mask] = ind2sub(size(mask_matrix),mask_inds);
    
    XYZ = [x_in_mask,y_in_mask,z_in_mask]';
    
    for rr = 1:2 % For each run...
        for con = 1:numCon

            if con == 1
                cond_name = 'NOI';
            elseif con == 2
                cond_name = 'SIL';
            elseif con == 3
                cond_name = 'ORA';
            elseif con == 4
                cond_name = 'SRA';
            end

            betas_all = zeros(sc(ii).TRs, num_mask_voxels);
            for TR = 1:sc(ii).TRs
                thisTR = sc(ii).index(con) + TR - 1;
                if rr == 2 % If run 2...
                    if ii == 1 % If isss
                        if strcmp(thissubj, 'ZG_03Nov17') % ZG has no physio
                            run2 = 26;
                        else
                            run2 = 30;
                        end
                    elseif ii == 2 % if hybrid
                        if strcmp(thissubj, 'ZG_03Nov17') % ZG has no physio
                            run2 = 46;
                        else
                            run2 = 50;
                        end
                    end
                    
                    thisTR = thisTR + run2;
                end
                
                if thisTR < 10
                    thisTR = ['000' num2str(thisTR)];
                elseif thisTR < 100
                    thisTR = ['00'  num2str(thisTR)];
                end
                image_filenames_without_dir_path = spm_select('List',thisDesignDir,['beta_' thisTR '.nii']);
                copies_of_directory_path = repmat(thisDesignDir,1,1);
                image_filenames_with_path = [copies_of_directory_path filesep image_filenames_without_dir_path];
                betas_all(TR,:) = spm_get_data(image_filenames_with_path,XYZ);

            end


            %% calculating area
            AUE_for_this_cond = zeros(1,num_mask_voxels);
            for voxel = 1:num_mask_voxels
                area_all = 0;
                for TR = 1:(sc(ii).TRs - 1) % minus one because last sample calls on TR end-1 and end
                    y1=betas_all(TR,voxel); y2=betas_all(TR+1,voxel);

                    % If both are above zero...
                    if y1 > 0 && y2 > 0 % trapezoid shape
                        area= (y1+ y2)/2;

                    % If both are below zero...
                    elseif y1 < 0 && y2 < 0
                        % area= -1*(y1+ y2)/2;
                        area=0;

                    % If 1 is above and 2 is below
                    elseif y1 > 0 && y2 < 0
                        b=y1;
                        a=y2-y1;
                        x=-b/a;
                        area=(x*y1/2);%+ ((1-x)*y2/2);

                    elseif y1 < 0 && y2 > 0
                        b=y1;
                        a=y2-y1;
                        x=-b/a;
                        %  area=(x*y1/2)+ ((1-x)*y2/2);
                        area=((1-x)*y2/2);

                    end

                    area_all=area_all+area;
                end

                AUE_for_this_cond(1,voxel)=area_all;

            end

            Vol=spm_vol('beta_0001.nii');
            Img=spm_read_vols(Vol);
            Vol.fname=['AUE_' cond_name '_run' num2str(rr) '.nii'];

            for voxel=1:num_mask_voxels

                Img(mask_inds(voxel))=AUE_for_this_cond(1,voxel);
            end

            spm_write_vol(Vol, Img);


        end
    end
end
    
