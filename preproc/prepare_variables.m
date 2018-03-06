%% prepare_variables
% Combines multiple instances of the variables.mat folder (if needed)
% Author -- MH

% CHANGELOG (DD/MM/YY)
% 21/11/17  Initialized file -- MH

%% Parameters
thissubj = 'KN_27Oct17';
initials = thissubj(1:2);

%% Path
preprocDir = pwd;
cd ..
batchDir = pwd;
cd ..
isss_multi_params
% studyDir = pwd;
cd data
% dataDir = pwd;
cd(thissubj)
cd behav
cd scan

%% Load variables
mFiles = dir(['*' initials '_lang_variables*.mat']);

%% Which to keep? 
trueRespKey = cell(16, 6);
trueEventKey = NaN(16, 6);
trueAbsStimStart = NaN(16, 6);
trueFirstPulse = NaN(1, 6);
trueStimDuration = NaN(16, 6);
trueEventStartKey = NaN(16, 6);

runs = 1:6;
for rr = 1:length(mFiles)
    load(mFiles(rr).name)
    quitRuns = any(isnan(eventEnd)); % Which runs were aborted, if any?
    
    %% For each kept run...
    for ii = ~quitRuns
        for jj = 1:size(respKey, 2)
            trueRespKey = respKey{jj, ii};
        end
        trueEventKey = eventKey(:, ii);
        trueAbsStimStart = AbsStimStart(:, ii);
        trueFirstPulse = firstPulse(ii);
        trueStimDuration = stimDuration(:, ii);
        trueEventStartKey = eventStart(:, ii);
    end
    
    
    
end


