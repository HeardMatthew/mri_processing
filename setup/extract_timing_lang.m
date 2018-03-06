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
% 09/29/17  Combined with convert to scans. 
% 11/08/17  Updated with new naming conventions
% 11/21/17  Went through to try and catch errors. Turned into a new,
%   simpler script. 

function onsets = extract_timing_lang(subject)
%% Parameters and Preallocation
if ~ischar(subject)
    error('Input ("subject") where subj is a string')
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

langRuns = cell(1, 6);
for ii = 1:6
    langRuns{ii} = allRuns{ii};
end

conNames = {...
    'NOI' ...
    'SIL' ...
    'ORA' ...
    'SRA' ...
    }; 

numCons = length(conNames); 
numRuns = length(langRuns);

onsets.h_seconds = cell(numCons, 2);
onsets.i_seconds = cell(numCons, 2);
onsets.m_seconds = cell(numCons, 2);

durations.h_seconds = cell(numCons, 2);
durations.i_seconds = cell(numCons, 2);
durations.m_seconds = cell(numCons, 2);

%% Load data for subject
dir_subj = fullfile(dir_data, subject);
try
    events = size(answerKey, 1);
catch 
    disp(['Now loading behavioral data from scan for subject ' subject '...'])
    cd(fullfile(dir_subj, 'behav', 'scan'))
    var = dir(['*' subject(1:2) '_lang_variables*.mat']);
    disp(['Found ' num2str(length(var)) ' variable files.']) % There might be many from aborted runs
    if length(var) ~= 1
        %% Combining aborted runs
        disp('Let us begin the splicing!')
        
        % Relevant quantities needed
        trueRespKey = cell(16, 6);
        trueEventKey = NaN(16, 6);
        trueAbsStimStart = NaN(16, 6);
        trueFirstPulse = NaN(1, 6);
        trueStimDuration = NaN(16, 6);
        trueEventStartKey = NaN(16, 6);
        
        goodRuns = cell(1, length(var));
        
        % Going through each variable.mat file...
        for vv = 1:length(var)
            load(fullfile(var(vv).folder, var(vv).name))
            keepRuns = zeros(1, 6); % Determine which runs to include
            for rr = 1:6
                if ~isnan(actEventDur(1, rr))
                    keepRuns(rr) = 1;
                end
            end
            goodRuns{vv} = keepRuns;
            
            for rr = find(keepRuns == 1) % For each good run...
                
                % Extract good respKey
                for jj = 1:size(respKey, 2)
                    trueRespKey{rr, jj} = respKey{rr, jj};
                end
                
                % Extract good other stuff
                trueEventKey(:, rr) = eventKey(:, rr);
                trueAbsStimStart(:, rr) = AbsStimStart(:, rr);
                trueFirstPulse(rr) = firstPulse(rr);
                trueStimDuration(:, rr) = stimDuration(:, rr);
                trueEventStartKey(:, rr) = eventStartKey(:, rr);
            end
            
        end
        
        respKey = trueRespKey;
        eventKey = trueEventKey;
        AbsStimStart = trueAbsStimStart;
        firstPulse = trueFirstPulse;
        stimDuration = trueStimDuration;
        eventStartKey = trueEventStartKey;
       
    else
        load(fullfile(var.folder, var.name))
    end
    disp('Done!')
    events = size(answerKey, 1);    
end

eventMasks = cell(1, numCons); % Includes correct and incorrect masks
onsetCell = cell(1, numCons);
for ii = 1:length(eventMasks)
    eventMasks{ii} = false(events, numRuns);
end
for ii = 1:length(onsetCell)
    onsetCell{ii} = cell(1, numRuns);
end

% %% Preallocate scan, onset, and duration structures
% s = struct('h', NaN, 'i', NaN, 'm', NaN); 
% r = struct('n', NaN); 
% 
% s.h = struct('r1', r, 'r2', r); 
% s.i = struct('r1', r, 'r2', r); 
% s.m = struct('r1', r, 'r2', r); 
% 
% sTypes = fields(s); 
% runNum = fields(s.h); 
% 
scanOrder = NaN(2, 3);
scanOrder(:, 1) = find(masterMat(subjnum, :) == 1); % hybrid
scanOrder(:, 2) = find(masterMat(subjnum, :) == 2); % isss
scanOrder(:, 3) = find(masterMat(subjnum, :) == 3); % multi
% 
% for scan = 1:3
%     for run = 1:2
%         s.(sTypes{scan}).(runNum{run}).order = scanOrder(run, scan); 
%     end
% end

%% Prepare object, subject, noise, and silence keys
ns = NumSpStim; 
objKey    = sort(horzcat(1:4:ns, 2:4:ns));
subjKey   = sort(horzcat(3:4:ns, 4:4:ns));
noiseKey  = [193 194 195 196];
silentKey = [197 198 199 200];

%% Prepare subject data
stimOnsets = AbsStimStart - firstPulse; 

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
            if find(eventKey(event,rn) == noiseKey)
                eventMasks{1}(event, rn) = true; 
            elseif find(eventKey(event,rn) == silentKey)
                eventMasks{2}(event, rn) = true; 
            elseif find(eventKey(event, rn) == objKey)
                eventMasks{3}(event, rn) = true; 
            elseif find(eventKey(event,rn) == subjKey)
                eventMasks{4}(event, rn) = true; 
            end
            
        catch err
            rethrow(err)
        end
    end
end

%% ONSETS and DURATIONS
allOnsets = cell(1, numCons);
allDurations = cell(1, numCons);
for ii = 1:numCons
    allOnsets{ii} = reshape(stimOnsets(eventMasks{ii}), [4, numRuns]); 
    allDurations{ii} = reshape(stimDuration(eventMasks{ii}), [4, numRuns]); 
end

%% Extract onsets and durations of each stimuli category
scT = fields(onsets);

for sc = 1:length(scT)
    for cn = 1:numCons
        for rn = 1:2
            onsets.(scT{sc}){cn, rn} = allOnsets{cn}(:, scanOrder(rn, sc));
            durations.(scT{sc}){cn, rn} = allDurations{cn}(:, scanOrder(rn, sc));
        end
    end
end

%% Convert to scans
onsets.h_scans = cell(numCons, 2);
onsets.i_scans = cell(numCons, 2);
onsets.m_scans = cell(numCons, 2);

timeKey = eventStartKey(:, 1) + p.presTime;

scT = fields(onsets); % 1-3 are _seconds, 4-6 are _scans
for sc = 1:3

    if strcmp(scT{sc}(1), 'h') % Hybrid
        scanKey = (10:10:179)';
    elseif strcmp(scT{sc}(1), 'i') % ISSS
        scanKey = (5:5:89)';
    elseif strcmp(scT{sc}(1), 'm') % Multiband
        scanKey = (10:14:247)';
    end
    
    for cn = 1:numCons
        for rn = 1:2
            onsetsTemp = onsets.(scT{sc}){cn, rn};
            whichScan = false(p.events, 1);

            for ii = 1:length(onsetsTemp)
                for jj = 1:p.events
                    if onsetsTemp(ii) < timeKey(jj)
                        whichScan(jj) = true;
                        break
                    end
                end
            end

            onsets.(scT{sc + 3}){cn, rn} = scanKey(whichScan);
            
        end
    end
    
end 

%% Save

cd(dir_subj)
save('onsets_lang.mat', 'onsets')
save('durations_lang.mat', 'durations')
cd(dir_batch)

end