function [responseTimes responseKeyboardEvents responseAcc timing] = ...
    rd_presentRivalryTrainingImageSequence(window, texs, imageDuration, trialDuration, correctResponses, responseNames, responseKeyNumbers, devNums, errorsound)

% Given a list of image texture pointers and image durations, present one
% image after the other and collect responses throughout. Separate images
% by blank rivalry annuluses. Collect item responses and give feedback
% for wrong responses. Items can be images, categories, or something else.
%
% Modified from rd_presentRivalryTrainingImageSequence4
% (It is really identical except for variable name changes)
%
% Rachel Denison
% February 2013

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializations
refrate = 60;
nTrials = length(texs);
[blankTexture blanktex] = rd_makeRivalryBlankTexture(window);

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
responseTimes = zeros(nTrials,1);
responseKeyboardEvents = zeros(nTrials,1);
responseAcc = zeros(nTrials,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRESENT TRIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slack = 1/refrate/2; 

% dummy start time
timeFlipBlank = GetSecs;

for trial = 1:nTrials

    imagetex = texs(trial);

    % Draw images
    Screen('DrawTexture', window, imagetex);
    timeFlipImage = Screen('Flip', window);

    keyAlreadyPressed = 0; % take first key press only
    while GetSecs < timeFlipImage + imageDuration - slack
        % Check subject response
        [keyIsDown, seconds, keyCode] = KbCheck(devNums.Keypad); % Check the state of the keyboard

        if keyIsDown && ~keyAlreadyPressed && sum(keyCode)<2 % don't take multiple responses
            [responseTimes(trial) responseKeyboardEvents(trial) responseAcc(trial)] = ...
                keyDownActions(seconds, timeFlipImage, keyCode, responseNames, ...
                responseKeyNumbers, correctResponses, errorsound);
            
            if responseTimes(trial) > 0.1 % assume rt < 100 ms is response to previous image
                keyAlreadyPressed = 1;
            end
        end
    end
    
    timing.blank(trial,1) = timeFlipImage - timeFlipBlank;
    
    % Draw blank  
    Screen('DrawTexture', window, blanktex);
    timeFlipBlank = Screen('Flip', window);
    
    while GetSecs < timeFlipImage + trialDuration - slack
        % Check subject response
        [keyIsDown, seconds, keyCode] = KbCheck(devNums.Keypad); % Check the state of the keyboard
        
        if keyIsDown && ~keyAlreadyPressed && sum(keyCode)<2
            [responseTimes(trial) responseKeyboardEvents(trial) responseAcc(trial,1)] = ...
                keyDownActions(seconds, timeFlipImage, keyCode, responseNames, ...
                responseKeyNumbers, correctResponses, errorsound);
            keyAlreadyPressed = 1;
        end
    end
    
    timing.image(trial,1) = timeFlipBlank - timeFlipImage;

end % end trials

% Shut down realtime-mode:
% kluge to deal with random intermittent crashes until MacOS is updated
successfullySetPriority = 0;
while ~ successfullySetPriority
    try
        Priority(0);
        successfullySetPriority = 1;

    catch
        successfullySetPriority = 0;
    end
end

% release all textures and offscreen windows
Screen('Close');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keyDownActions
function [rt response correct] = keyDownActions(seconds, timeFlipImage, keyCode, responseNames, responseKeyNumbers, correctResponses, errorsound)
    rt = seconds - timeFlipImage;
    response = find(keyCode);

    % feedback
    if nnz(responseKeyNumbers==response)>0
        responseType = responseNames{responseKeyNumbers==response};
    else
        responseType = [];
    end

    if ~isempty(responseType)
        correct = strcmp(correctResponses{trial}, responseType);
    else
        correct = 0;
    end
    if ~correct
        sound(errorsound, 8000);
    end
end % end keyDownActions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end % end main function




