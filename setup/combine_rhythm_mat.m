%% combine_rhythm_mat
% Combines behavioral data collected from multiple runs, because sometimes
% that happens! Runs as a sub-script of extract_timing_rhythm.mat

% CHANGELOG (DD/MM/YY)
% 14/12/17  File started after realizing data from subject CS_11Dec17 had
%   an exception

%% Pathing
cd(dir_behav)

for fnum = 1:length(files) % for each rhythm file...
    load(files(fnum).name)
    
    vars_onerun = whos;
    
    vars_idx = 1;
    for ii = 1:length(vars_onerun) % make a cell with each variable's value
        if vars_onerun(ii).size(2) == 2 % if the variable has two columns...
            vars_allnames{fnum, vars_idx} = vars_onerun(ii).name;
            vars_allclasses{fnum, vars_idx} = vars_onerun(ii).class;
            vars_allvalues{fnum, vars_idx} = eval(vars_allnames{fnum, vars_idx});
            vars_idx = vars_idx + 1;
        end
    end
    
end

% test that all loaded correctly
for jj = 1:length(vars_allnames)
    if ~strcmp(vars_allnames{1, jj}, vars_allnames{2, jj})
        error('Names of variables do not all match!')
    end
end

for ii = 1:length(vars_allnames)
    temp{ii} = vars_allnames{1, ii};
end

vars_allnames = temp;

for value = 1:length(vars_allvalues)
    temp1 = vars_allvalues{1, value};
    temp2 = vars_allvalues{2, value};
    vars_newvalues{value} = [temp1(:, 1), temp2(:, 2)];
end
    
newvars = cell2struct(vars_newvalues', vars_allnames, 1);

cd(dir_behav)

save('002_CS_rhythm_variables_combined.mat', '-struct', 'newvars') % just change the name manually

