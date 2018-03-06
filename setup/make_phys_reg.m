%% make_physio_regressor(run)
% Does exactly what it says on the tin. Save your zip file holding the
% regressor in the \PHYSIO\run folder, and sit back to watch the magic
% happen. 

% CHANGELOG
% 09/11/17  File inception
% 09/15/17  Updated file to follow current conventions of isss_multi_params

function make_phys_reg(subj)
if ~isstr(subj)
    error('Input ("subj") where subj is a string')
end

funclocImages = 60;

cd ..
isss_multi_params

cd(dir_data)
cd(subj)
dir_subj = pwd;
dir_physio = fullfile(dir_subj, 'PHYSIO');
dir_reg = fullfile(dir_subj, 'reg');
cd(dir_physio)

%% Read in raw data
niis = dir('*.nii');
% info = fields(niis);

names = cell(1, length(niis));
newnames = cell(1, length(niis));
for ii = 1:length(niis)
    names{ii} = niis(ii).name;
    if isnan(str2double(names{ii}(end-5:end-4))) % i.e. if the file is number 0 to 9
        newnames{ii} = [names{ii}(1:11), '0', names{ii}(12:end)];
    else
        newnames{ii} = names{ii};
    end
    niis(ii).name = newnames{ii};
end

niis_cell = struct2cell(niis)';
niis_cell = sortrows(niis_cell, 1);
niis = cell2struct(niis_cell', fields(niis));

% Test
if isempty(niis)
    error('No niis found in file. Make sure you extracted from zip and converted from dicm')
end

V = cell(1, length(niis));
P = cell(1, length(niis));
for n = 1:length(niis)
    [V{n}, ~] = ReadData3D(niis(n).name, false);
    V{n} = reshape(V{n}, size(V{n}, 3), size(V{n}, 2));
end

skipRun = [];
funcloc = [];

for ii = 1:length(V)
    if size(V{ii}, 1) == funclocImages
        funcloc = [funcloc ii];
        disp('Found the funcloc. Skipping...')
    elseif ~((size(V{ii}, 1) == 124) || (size(V{ii}, 1) == 248) || (size(V{ii}, 1) == 291))
        skipRun = [skipRun ii];
        disp('Found an aborted run. Skipping...')
    else
        if ii < 10
            headerName = fullfile(pwd, ['header_0', num2str(ii)]);
        else
            headerName = fullfile(pwd, ['header_', num2str(ii)]);
        end
        load(headerName);
        P{ii} = h.PulseRespiratoryRegressors.ProtocolName;
        disp(['Found ', P{ii}])
    end
end

removeRuns = [];

if skipRun ~= 0
    removeRuns = sort([funcloc, skipRun], 'descend');
else
    removeRuns = funcloc;
end

if funcloc ~= 0
    if skipRun ~= 0
        removeRuns = sort([funcloc, skipRun], 'descend');
    else
        removeRuns = funcloc;
    end
end

if ~isempty(removeRuns)
    for rr = removeRuns
        P(rr) = [];
        V(rr) = [];
    end
end

disp(['Found ' num2str(length(P)) ' files total.'])

for run = 1:length(P)
    %% Prepare to make regressors
    hybrid = 0;
    isss   = 0;
    multi  = 0;
    rhythm = 0;
    skipToEnd = 0;

    if strcmp(P{run}(1), 'h')
        hybrid = 1;
        isInterleaved = 1;
        numImages = 180;
    elseif strcmp(P{run}(1), 'i')
        isss = 1;
        isInterleaved = 1;
        numImages = 90;
    elseif strcmp(P{run}(1), 'm')
        multi = 1; 
        isInterleaved = 0;
        numImages = 248;
    elseif strcmp(P{run}(1), 'r')
        rhythm = 1;
        isInterleaved = 1;
        numImages = 211;
    end

    
    if ~isInterleaved
        try
            reg = reshape(V{run}, [numImages 8]);
        catch
            disp(['Something happened during run ' P{run}, ' and the regressor was not created'])
            skipToEnd = 1;
        end
    else
        if isss
            firstScans = ones(5, 8); 
            template = vertcat(false(2, 1), true(5, 1));
            extract = vertcat(firstScans, repmat(template, [17, 8]));
        elseif hybrid
            firstScans = ones(10, 8); 
            template = vertcat(false(4, 1), true(10, 1));
            extract = vertcat(firstScans, repmat(template, [17, 8]));
        elseif rhythm
            firstScans = ones(10, 8); 
            template = vertcat(false(4, 1), true(10, 1));
            extract = vertcat(firstScans, repmat(template, [20, 8]), ones(1, 8));
        end

        try
            reg = reshape(V{run}(extract == 1), [numImages, 8]); 
        catch
            disp(['Something happened during ' P{run} ' and the regressor was not created.'])
            skipToEnd = 1;
        end

        % A quick test...
        if ~skipToEnd
            temp = 0:numImages-1; 
            if isss
                index = (floor(temp / 5)*7 + mod(temp, 5) + 1);
            elseif hybrid
                index = (floor(temp / 10)*14 + mod(temp, 10) + 1);
            elseif rhythm
                temp(end) = [];
                index = [(floor(temp / 10)*14 + mod(temp, 10) + 1), 291];
            end

            for ii = 1:numImages
                for jj = 1:8
                    if reg(ii, jj) ~= V{run}(index(ii), jj)
                        disp(['SOMETHING WENT WRONG IN RUN ', P{run}, ', LIKELY THAT THE RUN WAS ABORTED DURING SCAN'])
                        skipToEnd = 1;
                        break
                    end                    
                end
                if skipToEnd
                    break
                end
            end
        end

    end

    if ~skipToEnd
        cd(dir_reg)
        disp(['Saving ' P{run}])

        filename1 = ['physio_full_' P{run} '_00001.txt'];
        fid = fopen(filename1, 'w');
        for line = 1:numImages
            eline = '\t';
            for ii = 1:8
                if reg(line, ii) < 0
                    eline = [eline, '%e   '];
                elseif reg(line, ii) >= 0
                    eline = [eline, ' %e   '];
                end
            end
            fprintf(fid, eline, reg(line, :));
            fprintf(fid, '\n');
        end
        fclose(fid); 

        filename2 = ['physio_1st_' P{run} '_00001.txt'];
        fid = fopen(filename2, 'w');
        for line = 1:numImages
            eline = '\t';
            for ii = [1 2 5 6]
                if reg(line, ii) < 0
                    eline = [eline, '%e   '];
                elseif reg(line, ii) >= 0
                    eline = [eline, ' %e   '];
                end
            end
            fprintf(fid, eline, reg(line, [1 2 5 6]));
            fprintf(fid, '\n');
        end
        fclose(fid); 
    end

end

cd(dir_batch)
end
