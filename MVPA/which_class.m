%% which_class
% Creates a cell with dimensions numTRs*1 which I will share with Jihyung

close all; clear all; clc;  %#ok<CLALL>

%% Paths and parameters
dir_MVPA_batch = pwd;
cd ..
isss_multi_params

dir_MVPA_data = fullfile(dir_data, 'mvpa');
numSubjs = length(subjects);

for ss = 1:numSubjs % for each subject
    thissubj = subjects{ss};
    cd(fullfile(dir_data, thissubj, 'design'))
    
    disp(['Working on ' thissubj])
    
    for rr = 1:2 % for each run (hybrid and isss)
        if rr == 1
            thisrun = 'hybrid';
            numTRs = 360;
        elseif rr == 2
            thisrun = 'isss';
            numTRs = 180;
        end
        
        disp(['Working on ' thisrun])
        
        dir_work = fullfile(pwd, thisrun);
        cd(dir_work)
        
        disp('Loading SPM file...');
        load SPM.mat
        
        classes = cell(numTRs, 1);
        tags = cell(length(SPM.xX.name), 1);
        
        idx = 1; 
        for ii = 1:length(SPM.xX.name)-2 % Skip last 2, they're constant
            thiscolumn = SPM.xX.name{ii};
            if isempty(regexp(thiscolumn, '[R]\d', 'once')) % if this column is NOT a regressor
                tags{ii} = [thiscolumn(7:9) '_run' thiscolumn(4)];
            end
        end
        
        for ii = 1:length(tags)
            if ~isempty(tags{ii})
                idx = find(SPM.xX.X(:, ii));
                for jj = 1:length(idx)
                    classes{idx(jj)} = tags{ii};
                end
            end
        end

        cd(dir_MVPA_data)
        data_tc = [thissubj(1:2) '_' thisrun '_zero_meaned_tc.mat'];
        load(data_tc)
        
%         data_tc = ['DEMO_' data_tc];
        
        save(data_tc, 'zero_meaned_tc_total', 'classes')
        
        cd(dir_work)
        
        
        cd ..
        
    end
        
end
    