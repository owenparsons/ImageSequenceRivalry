function rd_postTestImageSequenceRivalry

% 2-interval forced choice familiarity test for image sequences that were
% seen during the training portion of the experiment vs. image sequence
% foils that were unseen.
%
% Foils can have the same category sequence but different image sequence
% than training sequences, or they can have different images and different
% categories.
%
% Subjects press a button to say whether the more familiar sequence
% was presented first or second, on each trial.
%
% Rachel Denison
% March 2011

% Start by removing anything left over in the memory:
clear all;
close all;

location = input('location (laptop, testingRoom): ','s');

global pixelsPerDegree;
global spaceBetweenMultiplier;

% -------------------------------------------------------------------------
% User-defined values, might vary by testing room. Check these before running.
% -------------------------------------------------------------------------
% Set up paths. Depends on testing location.
% data path
dataDirectoryPath = 'data/';
% displayParams file path
targetDisplayPath = 'displays/';
% image path
imageDirectoryPath = 'images/';
% image file names lists path
typeListDirectoryPath = 'image_type_lists/';

% displayParams file
targetDisplayName = 'Minor_582J_rivalry'; % 60 Hz frame rate

typeFile = 'TYPES_20110331_PostTest.mat'; % 4 hand-picked image sets

% set keypad device numbers
devNums.Keypad = -1;

% sound on?
sound_on = 1; % 1 for on, 0 for off

% response keys
responseKeys = {'1','2'}; % these are our default keys
keyNames = {'FIRST','SECOND'};

% run parameters
nItemsInUnitSequence = 3; % triplets
nImageBs = 4;
nReps = 1; % determines the number of trials
nBlocks = 1; % do all the nReps in every block
imageDuration = 0.85; % seconds -- multiple of refresh, please!
trialDuration = 0.85;
interSequenceWaitTime = 1;
responseDuration = 3;

imageTypeNames = {'b','a1','a2','a3','c1','c2','c3','c4','d','z1','z2','z3'}';
lowerbounds = [(0:100:800) (1100:100:1300)]';
upperbounds = lowerbounds + 101;

% Sound for starting trials
v = 1:2000;
soundvector = 0.25 * sin(2*pi*v/30); %a nice beep at 2kH samp freq

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spaceBetweenMultiplier = 3;

Screen('Preference', 'VisualDebuglevel', 3); % replaces startup screen with black display
screenNumber = max(Screen('Screens'));

window = Screen('OpenWindow', screenNumber);
black = BlackIndex(window);  % Retrieves the CLUT color code for black.
white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
gray = (black + white) / 2;  % Computes the CLUT color code for gray.

Screen('TextSize', window, 60);

switch location
    case 'testingRoom'
        targetDisplay = loadDisplayParams_OSX('path',targetDisplayPath,'displayName',targetDisplayName,'cmapDepth',8);
        pixelsPerDegree = angle2pix(targetDisplay, 1); % number of pixels in one degree of visual angle
        Screen('LoadNormalizedGammaTable', targetDisplay.screenNumber, targetDisplay.gammaTable);
    otherwise
        fprintf('\nNot setting pixels per degree or loading gamma table.\n\n')
end

fprintf('Welcome to the Image Sequence Rivalry Study\n\n');
fprintf('Be sure to turn manually turn off console monitor before testing!\n\n')

KbName('UnifyKeyNames');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Keyboard mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for key = 1:length(responseKeys)
    keyCode (1:256) = 0;
    keyCode (KbName (responseKeys(key))) = 1; % creates the keyCode vector

    response = 1;
    while ~isempty (response)
        fprintf('The key assigned for %s is: %s \n', keyNames{key}, KbName(keyCode));
        response = input ('Hit "enter" to keep this value or a new key to change it.\n','s');
        if ~isempty(response) && str2num(response)<10 % make sure response key is on the key pad
            key = response;
            keyCode (1:256) = 0;
            keyCode (KbName (key)) = 1; % creates the keyCode vector
        end
    end

    keyNumbers(:,key) = find(keyCode);
end

fprintf('Key numbers: %d %d\n\n', keyNumbers)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect subject and session info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjectNumber = str2double(input('\nPlease input the subject number: ','s'));
runNumber = str2double(input('\nPlease input the run number: ','s'));
subjectID = sprintf('s%02d_run%02d', subjectNumber, runNumber);
timeStamp = datestr(now);

% Show the gray background, return timestamp of flip in 'vbl'
Screen('FillRect',window, gray);
vbl = Screen('Flip', window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load image file lists by type (TYPES). types are b, a1, a3, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load TYPES
typeListFileName = [typeListDirectoryPath typeFile];
load(typeListFileName);

% or make TYPES now:
% TYPES = rd_imageCat2TypeTransform(nImageBs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store experiment parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expt.timeStamp = timeStamp;
expt.subject = subjectNumber;
expt.run = runNumber;
expt.nItemsInUnitSequence = nItemsInUnitSequence;
expt.nImageBs = nImageBs;
expt.nReps = nReps;
expt.nBlocks = nBlocks;
expt.imageDuration = imageDuration;
expt.trialDuration = trialDuration;
expt.interSequenceWaitTime = interSequenceWaitTime;
expt.responseDuration = responseDuration;
expt.imageTypeNames = imageTypeNames;
expt.lowerbounds = lowerbounds;
expt.upperbounds = upperbounds;
expt.keyNames = keyNames;
expt.keyNumbers = keyNumbers;

stim.TYPES = TYPES;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataFileName = [dataDirectoryPath subjectID '_PostTestImageSequenceRivalry_', datestr(now,'ddmmmyyyy')];

for block = 1:nBlocks

    DrawFormattedText(window, 'Preparing stimuli ...', 0, 'center', [255 255 255]);
    Screen('Flip', window);
    tic

    % generate sequence pairings
    %** nReps comes in here **%
    % 4 trained, 4 category match foils, 4 category different foils
    a = fullfact([4 4]);
    a(:,2) = a(:,2) + 4;
    b = a;
    b(:,2) = b(:,2) + 4;
    c = a + 4;
    afcPairings1 = [a; b; c]; % [first presentation, second presentation]
    afcPairings2 = fliplr(afcPairings1); % [first presentation, second presentation]
    afcPairings = [afcPairings1; afcPairings2];
    
    nAfcTrials = size(afcPairings,1);

    % more familiar sequence is on left in first half, right in second half
    correctIntervals = [ones(nAfcTrials/2,1); 2*ones(nAfcTrials/2,1)];
    
    % replicate nrep times
    afcPairings = repmat(afcPairings,nReps,1);
    correctIntervals = repmat(correctIntervals,nReps,1);

    % randomize order
    w = randperm(nAfcTrials);
    afcPairingsSequence = afcPairings(w,:);
    correctIntervalsSequence = correctIntervals(w,:); 
    
    % print run start time
    datestr(now)

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Preload all textures
    %%%%%%%%%%%%%%%%%%%%%%%%
    for afcTrial = 1:nAfcTrials

        afcPairing = afcPairingsSequence(afcTrial,:);
        correctInterval = correctIntervalsSequence(afcTrial);

        % make image sequence for this afcTrial
        imageSequence = rd_makePostTestImageSequence(afcPairing);

        % get category labels for this image sequence
        imageSequenceCategories = getCategoryLabels(imageSequence, TYPES);

        clear imageTextures imagetexs

        % build image texture sequence
        for trial = 1:length(imageSequence)

            image = imageSequence(trial);
            imageType = imageTypeNames{(image > lowerbounds) & (image < upperbounds)};
            imageNumber = rem(image, 100);
            imageFileName = TYPES.(imageType).imageFiles(imageNumber).name;

            imageFilePathLeft = [imageDirectoryPath imageFileName];
            imageFilePathRight = imageFilePathLeft; % same image on both sides

            [imageTexture imagetex] = rd_makeRivalryImageTextureRGB(window, imageFilePathLeft, imageFilePathRight);

            imageTextures{trial} = imageTexture; % a stack of image matrices (eg. imagesc(imageTexture))
            imagetexsAll(trial, afcTrial) = imagetex; % a list of texture pointers to said image matrices

            % store information for each trial
            trialArray(block, afcTrial, trial).afcPairing = afcPairing;
            trialArray(block, afcTrial, trial).correctInterval = correctInterval;
            trialArray(block, afcTrial, trial).image = image;
            trialArray(block, afcTrial, trial).imageType = imageType;
            trialArray(block, afcTrial, trial).imageNumber = imageNumber;
            trialArray(block, afcTrial, trial).imageFileName = imageFileName;
            trialArray(block, afcTrial, trial).category = imageSequenceCategories(trial);

        end

        % store image sequence and categories
        imageSequenceByBlock(:,afcTrial,block) = imageSequence;
        imageSequenceCategoriesByBlock(:,afcTrial,block) = imageSequenceCategories;

    end % end afc trials

    % store in stim
    stim.afcPairingsSequence = afcPairingsSequence;
    stim.correctIntervalsSequence = correctIntervalsSequence;
    stim.imageSequences = imageSequenceByBlock;
    stim.imageCategories = imageSequenceCategoriesByBlock;

    toc
    % Make a beep to say we're ready
    if sound_on
        sound (soundvector, 8000);
    end
    
    %%%%%%%%%%%%%%%%%%
    % Present trials
    %%%%%%%%%%%%%%%%%%
    for afcTrial = 1:nAfcTrials

        % get texs and correct response
        imagetexs = imagetexsAll(:,afcTrial);
        correctInterval = correctIntervalsSequence(afcTrial);

        % present alignment targets and wait for a keypress
        WaitSecs(0.2); % try to avoid picking up last key press
        presentAlignmentTargets(window, devNums);

        % present image sequence for this block
        [responseArray(block).keyTimes(afcTrial,1) ...
            responseArray(block).keyEvents(afcTrial,1) ...
            responseArray(block).responseAcc(afcTrial,1)] = ...
            rd_presentRivalryPostTestImageSequence(window, imagetexs, ...
            imageDuration, trialDuration, interSequenceWaitTime, responseDuration, ...
            nItemsInUnitSequence, correctInterval, keyNumbers, devNums);

        % save data
        save(dataFileName, 'subjectID', 'timeStamp', 'responseArray', 'trialArray', 'stim', 'expt');

    end % end afc trials

    DrawFormattedText(window, ...
        'Block completed\n\nThank you!', 0, 'center', [255 255 255]);
    Screen('Flip', window);

    WaitSecs(3);
    datestr(now)

end % end block

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('topup_run','var')
    Screen('CloseAll');
    ShowCursor;
end
