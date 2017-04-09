% rd_analyzeTestImageSequenceRivalryGroupData.m

subjects = 1:18;
session = 1;
nSubjects = numel(subjects);
fprintf('\n%d subjects\n\n', nSubjects)

plotFigs = 1;
saveFigs = 0;
saveData = 0;

groupStr = sprintf('g1-18_N%d',nSubjects);
figTitle = ['Subjects ' sprintf('%d ', subjects), ', session ' num2str(session)];
typeLabels = {'im-match','im-nonmatch','cat-match','cat-nonmatch'};
typeLabelsEB = {'';'im-match';'';'im-nonmatch';'';'cat-match';'';'cat-nonmatch'}; % for error bars

figdir = 'figures';

for iSubject = 1:nSubjects
    subject = subjects(iSubject);

    % load indiv subject analysis file
    filebase = sprintf('s%02d_run%02d_TestImageSequenceRivalryContResp', subject, session);
    datafile = dir(['analysis/' filebase '_a.mat']);
    try
        datafile = datafile.name;
    catch
        error('More or less than one matching data file! Check subject, session, and collected data files.')
    end
    load(['analysis/' datafile]);
    
    disp(responseSummary.subject)
    
    groupData.propMatching(iSubject,:) = responseSummary.matchEffect.propmatching_mean;
    groupData.propFirstRespMatching(iSubject,:) = responseSummary.matchEffect.propfirstrespmatching_mean;
    groupData.imPropMatching(:,:,iSubject) = responseSummary.imMatchEffect.propmatching;
    groupData.imPropFirstRespMatching(:,:,iSubject) = responseSummary.imMatchEffect.propfirstrespmatching;
end

% group analysis
fieldNames = fields(groupData);
for iField = 1:numel(fieldNames)
    fieldName = fieldNames{iField};
    if strfind(fieldName,'im'), subjectDim = 3; else subjectDim = 1; end
    groupMean.(fieldName) = mean(groupData.(fieldName),subjectDim);
    groupSte.(fieldName) = std(groupData.(fieldName),0,subjectDim)./sqrt(nSubjects);
end

% save data
if saveData
    saveFile = sprintf('analysis/%s_run%02d_TestImageSequenceRivalry_a.mat', groupStr, session);
    timeStamp = datestr(now);
    save(saveFile, 'subjects', 'session', 'groupStr', 'typeLabels', ...
        'typeLabelsEB','groupData','groupMean','groupSte','timeStamp')
end

% plot figs
if plotFigs
    ylims = [.35 .65];
    
    f(1) = figure;
    bar(groupMean.imPropMatching')
    title(figTitle)
    xlabel('Image')
    ylabel('Proportion matching')
    legend(typeLabels,'location','best')
    ylim(ylims)
    
    f(2) = figure;
    bar(groupMean.imPropFirstRespMatching')
    title(figTitle)
    xlabel('Image')
    ylabel('Proportion first response matching')
    legend(typeLabels,'location','best')
    ylim(ylims)
    
    f(3) = figure;
    hold on
    bar(groupMean.propMatching)
    errorbar(groupMean.propMatching, groupSte.propMatching,'k','LineStyle','none')
    title(figTitle)
    set(gca,'XTickLabel',typeLabelsEB)
    ylabel('Proportion matching')
    ylim(ylims)
    
    f(4) = figure;
    hold on
    bar(groupMean.propFirstRespMatching)
    errorbar(groupMean.propFirstRespMatching, groupSte.propFirstRespMatching,'k','LineStyle','none')
    title(figTitle)
    set(gca,'XTickLabel',typeLabelsEB)
    ylabel('Proportion first response matching')
    ylim(ylims)
    
    f(5) = figure;
    hold on
    bar(groupData.propFirstRespMatching)
    title(figTitle)
    xlabel('subject')
    ylabel('Proportion first response matching')
    legend(typeLabels,'location','best')
    
    f(6) = figure;
    nImages = size(groupData.imPropFirstRespMatching,2);
    hold on
    for iIm = 1:nImages
        subplot(nImages,1,iIm)
        bar(squeeze(groupData.imPropFirstRespMatching(:,iIm,:))')
        if iIm == nImages
            xlabel('subject')
            ylabel('Proportion first response matching')
            legend(typeLabels,'location','best')
        end
        title(sprintf('image %d', iIm))
    end
    rd_supertitle(figTitle)
end

% save figs
if saveFigs
    figNameExtensions = {'imPropMatching.jpg', ...
        'imPropFirstRespMatching.jpg', ...
        'propMatching.jpg', ...
        'propFirstRespMatching.jpg', ...
        'indivSubPFRM.jpg', ...
        'indivSubImPFRM.jpg'};
    for iF = 1:length(f)
        figfile = sprintf('%s/%s_run%02d_Test_%s', figdir, groupStr, session, figNameExtensions{iF});
        print(f(iF),'-djpeg','-r80',figfile)
    end
end

% stats
pfrm = groupData.propFirstRespMatching;
% anova2([pfrm(:,1) pfrm(:,3); pfrm(:,2) pfrm(:,4)],nSubjects);
[hIm pIm] = ttest(pfrm(:,1),pfrm(:,2));
[hCat pCat] = ttest(pfrm(:,3),pfrm(:,4));
fprintf('\nImage match vs. non-match: p = %.04f', pIm)
fprintf('\nCategory match vs. non-match: p = %.04f\n', pCat)

imdiff = pfrm(:,2)-pfrm(:,1);
catdiff = pfrm(:,4)-pfrm(:,3);
figure
subplot(2,1,1)
bar(imdiff)
title('imdiff')
subplot(2,1,2)
bar(catdiff)
title('catdiff')

% repeated measures anova
pfrma = [pfrm(:,1); pfrm(:,3); pfrm(:,2); pfrm(:,4)];
s = [1:nSubjects 1:nSubjects 1:nSubjects 1:nSubjects]';
fmatch = [ones(nSubjects*2,1)*1; ones(nSubjects*2,1)*2];
fimcat = [ones(nSubjects,1)*1; ones(nSubjects,1)*2; ...
    ones(nSubjects,1)*1; ones(nSubjects,1)*2];
factnames = {'match','imcat'};
anova = rm_anova2(pfrma, s, fmatch, fimcat, factnames);
disp(anova)

% this does the same thing as rm_anova2 for match effects:
% anovan(pfrma,{s fmatch fimcat},'random',1,'model',2,'varnames',{'subject','matching','imcat'})

%%% calculate effect sizes
% match vs. nonmatch main effect
matchVsNonmatch = mean([imdiff catdiff],2); % for each subject
matchVsNonmatchES = mean(matchVsNonmatch);

% match x imcat interaction
matchXImcat = imdiff - catdiff;
matchXImcatES = mean(matchXImcat);

% image match vs. non-match
imMatchVsNonmatchES = mean(imdiff);

% cat match vs. non-match
catMatchVsNonmatchES = mean(catdiff);

%%% calculate confidence intervals
% 95% confidence intervals = [.025 .975]
tp = 0.975;
msIdx = find(strcmp(anova(1,:),'MS'));
dfIdx = find(strcmp(anova(1,:),'df'));

% match vs. nonmatch main effect
testIdx = find(strcmp(anova(:,1),'match x Subj'));
tcrit = tinv(tp, anova{testIdx,dfIdx});
matchVsNonmatchMOE = tcrit*sqrt(anova{testIdx,msIdx}/nSubjects);
matchVsNonmatchCI = matchVsNonmatchES + matchVsNonmatchMOE*[-1 1];

% match x imcat interaction % is this correct?
testIdx = find(strcmp(anova(:,1),'match x imcat x Subj'));
tcrit = tinv(tp, anova{testIdx,dfIdx});
% matchXImcatMOE = tcrit*sqrt(anova{testIdx,msIdx}/nSubjects);
matchXImcatMOE = tcrit*std(matchXImcat)/sqrt(nSubjects);
matchXImcatCI = matchXImcatES + matchXImcatMOE*[-1 1];

% image match vs. non-match
tcrit = tinv(tp, nSubjects-1);
imMatchVsNonmatchMOE = tcrit*std(imdiff)/sqrt(nSubjects);
imMatchVsNonmatchCI = imMatchVsNonmatchES + imMatchVsNonmatchMOE*[-1 1];

% cat match vs. non-match
tcrit = tinv(tp, nSubjects-1);
catMatchVsNonmatchMOE = tcrit*std(catdiff)/sqrt(nSubjects);
catMatchVsNonmatchCI = catMatchVsNonmatchES + catMatchVsNonmatchMOE*[-1 1];

