% rd_analyzeTrainImageSequenceRivalryGroupData.m

subjects = 1:18;
session = 1;
nSubjects = numel(subjects);
fprintf('\n%d subjects\n\n', nSubjects)

plotFigs = 1;
saveFigs = 0;
saveData = 0;

groupStr = sprintf('g1-18_N%d',nSubjects);
figTitle = ['Subjects ' sprintf('%d ', subjects), ', session ' num2str(session)];

figdir = 'figures';

for iSubject = 1:nSubjects
    subject = subjects(iSubject);

    % load indiv subject analysis file
    filebase = sprintf('s%02d_run%02d_TrainImageSequenceRivalry', subject, session);
    datafile = dir(['analysis/' filebase '_a.mat']);
    try
        datafile = datafile.name;
    catch
        error('More or less than one matching data file! Check subject, session, and collected data files.')
    end
    load(['analysis/' datafile]);
    
    disp(subjects(iSubject))
    
    groupData.acc(:,:,iSubject) = responseSummary.totals.accMeans;
    groupData.rt(:,:,iSubject) = responseSummary.totals.rtMeans;
end

groupMean.acc = mean(groupData.acc,3);
groupMean.rt = mean(groupData.rt,3);

groupSte.acc = std(groupData.acc,0,3)./sqrt(nSubjects);
groupSte.rt = std(groupData.rt,0,3)./sqrt(nSubjects);

% save data
if saveData
    saveFile = sprintf('analysis/%s_run%02d_TrainImageSequenceRivalry_a.mat', groupStr, session);
    timeStamp = datestr(now);
    save(saveFile, 'subjects', 'session', 'groupStr', ...
        'groupData','groupMean','groupSte','timeStamp')
end

% figures
if plotFigs
    blockLabels = {'block 1','block 2','block 3','block 4','block 5'};
    xlims = [.8 3.2];
    
    f(1) = figure;
    errorbar(groupMean.acc, groupSte.acc);
    set(gca,'XTick',1:3);
    xlabel('Position in image sequence')
    ylabel('Accuracy (proportion correct)')
    legend(blockLabels,'Location','best')
    title([groupStr ', Session ' num2str(session)]);
    
    f(2) = figure;
    errorbar(groupMean.rt, groupSte.rt);
    set(gca,'XTick',1:3)
    xlabel('Position in image sequence')
    ylabel('RT (s)')
    legend(blockLabels,'Location','best')
    title([groupStr ', Session ' num2str(session)]);
end

% save figs
if saveFigs
    figNameExtensions = {'acc.jpg', 'rt.jpg'};
    for iF = 1:length(f)
        figfile = sprintf('%s/%s_run%02d_Train_%s', figdir, groupStr, session, figNameExtensions{iF});
        print(f(iF),'-djpeg','-r80',figfile)
    end
end

% extra stats
acc = reshape(groupData.acc, [size(groupData.acc,1)*size(groupData.acc,2) nSubjects]);
accIndiv = mean(acc,1);
accMean = mean(accIndiv)
accStd = std(accIndiv)
[h p ci stat] = ttest(accIndiv - 1/12);
