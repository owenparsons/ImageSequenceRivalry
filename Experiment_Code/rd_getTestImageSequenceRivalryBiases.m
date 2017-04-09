% rd_getTestImageSequenceRivalryBiases.m

subjects = 1:18;
session = 1;
nSubjects = numel(subjects);
fprintf('\n%d subjects\n\n', nSubjects)

groupStr = sprintf('g01-18_N%d',nSubjects);

for iSubject = 1:nSubjects
    subject = subjects(iSubject);

    % load indiv subject analysis file
    filebase = sprintf('s%02d_run%02d_TestImageSequenceRivalryContResp', subject, session);
    datafile = dir(['analysis/Test/' filebase '_a.mat']);
    try
        datafile = datafile.name;
    catch
        error('More or less than one matching data file! Check subject, session, and collected data files.')
    end
    load(['analysis/Test/' datafile]);

    % get right eye dominance
    firstRespRightIdx = strcmp(responseSummary.trials_headers,'firstResponseRightEyeDominant');
    rightEyeDom = responseSummary.trials(:,firstRespRightIdx);
    
    % get right eye tint
    rightEyeTintIdx = strcmp(responseSummary.trials_headers,'rightTint');
    rightEyeTint = responseSummary.trials(:,rightEyeTintIdx);
    
    % get left and right eye images
    leftEyeImIdx = strcmp(responseSummary.trials_headers,'leftImageFileNumber');
    rightEyeImIdx = strcmp(responseSummary.trials_headers,'rightImageFileNumber');
    leftEyeIm = responseSummary.trials(:,leftEyeImIdx);
    rightEyeIm = responseSummary.trials(:,rightEyeImIdx);
    
    for iTrial = 1:length(rightEyeDom)
        if rightEyeDom(iTrial)==1
            tintDom(iTrial,1) = rightEyeTint(iTrial);
            imDom(iTrial,1) = rightEyeIm(iTrial);
        elseif rightEyeDom(iTrial)==0
            tintDom(iTrial,1) = 3-rightEyeTint(iTrial);
            imDom(iTrial,1) = leftEyeIm(iTrial);
        else
            tintDom(iTrial,1) = NaN;
            imDom(iTrial,1) = NaN;
        end
    end
        
    firstRespRightEye(iSubject) = nanmean(rightEyeDom);
    firstRespBlueTint(iSubject) = nanmean(double(tintDom==2));
    
    images = [45 297 312 794];
    for iIm = 1:numel(images)
        firstRespIm(iSubject,iIm) = nanmean(double(imDom==images(iIm)));
    end
end

% plot
figure
bar(firstRespRightEye)

figure
bar(firstRespBlueTint)

figure
bar(firstRespIm)

% save
analysisFile = sprintf('analysis/Test/%s_run%02d_TestImageSequenceBiases.mat', groupStr, session);
save(analysisFile,'subjects','session','rightEyeDom','tintDom','imDom','firstRespRightEye','firstRespBlueTint','firstRespIm','images')
    
    
