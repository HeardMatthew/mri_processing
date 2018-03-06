%% average reaction time
RT = [];
numORtrials = 0;
for jj = 1:6
    for ii = 1:16
        if ~isnan(respTime{ii, jj})
            numORtrials = numORtrials + 1;
            RT = horzcat(RT, respTime{ii, jj}-stimEnd(ii, jj));
        end
    end
end

avgRT = mean(RT)
stdRT = std(RT)

%% acc
ORkey = sort([1:4:192 2:4:192]);
SRkey = sort([3:4:192 4:4:192]);
correctOR = 0;
correctSR = 0;
numORtrials = 0;
numSRtrials = 0;
for jj = 1:6
    for ii = 1:16
        if answerKey(ii, jj) ~= 0 % if not silent
            if answerKey(ii, jj) ~= 3 % if not noise
                if find(ORkey == eventKey(ii, jj)) % if OR
                    numORtrials = numORtrials + 1;
                    if str2double(respKey{ii, jj}) == answerKey(ii, jj) % if correct
                        correctOR = correctOR + 1;
                    end
                elseif find(SRkey == eventKey(ii, jj)) % if SR
                    numSRtrials = numSRtrials + 1;
                    if str2double(respKey{ii, jj}) == answerKey(ii, jj) % if correct
                        correctSR = correctSR + 1;
                    end
                end
            end
        end
    end
end

ORacc = correctOR/numORtrials
SRacc = correctSR/numSRtrials