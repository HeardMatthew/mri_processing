%% analysis1_multi_v2
% Prepares to run multiband GLM analysis. Currently runs 1 subj at a time.
% Input: subjnum (1-10), runs. 

% CHANGELOG
% 09/01/17  File inception
% 09/06/17  Worked on timing and duration extraction
% 09/07/17  Added button press condition, accuracy regressor
% 09/08/17  Changed accuracy regressor to a condition, started function
% 09/15/17  Updated to use cells to store onsets, events, and durations
% 09/26/17  Changing to use cells instead of structs. Way easier to handle
%   in SPM batch
% 09/27/17  Forked into rhythm version after completing v4 update. 

function [onsets, durations] = extract_timing_rhythm(subject)
%% Parameters and Preallocation
if ~ischar(subject)
    error('Input ("subject" where subj is a string')
end

dir_preproc = pwd;
cd ..
isss_multi_params

% Find subject number
for ii = 1:length(subjects)
    if strcmp(subjects{ii}, subject)
        subjnum = ii;
    end
end

% Find numruns
numRuns = length(masterRuns{subjnum}) - 6;

% langRuns = cell(1, 6);
% for ii = 1:6
%     langRuns{ii} = allRuns{ii};
% end

conNames = {...
    'S70'  ... % Simple  long  (event key 1)
    'C70'  ... % Complex long  (event key 2)
    'S140' ... % Simple  short (event key 3)
    'C140' ... % Complex short (event key 4)
    'ODD'  ... % Oddball       (event keys 5, 6)
    'SIL'  ... % Silent        (event keys 7, 8)
    }; 

numCons = length(conNames); 

onsets.seconds = cell(numCons, numRuns);
onsets.scans = cell(numCons, numRuns);
durations.seconds = cell(numCons, numRuns);

%% Load data for subject
dir_subj = fullfile(dir_data, subject);
try
    events = size(answerKey, 1);
catch 
    disp(['Now loading behavioral data from scan for subject ' subject '...'])
    cd(fullfile(dir_subj, 'behav', 'scan'))
    files = dir('*rhythm*.mat');
    thisfile = files(end).name;
    if strcmp(subjects{subjnum}, 'CS_11Dec17') % we have to load BOTH files...
        dir_behav = pwd;
        cd(dir_preproc)
        combine_rhythm_mat
        cd(dir_behav)
        thisfile = '002_CS_rhythm_variables_combined.mat';
    end
    disp(['Found the rhythm file ' thisfile ', I sure hope it is correct!'])
    load(fullfile(files(end).folder, thisfile))
    disp('Done!')
    events = size(answerKey, 1);
end

eventMasks = cell(1, numCons);
onsetCell = cell(1, numCons);
for ii = 1:length(eventMasks)
    eventMasks{ii} = false(events, numRuns);
end
for ii = 1:length(onsetCell)
    onsetCell{ii} = cell(1, numRuns);
end

%% Prepare subject data
stimOnsets = stimStart - firstPulse; 
RT = cell2mat(respTime) - firstPulse; 

% Create response matrix
resp = zeros(events, numRuns); 
for rn = 1:numRuns
    for event = 1:events
        resp(event, rn) = str2double(respKey{event, rn}); 
    end
end


%% THE REAL CODING
for rn = 1:numRuns
%% EVENT MASKS
    for event = 1:events
        try          
            % All event matrices
            if eventKey(event,rn) == 1
                eventMasks{1}(event, rn) = true; 
            elseif eventKey(event,rn) == 2
                eventMasks{2}(event, rn) = true; 
            elseif eventKey(event, rn) == 3
                eventMasks{3}(event, rn) = true; 
            elseif eventKey(event,rn) == 4
                eventMasks{4}(event, rn) = true; 
            elseif find(eventKey(event,rn) == [5, 6])
                eventMasks{5}(event, rn) = true; 
            elseif find(eventKey(event,rn) == [7, 8])
                eventMasks{6}(event, rn) = true; 
            end
        catch err
            rethrow(err)
        end
    end
end

%% ONSETS and DURATIONS
allOnsets = cell(1, numCons);
allDurations = cell(1, numCons);

for rn = 1:numRuns
    tempOnsets = stimOnsets(:, rn);
    tempDurations = stimDuration(:, rn);
    for ii = 1:numCons
        allOnsets{ii} = horzcat(allOnsets{ii}, tempOnsets(eventMasks{ii}(:, rn)));
        allDurations{ii} = horzcat(allDurations{ii}, tempDurations(eventMasks{ii}(:, rn)));
    end
    if isempty(allDurations{1}) % This is what happens when you skip run 1
        for jj = 1:numCons
            if jj < 5
                allOnsets{jj} = nan(4, 1);
                allDurations{jj} = nan(4, 1);
            else
                allOnsets{jj} = nan(2, 1);
                allDurations{jj} = nan(2, 1);
            end
        end
    end
end

%% Extract onsets and durations of each stimuli category
for cn = 1:numCons
    for rn = 1:numRuns
        onsets.seconds{cn, rn} = allOnsets{cn}(:, rn);
        durations.seconds{cn, rn} = allDurations{cn}(:, rn);
    end
end

%% Build onsets.scans
timeKey = eventStartKey(:, numRuns) + p.presTime;
scanKey = (10:10:210)';

for cn = 1:numCons
    for rn = 1:numRuns
        onsetsTemp = onsets.seconds{cn, rn};
        whichScan = false(p.events, 1);

        for ii = 1:length(onsetsTemp)
            for jj = 1:p.events
                if onsetsTemp(ii) < timeKey(jj)
                    whichScan(jj) = true;
                    break
                end
            end
        end

        onsets.scans{cn, rn} = scanKey(whichScan);

    end
end

%% Save
cd(dir_subj)
save('onsets_rhythm.mat', 'onsets')
save('durations_rhythm.mat', 'durations')
cd(dir_preproc)

end