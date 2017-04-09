function rd_testImageSequenceRivalry_ContResp

% Test pairs of rivalry images (b & c3) following sequences (z3-a3) in both
% eyes that predict b. The same images are either predicted (b) or
% non-predicted (c3) in two different image pairs. Tests whether you are 
% more likely to see the b image when it is preceded by a predictive 
% sequence.
%
% Also test category-match rivalry pairs (d & c4), where d has the same 
% category as b. The d & c4 pair also functions as a b & c3 pair in another
% image set.
%
% Subjects report which image they see on each rivalry trial by reporting 
% the image tint color (reddish or blueish).
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

typeFile = 'TYPES_20110325_6Cat.mat'; % 4 hand-picked image sets

% set keypad device numbers
devNums.Keypad = -1;

% sound on?
sound_on = 1; % 1 for on, 0 for off

% training topups between each block?
training_topups = 0; % 1 for on, 0 for off

% run parameters
nImageBs = 4; 
nRepsB = 1; % determines the number of trials **for now, only works when nRepsB = 1**
repsPerSubstack = 1; % should be <= nRepsB
nBlocks = 3; % do all the nReps in every block
imageDuration = 0.85; % seconds -- multiple of refresh, please!
blankDuration = 0;
responseDuration = 5; 

imageTypeNames = {'b','a1','a2','a3','c1','c2','c3','c4','d','z1','z2','z3'}'; 
lowerbounds = [(0:100:800) (1100:100:1300)]';
upperbounds = lowerbounds + 101;

tintColors{1} = [1.5 1 1]; % red tint
tintColors{2} = [1 1 1.5]; % blue tint
tintColors{3} = [1 1 1]; % no tint

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

fprintf('Welcome to the Predictive Rivalry Study\n\n');
fprintf('Be sure to turn manually turn off console monitor before testing!\n\n')

KbName('UnifyKeyNames');
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Keyboard mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% red tint key
redKey = '4'; % this is our default key  

redKeyCode (1:256) = 0;
redKeyCode (KbName (redKey)) = 1; % creates the keyCode vector

response = 1;
while ~isempty (response)
    fprintf('The key assigned for RED TINT is: %s \n', KbName(redKeyCode));
    response = input ('Hit "enter" to keep this value or a new key to change it.\n','s');
    if ~isempty (response) && str2num(response)<10 % make sure response key is on the key pad
        redKey = response; 
        redKeyCode (1:256) = 0;
        redKeyCode (KbName (redKey)) = 1; % creates the keyCode vector
    end
end

redKeyNumber = find(redKeyCode);

% blue tint key
blueKey = '5'; % this is our default key  

blueKeyCode (1:256) = 0;
blueKeyCode (KbName (blueKey)) = 1; % creates the keyCode vector

response = 1;
while ~isempty (response)
    fprintf('The key assigned for BLUE TINT is: %s \n', KbName(blueKeyCode));
    response = input ('Hit "enter" to keep this value or a new key to change it.\n','s');
    if ~isempty (response) && str2num(response)<10
        blueKey = response; 
        blueKeyCode (1:256) = 0;
        blueKeyCode (KbName (blueKey)) = 1; % creates the keyCode vector
    end
end

blueKeyNumber = find(blueKeyCode);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect subject and session info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjectNumber = str2double(input('\nPlease input the subject number: ','s'));
runNumber = str2double(input('\nPlease input the run number: ','s'));
subjectID = sprintf('s%02d_run%02d', subjectNumber, runNumber);
timeStamp = datestr(now);

% sequenceFileBase = [imageSequenceDirectoryPath subjectID '_TestImageSequenceRivalry_imageSequence'];

% Show the gray background, return timestamp of flip in 'vbl'
Screen('FillRect',window, gray);
vbl = Screen('Flip', window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate or load the image presentation order for all blocks & load image
% file lists by type (TYPES). types are b, a1, a3, etc.
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
expt.nImageBs = nImageBs;
expt.nRepsB = nRepsB;
expt.nBlocks = nBlocks;
expt.imageDuration = imageDuration;
expt.blankDuration = blankDuration;
expt.responseDuration = responseDuration;
expt.imageTypeNames = imageTypeNames;
expt.lowerbounds = lowerbounds;
expt.upperbounds = upperbounds;
expt.tintColors = tintColors;
expt.keyNumbers = [redKeyNumber blueKeyNumber];

stim.TYPES = TYPES;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataFileName = [dataDirectoryPath subjectID '_TestImageSequenceRivalryContResp_', datestr(now,'ddmmmyyyy')];

for block = 1:nBlocks
    
    if training_topups
        fprintf('We are training!\n')
        rd_trainImageSequenceRivalry
    end
    
    DrawFormattedText(window, 'Preparing stimuli ...', 0, 'center', [255 255 255]);
    Screen('Flip', window);
    tic
    
    % make image sequence for this block
    rivalryPairsSequence = rd_makeTestImageSequence(nImageBs, nRepsB, repsPerSubstack);
%     save(sprintf('%s_block%02d', sequenceFileBase, block),'subjectID', 'block', 'timeStamp', 'rivalryPairsSequence');

    rivalryPairsSequenceKey = {'image sequence (1 & 2)','side sequence (1 & 2)','tint sequence (1 & 2)'};
    
    % get image, tint, and side sequences for this block
    imageSequence = rivalryPairsSequence(:, 1:2);
    sideSequence = rivalryPairsSequence(:, 3:4);
    tintSequence = rivalryPairsSequence(:, 5:6);

    clear imageTextures imagetexs
    
    % build image texture sequence
    for trial = 1:length(imageSequence)

        for i = 1:2 % [B C3] or [D C4]
            
            side = sideSequence(trial, i); % side 1 for left, 2 for right            
            image(side) = imageSequence(trial, i);
            tint(side) = tintSequence(trial, i);

            imageType{side} = imageTypeNames{(image(side) > lowerbounds) & (image(side) < upperbounds)};
            imageNumber(side) = rem(image(side), 100);
            imageFileName{side} = TYPES.(imageType{side}).imageFiles(imageNumber(side)).name;

            imageFilePath{side} = [imageDirectoryPath imageFileName{side}];
            
            category{side} = TYPES.(imageType{side}).categories{imageNumber(side)};
            
        end
        
        % store images and tints as they appeared (left or right)
        imagesBySide(trial,:,block) = image;
        tintsBySide(trial,:,block) = tint;
        
        % store everything (each item will have two values [left right])
        trialArray(block, trial).image = image;
        trialArray(block, trial).tint = tint;
        trialArray(block, trial).imageType = imageType;
        trialArray(block, trial).imageNumber = imageNumber;
        trialArray(block, trial).imageFileName = imageFileName;
        trialArray(block, trial).category = category;
        
        % arguments are in left-right order: 1=left, 2=right
        [imageTexture imagetex] = rd_makeRivalryImageTextureRGB(window, imageFilePath{1}, imageFilePath{2}, tintColors{tint(1)}, tintColors{tint(2)});
        
        imageTextures{trial} = imageTexture; % a stack of image matrices (eg. imagesc(imageTexture))
        imagetexs(trial,1) = imagetex; % a list of texture pointers to said image matrices
        
    end
    
    % store image sequence
    rivalryPairsSequenceByBlock(:,:,block) = rivalryPairsSequence;
    stim.sequence = rivalryPairsSequenceByBlock;
    stim.sequence_key = rivalryPairsSequenceKey;
    stim.imagesBySide = imagesBySide;
    stim.tintsBySide = tintsBySide;
    stim.trialArray = trialArray;
    
    % present alignment targets and wait for a keypress
    toc
    presentAlignmentTargets(window, devNums);  

    % make a beep to say we're ready
    if sound_on
        sound (soundvector, 8000); 
    end
    
    for trial = 3:3:length(imageSequence) % responseArray contains response to the third image in each triplet        
        if trial==3
            datestr(now)
        end
        
        imagetexsnow = imagetexs(trial-2:trial,1);
        % present image sequence for this block
        [responseArray(block, trial).keyTimes responseArray(block, trial).keyEvents] = ...
            rd_presentRivalryImageSequence_ContResp(window, imagetexsnow, ...
                imageDuration, blankDuration, responseDuration, ...
                redKeyCode, blueKeyCode, devNums);

        % save data
        save(dataFileName, 'subjectID', 'timeStamp', 'responseArray', 'stim', 'expt');
    end

    % release all textures and offscreen windows
    Screen('Close');    
    
    datestr(now)
    
    % some report of performance
    redKeyDown = 1; 
    blueKeyDown = 3;
    for i = 3:3:size(responseArray,2)
        if ~isempty(responseArray(block,i).keyEvents);
            firstEvents(i) = responseArray(block,i).keyEvents(1);
        end
    end
    redProp = nnz(firstEvents==redKeyDown)/nnz(firstEvents);
    blueProp = nnz(firstEvents==blueKeyDown)/nnz(firstEvents);
    
    DrawFormattedText(window, ['Red responses: ' num2str(round(redProp*100)) '%\n\nBlue responses: ' num2str(round(blueProp*100)) '%'], 0, 'center', [255 255 255]);
    Screen('Flip', window);

    WaitSecs(3);

end % end block

% Clean up
Screen('CloseAll');  
ShowCursor;










