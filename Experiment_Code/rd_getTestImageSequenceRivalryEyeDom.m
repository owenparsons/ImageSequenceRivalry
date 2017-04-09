% rd_getTestImageSequenceRivalryEyeDom.m

subjects = 1:18;
session = 1;
nSubjects = numel(subjects);
fprintf('\n%d subjects\n\n', nSubjects)

groupStr = sprintf('g1-18_N%d',nSubjects);

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

    % get eye dominance
    firstRespRightIdx = strcmp(responseSummary.trials_headers,'firstResponseRightEyeDominant');

    firstRespRightEye(iSubject) = ...
        nanmean(responseSummary.trials(:,firstRespRightIdx));
end

% save
analysisFile = sprintf('analysis/Test/%s_run%02d_TestImageSequenceEyeDom.mat', groupStr, session);
save(analysisFile,'subjects','session','firstRespRightEye')
    
    
