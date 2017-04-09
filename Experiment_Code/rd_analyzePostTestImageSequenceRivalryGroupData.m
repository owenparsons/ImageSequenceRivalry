% rd_analyzePostTestImageSequenceRivalryGroupData.m

subjects = 1:18;
session = 1;
nSubjects = numel(subjects);
fprintf('\n%d subjects\n\n', nSubjects)

saveFigs = 0;
saveData = 0;

groupStr = sprintf('g1-18_N%d',nSubjects);
figTitle = ['Subjects ' sprintf('%d ', subjects), ', session ' num2str(session)];

figdir = 'figures';

groupLabels = {'trained_v_cat-match';'trained_v_cat-diff';'cat-match_v_cat-diff'};

for iSubject = 1:nSubjects
    subject = subjects(iSubject);

    % load indiv subject analysis file
    filebase = sprintf('s%02d_run%02d_PostTestImageSequenceRivalry', subject, session);
    datafile = dir(['analysis/' filebase '_a.mat']);
    try
        datafile = datafile.name;
    catch
        error('More or less than one matching data file! Check subject, session, and collected data files.')
    end
    load(['analysis/' datafile]);
    
    disp(subject)
    
    groupMeansData = [];
    for iGroup=1:length(responseSummary.totalsGroups)
        groupMeansData(iGroup,:) = ...
            responseSummary.totalsGroups(iGroup).means;
    end
    
    groupData.acc(iSubject,:) = groupMeansData(:,1)';
    groupData.rt(iSubject,:) = groupMeansData(:,2)';
end

groupMeans.acc = mean(groupData.acc);
groupMeans.rt = mean(groupData.rt);

groupSte.acc = std(groupData.acc)./sqrt(nSubjects);
groupSte.rt = std(groupData.rt)./sqrt(nSubjects);

% save data
if saveData
    saveFile = sprintf('analysis/%s_run%02d_PostTestImageSequenceRivalry_a.mat', groupStr, session);
    timeStamp = datestr(now);
    save(saveFile, 'subjects', 'session', 'groupStr', 'groupLabels', ...
        'groupData','groupMeans','groupSte','timeStamp')
end

% figures
f(1) = figure;
hold on
bar(groupMeans.acc);
errorbar(groupMeans.acc, groupSte.acc,'k','LineStyle','none');
set(gca,'XTick',1:numel(groupLabels));
set(gca,'XTickLabel',groupLabels)
xlabel('group type')
ylabel('proportion correct')
title(['Accuracy by group type', 10, groupStr ', Session ' num2str(session)]);

f(2) = figure;
hold on
bar(groupMeans.rt);
errorbar(groupMeans.rt, groupSte.rt,'k','LineStyle','none');
set(gca,'XTick',1:numel(groupLabels));
set(gca,'XTickLabel',groupLabels)
xlabel('group type')
ylabel('RT (s)')
title(['Response time by group type', 10, groupStr ', Session ' num2str(session)]);

% save figs
if saveFigs
    figNameExtensions = {'acc.jpg', 'rt.jpg'};
    for iF = 1:length(f)
        figfile = sprintf('%s/%s_run%02d_PostTest_%s', figdir, groupStr, session, figNameExtensions{iF});
        print(f(iF),'-djpeg','-r80',figfile)
    end
end

% stats 
% image learning vs. category learning
imLearnVsCatLearn = groupData.acc(:,3)-groupData.acc(:,1);
[h p ci stat] = ttest(imLearnVsCatLearn);

% confidence intervals
tp = 0.975; % 95% confidence interval
tcrit = tinv(tp, nSubjects-1);
accMOE = tcrit*std(groupData.acc)./sqrt(nSubjects);
accCI = repmat(groupMeans.acc,2,1) + ([-1 1])'*accMOE;

imLearnVsCatLearnES = mean(imLearnVsCatLearn);
imLearnVsCatLearnMOE = tcrit*std(imLearnVsCatLearn)/sqrt(nSubjects);
imLearnVsCatLearnCI = imLearnVsCatLearnES + [-1 1]*imLearnVsCatLearnMOE;

