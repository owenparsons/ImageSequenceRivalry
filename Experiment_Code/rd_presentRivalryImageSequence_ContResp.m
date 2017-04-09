function [responseTimes responseKeyboardEvents] = ...
    rd_presentRivalryImageSequence_ContResp(window, tex, itemDuration, blankDuration, responseDuration, redKeyCode, blueKeyCode, devNums)

% Given a list of image texture pointers and image durations, present one
% image after the other and collect responses throughout. Separate images
% by blank rivalry annuluses.
%
% Rachel Denison
% July 2009

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initializations
refrate = 60;
slack = 1/refrate/2;

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRESENT TRIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize response measures
dataIndex = 1;
responseTimes(1) = 0;
responseKeyboardEvents(1) = 0;
redKeyWasDown = 0;
blueKeyWasDown = 0;

timeFlipBlank = GetSecs;

% Display the rivalry item sequence
for item = 1:length(tex)

    imagetex = tex(item);

    % Draw images
    Screen('DrawTexture', window, imagetex);
    timeFlipImage = Screen('Flip', window, (timeFlipBlank + blankDuration - slack));

    if item == length(tex) % if the last rivalry item
        % Play a sound? Do nothing?
    else
        % Draw blank
        Screen('DrawTexture', window, blanktex);
        timeFlipBlank = Screen('Flip', window, (timeFlipImage + itemDuration - slack));
    end

end % for

% Check for continuous response to final rivalry display
tic % start timer
while GetSecs < timeFlipImage + responseDuration - slack
    
    WaitSecs(.01);

    %  Check the Subject Responses
    [ keyIsDown, seconds, keyCode ] = KbCheck(devNums.Keypad); % Check the state of the keyboard.

    redKeyIsNowDown =  isequal(redKeyCode, (redKeyCode & keyCode));
    blueKeyIsNowDown =  isequal(blueKeyCode, (blueKeyCode & keyCode));

    if (~redKeyWasDown) && redKeyIsNowDown
%        display ('You just PRESSED the RED key');
        redKeyWasDown = 1;
        responseTimes(dataIndex) = toc;
        responseKeyboardEvents(dataIndex) = 1;
        dataIndex = dataIndex +1;
    elseif redKeyWasDown && ~redKeyIsNowDown
%        display ('You just RELEASED the RED key');
        redKeyWasDown = 0;
        responseTimes(dataIndex) = toc;
        responseKeyboardEvents(dataIndex) = 2;
        dataIndex = dataIndex +1;

    elseif (~blueKeyWasDown) && blueKeyIsNowDown
%        display ('You just PRESSED the BLUE key');
        blueKeyWasDown = 1;
        responseTimes(dataIndex) = toc;
        responseKeyboardEvents(dataIndex) = 3;
        dataIndex = dataIndex +1;
    elseif blueKeyWasDown && ~blueKeyIsNowDown
%        display ('You just RELEASED the BLUE key');
        blueKeyWasDown = 0;
        responseTimes(dataIndex) = toc;
        responseKeyboardEvents(dataIndex) = 4;
        dataIndex = dataIndex +1;

    end %if

end

% mark the end of the response duration in case key is still down when
% the response duration ends
responseTimes(dataIndex) = toc;
responseKeyboardEvents(dataIndex) = 99;
dataIndex = dataIndex + 1;

% make sure we don't leave a lingering image
Screen('DrawTexture', window, blanktex);
Screen('Flip', window);

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
% Screen('Close');



