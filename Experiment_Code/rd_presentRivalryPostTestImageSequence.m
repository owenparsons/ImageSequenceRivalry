function [responseTimes responseKeyboardEvents responseAcc] = ...
    rd_presentRivalryPostTestImageSequence(window, texs, imageDuration, trialDuration, interSequenceWaitTime, responseDuration, nItemsInUnitSequence, correctInterval, keyNumbers, devNums)

% Given a list of image texture pointers and image durations, present one
% image after the other in sequence groups for an n-interval-forced choice 
% task. After all presentations, collect a response for which interval the
% correct sequence appeared in.
%
% Rachel Denison
% March 2011

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializations
refrate = 60;
nAfcTrials = 1;
nTrials = length(texs);
[blankTexture blanktex] = rd_makeRivalryBlankTexture(window);

afcEndTrials = nItemsInUnitSequence:nItemsInUnitSequence:nTrials; 

% % Switch to realtime:
% priorityLevel = MaxPriority(window);
% 
% % kluge to deal with random intermittent crashes until MacOS is updated
% successfullySetPriority = 0;
% while ~ successfullySetPriority
%     try
%         Priority(priorityLevel);
%         successfullySetPriority = 1;
%     catch
%         successfullySetPriority = 0;
%     end
% end

% Initialize response measures
responseTimes = zeros(nAfcTrials,1);
responseKeyboardEvents = zeros(nAfcTrials,1);
responseAcc = zeros(nAfcTrials,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRESENT TRIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slack = 1/refrate/2; 

for trial = 1:nTrials
    
    imagetex = texs(trial);

    % Draw images
    Screen('DrawTexture', window, imagetex);
    timeFlipImage = Screen('Flip', window);
    while GetSecs < timeFlipImage + imageDuration - slack
        % Wait
    end

    % Draw blank
    Screen('DrawTexture', window, blanktex);
    timeFlipBlank = Screen('Flip', window);
    while GetSecs < timeFlipImage + trialDuration - slack
        % Wait
    end
    
    if ismember(trial, afcEndTrials(1:end-1)) % if we're between choice intervals
        WaitSecs(interSequenceWaitTime);
    end

end % end trials

% after all sequence choices are presented, collect response
keyIsDown = 0;
while ~keyIsDown && (GetSecs < timeFlipImage + trialDuration + responseDuration - slack)
    % Check subject response
    [keyIsDown, seconds, keyCode] = KbCheck(devNums.Keypad); % Check the state of the keyboard
    
    % Hack to get rid of numlock in keycode
    keyCode(KbName('NumLockClear')) = 0;
    
    if keyIsDown && sum(keyCode)<2
        [responseTimes responseKeyboardEvents responseAcc] = ...
            keyDownActions(seconds, timeFlipBlank, keyCode, ...
            keyNumbers, correctInterval);
    end
end

% % Shut down realtime-mode:
% % kluge to deal with random intermittent crashes until MacOS is updated
% successfullySetPriority = 0;
% while ~ successfullySetPriority
%     try
%         Priority(0);
%         successfullySetPriority = 1;
% 
%     catch
%         successfullySetPriority = 0;
%     end
% end

% release all textures and offscreen windows
% Screen('Close');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keyDownActions
function [rt responseKey correct] = keyDownActions(seconds, timeFlipBlank, keyCode, keyNumbers, correctInterval)
    rt = seconds - timeFlipBlank;
    responseKey = find(keyCode);
    
    % feedback
    if isempty(responseKey)
        responseKey = NaN;
        response = [];
    else
        response = find(keyNumbers==responseKey);
    end
    
    if ~isempty(response)
        correct = response==correctInterval;
    else
        correct = 0;
    end
end % end keyDownActions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end % end main function




