% rd_analyzeTestImageSequenceRivalry_ContResp
function rd_analyzeTestImageSequenceRivalry_ContResp(subject, session)

% s = warning('off','MATLAB:divideByZero')

% -----------------------
% user-defined
% -----------------------
% subject = 9;
% session = 9;
disp(fprintf('Subject %d', subject))

plotfigs = 1; % 1 for on, 0 for off
savefigs = 1; % 1 for on, 0 for off
savedata = 1; % 1 for on, 0 for off

keys = [92 93]; % 92 for red, 93 for blue
tints = [1 2]; % 1 for red, 2 for blue

nItemsInUnitSequence = 3;
nImageBs = 4; % = length(TYPES.b.imageFiles)

bConstant = 0;
a1Constant = 100;
a3Constant = 300;
c3Constant = 600;
c4Constant = 700; % rival with d
dConstant = 800;  % category match to b

typeConstantNames = {'b','c3','d','c4'};
typeConstants = [0 600 800 700]; % of the rivalry images
nTypes = length(typeConstants);
matchingTypeConstants = [0 800];
nonMatchingTypeConstants = [600 700];

a1_prediction = 0; 
a3_prediction = 1;
prediction_probs = a3_prediction; 

predictionClasses = {'trained','categoryMatch'};
predictionClassConstants = [bConstant dConstant];

categoryNames = {'man','woman','animal','food','indoor','outdoor'};

start_trial_time = 0;
end_trial_time = 5;
trial_dur = end_trial_time - start_trial_time;

if trial_dur < 5 % expt trial duration is 60 s
    using_full_trial_duration = 0;
else
    using_full_trial_duration = 1;
end

down_events = [1 3];

filebase = sprintf('s%02d_run%02d_TestImageSequenceRivalryContResp', subject, session);
savefile = [filebase '_a.mat']; % analyzed (rd_analyzeIOSRivalry)
savepath = (['analysis/' savefile]);
figsavedir = 'figures/';
figfilebase = sprintf('s%02d_run%02d_Test', subject, session);

% -------------------------------------------------------------------------
% load data (inc. responseArray, trialArray, rivalryPairsSequenceByBlock)
% -------------------------------------------------------------------------
datafile = dir(['data/' filebase '*']);
try
    datafile = datafile.name;
catch
    error('More or less than one matching data file! Check subject, session, and collected data files.')
end
load(['data/' datafile]);

% -------------------------------------------------------------------------
% initialize variables from single sessions
% -------------------------------------------------------------------------
if session ~= 9
    trialArray = stim.trialArray;
    TYPES = stim.TYPES;
end

% ----------------------------------------------------------------
% make trial information lists containing trials from all blocks
% ----------------------------------------------------------------
blocks = 1:size(trialArray,1);
trials_per_block = size(trialArray,2);

trial = 1;
for block = blocks
    for block_trial = 1:trials_per_block

        if ~isempty(trialArray(block, block_trial).image)

            image(trial,:) = trialArray(block, block_trial).image;
            tint(trial,:) = trialArray(block, block_trial).tint;

            category(trial,:) = trialArray(block, block_trial).category;
            category_number(trial,1) = find(strcmp(categoryNames, category(trial,1)));
            category_number(trial,2) = find(strcmp(categoryNames, category(trial,2)));

            image_file(trial,:) = trialArray(block, block_trial).imageFileName;
            
            for side = 1:2
                image_file_number(trial,side) = sscanf(image_file{trial,side},'%*5s %6d %*4s');
            end

            trial = trial+1;

        end

    end
end

% store trial information lists [left right]
trials_presented.image = image;
trials_presented.tint = tint;
trials_presented.category = category;
trials_presented.category_number = category_number;
trials_presented.image_file = image_file;
trials_presented.image_file_number = image_file_number;

% -----------------------
% initializations
% -----------------------
nTrials = length(trials_presented.image)/nItemsInUnitSequence; % trials_presented contains two images for every one response collected

trials_headers = {'trialNumber','leftImage','rightImage','leftImageFileNumber','rightImageFileNumber',...
    'leftTint','rightTint','leftCategoryNum','rightCategoryNum','predictionProb',...
    'totalDurTintChoiceRed','totalDurTintChoiceBlue','meanDurTintChoiceRed','meanDurTintChoiceBlue',...
    'totalDurImageChoiceMatching','totalDurImageChoiceNonMatching','meanDurImageChoiceMatching','meanDurImageChoiceNonMatching',...
    'totalDurLeftEyeDominant','totalDurRightEyeDominant','meanDurLeftEyeDominant','meanDurRightEyeDominant',...
    'firstResponseImageChoiceMatching','firstResponseLeftEyeDominant','firstResponseRightEyeDominant','firstResponseDuration',...
    'firstResponseBlueTint'};

trials = zeros(nTrials, length(trials_headers));

trials(:,1) = 1:nTrials;

% take only the test images
trials(:,2:3) = trials_presented.image(nItemsInUnitSequence:nItemsInUnitSequence:end,:);
trials(:,4:5) = trials_presented.image_file_number(nItemsInUnitSequence:nItemsInUnitSequence:end,:);
trials(:,6:7) = trials_presented.tint(nItemsInUnitSequence:nItemsInUnitSequence:end,:);
trials(:,8:9) = trials_presented.category_number(nItemsInUnitSequence:nItemsInUnitSequence:end,:);

% how much did the preceeding image predict the b image?
prediction_type = floor(trials_presented.image(nItemsInUnitSequence-1:nItemsInUnitSequence:end,1)/100)*100;
prediction_prob = 99*ones(size(prediction_type));
prediction_prob(prediction_type==a1Constant) = a1_prediction;
prediction_prob(prediction_type==a3Constant) = a3_prediction;
if any(prediction_prob==99)
    error('Not all prediction probabilities were assigned!')
end

trials(:,10) = prediction_prob;

% get tints and image types for later mapping of responses
leftTintIndex = find(strcmp(trials_headers,'leftTint'));
rightTintIndex = find(strcmp(trials_headers,'rightTint'));
trials_tints = trials(:,[leftTintIndex rightTintIndex]);

leftImageIndex = find(strcmp(trials_headers,'leftImage'));
rightImageIndex = find(strcmp(trials_headers,'rightImage'));
trials_images = trials(:,[leftImageIndex rightImageIndex]);
trials_image_types = floor(trials_images/100)*100; % in terms of type constants

% --------------------------
% read out data
% --------------------------
trial = 1;
for block = blocks
    for block_trial = nItemsInUnitSequence:nItemsInUnitSequence:trials_per_block % only even image presentations (test images)

        if ~isempty(trialArray(block, block_trial).image)
            ke = responseArray(block, block_trial).keyEvents;
            kt = responseArray(block, block_trial).keyTimes;

            % to look only at first part of trial, "if not using whole trial
            % dur, find the spot where kt exceeds trial dur, and cut off both ke
            % and kt at that point ...
            if ~using_full_trial_duration
                in_time_data_points = find(kt > start_trial_time & kt < end_trial_time);
                kt = kt(in_time_data_points);
                ke = ke(in_time_data_points);
            end

            num_events = length(ke);

            kdur = zeros(1,num_events); % a vector of key durations
            kdurA = zeros(num_events,length(down_events)); % an array of key durations, separated by key held down

            for i = 1:num_events

                event = ke(i);
                time1 = kt(i);

                if ismember(event, down_events)
                    switch event
                        case 1 % RED down
                            up_key = 2;
                        case 3 % BLUE down
                            up_key = 4;
                        otherwise
                            error('Down key not found...')
                    end

                    found_up_key = 0;
                    for j = i:num_events
                        if ke(j) == up_key
                            time2 = kt(j);
                            found_up_key = 1;
                            break
                        end
                    end

                    if found_up_key == 0 % sometimes you won't find an up key, (hopefully) because it is the end of the trial
%                         fprintf('\nUp key was not found for trial %d, event %d.\n', trial, i)
                        if ke(end) == 99 && using_full_trial_duration % make sure end event is coded, and we are looking at the whole trial
                            time2 = kt(end);
%                             fprintf('End of trial time was used instead.\n\n')
                        else
                            time2 = end_trial_time; % could be shorter than actual trial duration
                            fprintf(['End of trial event was not coded ... Used default end of trial time, ' num2str(end_trial_time) ' s.\n'])
                        end
                    end


                    kdur(i) = time2 - time1;
                    kdurA(i, up_key/2) = time2 - time1;


                end % end of if event is a down key

            end % end for num_events

            % report negative kdurs for error checking
            if any(kdur<0)
                fprintf('\n!!! Negative key durations recorded for trial %d !!!\n\n', trial)
            end

            % save kdurA
            responseArray(block, block_trial).keyDurations = kdurA;

            % response durations by TINT
            trials(trial,11:12) = sum(kdurA,1); % total durations

            kdur_red = kdurA(kdurA(:,1)>0,1);
            kdur_blue = kdurA(kdurA(:,2)>0,2);

            trials(trial,13) = mean(kdur_red); % mean durations (might generate div by 0 warning if no responses in that category)
            trials(trial,14) = mean(kdur_blue);

            % trial condition (1=RED/2=BLUE, 1=LEFT/2=RIGHT)
            redTargetSide = find(trials_tints(trial,:)==1);
            blueTargetSide = find(trials_tints(trial,:)==2);
            
            predImageSide = []; pc = 1;
            while isempty(predImageSide)
                pcConstant = predictionClassConstants(pc);
                predImageSide = find(trials_image_types(trial,:)==pcConstant);
                pc = pc+1;
            end
            predImageTint = find(predImageSide==[redTargetSide blueTargetSide]);
            leftTargetTint = find([redTargetSide blueTargetSide]==1);
            rightTargetTint = find([redTargetSide blueTargetSide]==2);

            % Matching predicted image (B image)
            if redTargetSide == predImageSide
                totalDurMatching = sum(kdur_red);
                totalDurNonMatching = sum(kdur_blue);
                meanDurMatching = mean(kdur_red);
                meanDurNonMatching = mean(kdur_blue);
            else % b image is blue
                totalDurMatching = sum(kdur_blue);
                totalDurNonMatching = sum(kdur_red);
                meanDurMatching = mean(kdur_blue);
                meanDurNonMatching = mean(kdur_red);
            end

            trials(trial,15:18) = [totalDurMatching totalDurNonMatching meanDurMatching meanDurNonMatching];

            % Eye dominance
            if redTargetSide == 1 % left eye target is red
                totalDurLeftEyeDominant = sum(kdur_red);
                totalDurRightEyeDominant = sum(kdur_blue);
                meanDurLeftEyeDominant = mean(kdur_red);
                meanDurRightEyeDominant = mean(kdur_blue);
            elseif redTargetSide == 2 % right eye target is red
                totalDurRightEyeDominant = sum(kdur_red);
                totalDurLeftEyeDominant = sum(kdur_blue);
                meanDurRightEyeDominant = mean(kdur_red);
                meanDurLeftEyeDominant = mean(kdur_blue);
            else
                error('Check eye dominance mapping.')
            end

            trials(trial,19:22) = [totalDurLeftEyeDominant totalDurRightEyeDominant meanDurLeftEyeDominant meanDurRightEyeDominant];

            % First response
            first_kdurA = kdurA(1,:);
            firstDur = sum(first_kdurA);
            first_tint_response = find(first_kdurA); % 1 = red, 2 = blue
            firstResponseMatching = first_tint_response==predImageTint;
            firstResponseLeftEyeDominant = leftTargetTint==first_tint_response;
            firstResponseRightEyeDominant = rightTargetTint==first_tint_response;

            trials(trial,23:26) = [firstResponseMatching firstResponseLeftEyeDominant firstResponseRightEyeDominant firstDur];

            if firstDur==0
                trials(trial,27) = NaN;
            else
                trials(trial,27) = first_tint_response==2;
            end
            
            % Update the trial counter
            trial = trial+1;

        end % if ~isempty(trialsArray.image) for this trial
    end
end

% Show missed trials, make all measures nan
missedTrials = find(trials(:,26)==0) % first response duration = 0
trials(missedTrials,15:end) = NaN;

% no catch trials here

% --------------------------
% analyze
% --------------------------
% Organize by specific image (image file) and type image was shown as in a
% given trial (image match, image non-match, category match, category
% non-match)
trialImageNumbers = trials(:,2:3);
trialImageFileNumbers = trials(:,4:5);
imageFileNumbers = unique(trialImageFileNumbers);
for im = 1:length(imageFileNumbers)
    imageFileNumber = imageFileNumbers(im);
    w = trialImageFileNumbers==imageFileNumber;
    trialImageTypesByImageFileNumber(:,im) = sum(trialImageNumbers.*w,2);
end

totals_headers = {'leftImage','rightImage','leftImageFileNumber','rightImageFileNumber', ...
    'totalDurDominant','totalDurSuppressed','meanDurDominant','meanDurSuppressed',...
    'totalDurLeftEyeDominant','totalDurRightEyeDominant','meanDurLeftEyeDominant','meanDurRightEyeDominant',...
    'firstResponseDominant','firstResponseLeftEyeDominant','firstResponseRightEyeDominant','firstResponseDuration',...
    'firstResponseBlueTint'};

firstRespMatchingIdx = find(strcmp(totals_headers,'firstResponseDominant'));

for type = 1:nTypes
    for im = 1:nImageBs
        % select all the trials where a specific image appears as a
        % specific type
        typeConstant = typeConstants(type);
        t = trialImageTypesByImageFileNumber(:,im);
        w_t = t>0;
        tConstant = t - mod(t,100);
        w_tConstant = tConstant==typeConstant;
        w = w_t & w_tConstant;

        if ismember(typeConstant, matchingTypeConstants)
            totals(:,:,im,type) = [trialImageNumbers(w,:) trialImageFileNumbers(w,:) ...
                trials(w,15:27)];
        elseif ismember(typeConstant, nonMatchingTypeConstants)
            totals(:,:,im,type) = [trialImageNumbers(w,:) trialImageFileNumbers(w,:) ...
                trials(w, [16 15 18 17 19:27])];
            
            totals(:,firstRespMatchingIdx,im,type) = 1-totals(:,firstRespMatchingIdx,im,type);
        else
            error('Type constant not found.')
        end
    end
end

totals_all = totals;
clear totals;

% totals is by image
for type = 1:nTypes
    totals(type).all = totals_all(:,:,:,type);
    totals(type).means = squeeze(nanmean(totals(type).all,1))';
    totals(type).stds = squeeze(nanstd(totals(type).all,0,1))';
    totals(type).stes = totals(type).stds/sqrt(size(totals(type).all,1));
    totals(type).propmatching = totals(type).means(:,5)./(totals(type).means(:,5) + totals(type).means(:,6));
    totals(type).meanmatchcontrast = (totals(type).means(:,7)-totals(type).means(:,8))./...
        (totals(type).means(:,7)+totals(type).means(:,8));
    totals(type).proprighteyedom = totals(type).means(:,10)./(totals(type).means(:,9) + totals(type).means(:,10));
    totals(type).propfirstrespmatching = totals(type).means(:,13);
    totals(type).propfirstresprighteye = totals(type).means(:,15);
    totals(type).propfirstrespbluetint = totals(type).means(:,17);
end

% matchEffect is collapsing across images
for type = 1:nTypes
    matchEffect.propmatching_mean(type) = mean(totals(type).propmatching);
    matchEffect.propmatching_ste(type) = std(totals(type).propmatching)/sqrt(nImageBs);
    matchEffect.meanmatchcontrast_mean(type) = mean(totals(type).meanmatchcontrast);
    matchEffect.meanmatchcontrast_ste(type) = std(totals(type).meanmatchcontrast)/sqrt(nImageBs);
    matchEffect.propfirstrespmatching_mean(type) = mean(totals(type).propfirstrespmatching);
    matchEffect.propfirstrespmatching_ste(type) = std(totals(type).propfirstrespmatching)/sqrt(nImageBs);
end

% imTotals is by type
for im = 1:nImageBs
    imTotals(im).all = totals_all(:,:,im,:);
    imTotals(im).means = squeeze(nanmean(imTotals(im).all,1))';
    imTotals(im).stds = squeeze(nanstd(imTotals(im).all,0,1))';
    imTotals(im).stes = imTotals(im).stds/sqrt(size(imTotals(im).all,1));
    imTotals(im).propmatching = imTotals(im).means(:,5)./(imTotals(im).means(:,5) + imTotals(im).means(:,6));
    imTotals(im).meanmatchcontrast = (imTotals(im).means(:,7)-imTotals(im).means(:,8))./...
        (imTotals(im).means(:,7)+imTotals(im).means(:,8));
    imTotals(im).proprighteyedom = imTotals(im).means(:,10)./(imTotals(im).means(:,9) + imTotals(im).means(:,10));
    imTotals(im).propfirstrespmatching = imTotals(im).means(:,13);
    imTotals(im).propfirstresprighteye = imTotals(im).means(:,15);
    imTotals(im).propfirstrespbluetint = imTotals(im).means(:,17);
end

% imMatchEffect is by types and images
imMatchEffect.dim_headers = {'1st dim = type','2nd dim = image'};
for im = 1:nImageBs
    imMatchEffect.propmatching(:,im) = imTotals(im).propmatching;
    imMatchEffect.meanmatchcontrast(:,im) = imTotals(im).meanmatchcontrast;
    imMatchEffect.propfirstrespmatching(:,im) = imTotals(im).propfirstrespmatching;
end

% -----------------------
% initial summary stats
% -----------------------
propRightEyeDomTrials = trials(:,20)./(trials(:,20)+trials(:,19));
propFirstRespRightEyeTrials = trials(:,25); 
propMatchingTrials = trials(:,15)./(trials(:,15)+trials(:,16));
propFirstRespMatchingTrials = trials(:,23);
propFirstRespBlueTintTrials = trials(:,27);

fprintf('\nProportions:\nRightEyeDom FirstRespRightEye Matching FirstRespMatching FirstRespBlueTint\n')
fprintf('%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\t\n\n', nanmean(propRightEyeDomTrials), nanmean(propFirstRespRightEyeTrials),...
    nanmean(propMatchingTrials), nanmean(propFirstRespMatchingTrials), ...
    nanmean(propFirstRespBlueTintTrials))

firstDurs = trials(:,26);
figure
hist(firstDurs)

% --------------------------------
% store the trial info and data
% --------------------------------
responseSummary.subject = subject;
responseSummary.session = session;
responseSummary.nImageBs = nImageBs;
responseSummary.nItemsInUnitSequence = nItemsInUnitSequence;
responseSummary.prediction_probs = prediction_probs;
responseSummary.categoryNames = categoryNames;

responseSummary.types.TYPES = TYPES;
responseSummary.types.typeNames = typeConstantNames;
responseSummary.types.typeConstants = typeConstants;
responseSummary.types.matchingConstants = matchingTypeConstants;
responseSummary.types.nonMatchingConstants = nonMatchingTypeConstants;
responseSummary.types.predictionClasses = predictionClasses;
responseSummary.types.predictionClassConstants = predictionClassConstants;

responseSummary.trials_presented = trials_presented;
responseSummary.trials_headers = trials_headers;
responseSummary.trials = trials;
responseSummary.totals_headers = totals_headers;
responseSummary.totals = totals;
responseSummary.matchEffect = matchEffect;
responseSummary.imTotals = imTotals;
responseSummary.imMatchEffect = imMatchEffect;

responseSummary.whenAnalyzed = datestr(now);

% --------------
% save analysis
% --------------
if savedata
    save(savepath,'trialArray','responseArray','responseSummary')
end

% ----------------
% plot figures
% ----------------
if plotfigs
    
    f(1) = figure;
    rightEyeDomIdx = find(strcmp(trials_headers,'firstResponseRightEyeDominant'));
    scatter(trials(:,1), trials(:,rightEyeDomIdx))
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])
    ylabel('Right eye initial dominance')
    xlabel('Trial number')

    f(2) = figure;
    bar(imMatchEffect.propmatching')
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])
    xlabel('Image')
    ylabel('Proportion matching')
    legend('im-match','im-nonmatch','cat-match','cat-nonmatch','location','best')
    
    f(3) = figure;
    bar(imMatchEffect.propfirstrespmatching')
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])
    xlabel('Image')
    ylabel('Proportion first response matching')
    legend('im-match','im-nonmatch','cat-match','cat-nonmatch','location','best')
    
    f(4) = figure;
    hold on
    bar(matchEffect.propmatching_mean)
    errorbar(matchEffect.propmatching_mean, matchEffect.propmatching_ste,'k','LineStyle','none')
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])
    set(gca,'XTickLabel',{'';'im-match';'';'im-nonmatch';'';'cat-match';'';'cat-nonmatch'})
    ylabel('Proportion matching')

    f(5) = figure;
    hold on
    bar(matchEffect.propfirstrespmatching_mean)
    errorbar(matchEffect.propfirstrespmatching_mean, matchEffect.propfirstrespmatching_ste,'k','LineStyle','none')
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])
    set(gca,'XTickLabel',{'';'im-match';'';'im-nonmatch';'';'cat-match';'';'cat-nonmatch'})
    ylabel('Proportion first response matching')
    
    f(6) = figure;
    blueTintDomIdx = find(strcmp(trials_headers,'firstResponseBlueTint'));
    scatter(trials(:,1), trials(:,blueTintDomIdx))
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])
    ylabel('Blue tint initial dominance')
    xlabel('Trial number')
    
end

% ----------
% save figs
% ----------
figNameExtensions = {'_eyeDom.jpg', ...
                     '_propMatchingIm.jpg', ...
                     '_propFirstRespMatchingIm.jpg', ...
                     '_propMatching.jpg', ...
                     '_propFirstRespMatching.jpg', ...
                     '_blueTintDom.jpg'};

if savefigs
    for iF = 1:length(f)
        print(f(iF),'-djpeg','-r80',[figsavedir figfilebase figNameExtensions{iF}])
    end
end
    
