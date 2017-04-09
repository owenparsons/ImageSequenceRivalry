function rd_analyzePostTestImageSequenceRivalry(subject)
% rd_analyzePostTestImageSequenceRivalry(subject)

% -----------------------
% user-defined
% -----------------------
% subject = 1;
session = 1;

plotfigs = 1; % 1 for on, 0 for off
savefigs = 1; % 1 for on, 0 for off
savedata = 1; % 1 for on, 0 for off

plotByImSeq = 0;

keys = [89 90]; % 89 for 1, 90 for 2

filebase = sprintf('s%02d_run%02d_PostTestImageSequenceRivalry_', subject, session);
savefile = [filebase 'a.mat']; % analyzed (rd_analyzeIOSRivalry)
savepath = (['analysis/' savefile]);
figfiledir = 'figures/';

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

% ----------------------------------------------------------------
% find accuracy and response time by sequence and sequence group type
% ----------------------------------------------------------------
numSeqTypes = 3;
sizeSeqType = 4;
nAFC = 2;

seqTypeNames = {'trained','categoryMatch','categoryDifferent'};
totals_headers = {'sequence_1','sequence_2','acc','rt'};


for seqType = 1:numSeqTypes
    seqTypeRanges{seqType} = ((seqType-1)*sizeSeqType+1):seqType*sizeSeqType;
end


afcGroupsAccuracyRT = [stim.afcPairingsSequence responseArray.responseAcc responseArray.keyTimes];
groups  = nchoosek(1:numSeqTypes,nAFC);

for seqType = 1:numSeqTypes
    for pos = 1:nAFC
        range = seqTypeRanges{seqType};
        seqInCat = afcGroupsAccuracyRT(:,pos)>=range(1) & afcGroupsAccuracyRT(:,pos)<=range(end);
        totalsSeqType(seqType).seqGroupsAccRT(:,:,pos) = afcGroupsAccuracyRT(seqInCat,:);
    end
end


for seq = 1:numSeqTypes*sizeSeqType
    seqAccRT = [];
    for pos = 1:nAFC
        totalsSeq(seq).seqAccRTByPos(:,:,pos) = afcGroupsAccuracyRT(afcGroupsAccuracyRT(:,pos)==seq,:);
        seqAccRT = [seqAccRT;totalsSeq(seq).seqAccRTByPos(:,:,pos)];
    end
    totalsSeq(seq).seqAccRT(:,:) = seqAccRT;
end


for seq =  1:numSeqTypes*sizeSeqType
    for i = 1:length(totalsSeq(seq).seqAccRT(1,:))-nAFC
        totalsSeq(seq).means(1,i) = nanmean(totalsSeq(seq).seqAccRT(:,nAFC+i));
    end
end


for seq = 1:numSeqTypes*sizeSeqType
    for seqType = 1:numSeqTypes
        if nnz(seqTypeRanges{seqType}==seq)>0
            thisSeqType = seqType;
        end
    end
    
    seqs = 1:numSeqTypes;
    seqs(seqs ==thisSeqType) = [];
    
    for seqType = seqs
        seqWithGroupsAccRT = [];
        for pos = 1:nAFC
            range = seqTypeRanges{seqType};
            seqInCat = totalsSeq(seq).seqAccRT(:,pos)>=range(1) & totalsSeq(seq).seqAccRT(:,pos)<=range(end);
            totalsSeq(seq).seqWithGroupsAccRTByPos(:,:,seqType,pos) = totalsSeq(seq).seqAccRT(seqInCat,:);
            seqWithGroupsAccRT = [seqWithGroupsAccRT;totalsSeq(seq).seqAccRT(seqInCat,:)];
        end
        totalsSeq(seq).seqWithGroupsAccRT(:,:,seqType) = seqWithGroupsAccRT;
    end
end


for seq = 1:numSeqTypes*sizeSeqType
    for seqType = 1:length(totalsSeq(seq).seqWithGroupsAccRT(1,1,:))
        for i = 1:length(totalsSeq(seq).seqWithGroupsAccRT(1,:,1))-nAFC
            totalsSeq(seq).meansWithGroups(1,i,seqType) = nanmean(totalsSeq(seq).seqWithGroupsAccRT(:,nAFC+i,seqType));
        end
    end
end

for groupType = 1:length(groups)
    permsOfGroup = fliplr(perms(groups(groupType,:))); %%%%%%
    seqGroupsAccRT = [];
    for pos = 1:length(permsOfGroup)
        groupIndex = ones(length(afcGroupsAccuracyRT),1);
        for i = 1:length(permsOfGroup(1,:))
            range = seqTypeRanges{permsOfGroup(pos,i)};  
            groupIndex = groupIndex & afcGroupsAccuracyRT(:,i)>=range(1) & afcGroupsAccuracyRT(:,i)<=range(end);
        end
        totalsGroups(groupType).seqGroupsAccRTByPos(:,:,pos) = afcGroupsAccuracyRT(groupIndex,:);
        seqGroupsAccRT = [seqGroupsAccRT;totalsGroups(groupType).seqGroupsAccRTByPos(:,:,pos)];
    end
    totalsGroups(groupType).seqGroupsAccRT(:,:) = seqGroupsAccRT;
end

for groupType = 1:length(totalsGroups)
    for pos = 1: length(perms(groups(groupType,:)))
        for i = 1:length(totalsGroups(1).seqGroupsAccRTByPos(1,:,pos))-nAFC
            totalsGroups(groupType).meansByPos(1,i,pos) = nanmean(totalsGroups(groupType).seqGroupsAccRTByPos(:,nAFC+i,pos));
        end
    end
    
    for i = 1:length(totalsGroups(1).seqGroupsAccRT(1,:))-nAFC
        totalsGroups(groupType).means(1,i) = nanmean(totalsGroups(groupType).seqGroupsAccRT(:,nAFC+i));
    end
end

% ----------------------------------------------------
% store all the trial info and data in one structure
% ----------------------------------------------------

responseSummary.total = afcGroupsAccuracyRT;
responseSummary.totalsSeq = totalsSeq;
responseSummary.totalsSeqType = totalsSeqType;
responseSummary.totalsGroups = totalsGroups;

responseSummary.whenAnalyzed = datestr(now);

% ---------------------
% plots
% ---------------------
if plotfigs
    for i =1:length(responseSummary.totalsGroups)
        groupMeansData(i,:) = responseSummary.totalsGroups(i).means;
    end
    
    posLabels = {'position 1', 'position 2'};
    groupLabels = {'trained_v_cat-match';'trained_v_cat-diff';'cat-match_v_cat-diff'};
    
    f(1) = figure;
    bar(groupMeansData(:,1));
    set(gca,'XTickLabel',groupLabels)
    xlabel('group type')
    ylabel('proportion correct')
    title(['Accuracy by group type',10,'Subject ' num2str(subject) ', Session ' num2str(session)]);
    
    f(2) = figure;
    bar(groupMeansData(:,2));
    set(gca,'XTickLabel',groupLabels)
    xlabel('group type')
    ylabel('RT (s)')
    title(['Response time by group type',10,'Subject ' num2str(subject) ', Session ' num2str(session)]);
    
    
    for i = 1:length(responseSummary.totalsGroups)
        for pos  = 1:length(responseSummary.totalsGroups(i).meansByPos)
            groupMeansByPosData(pos,:,i) = responseSummary.totalsGroups(i).meansByPos(:,:,pos);
        end
    end
    
    f(3) = figure;
    bar(squeeze(groupMeansByPosData(:,1,:))');
    set(gca,'XTickLabel',groupLabels)
    xlabel('group type')
    ylabel('proportion correct')
    legend(posLabels)
    title(['Accuracy by group type and position',10,'Subject ' num2str(subject) ', Session ' num2str(session)]);
    
    f(4) = figure;
    bar(squeeze(groupMeansByPosData(:,2,:))');
    set(gca,'XTickLabel',groupLabels)
    xlabel('group type')
    ylabel('RT (s)')
    legend(posLabels)
    title(['Response time by group type and position',10,'Subject ' num2str(subject) ', Session ' num2str(session)]);
    
    categoryLabels = {'trained','categoryMatch','categoryDifferent'};
    
    if plotByImSeq
        for seq = 1:numSeqTypes*sizeSeqType
            for seqType = 1:numSeqTypes
                if nnz(seqTypeRanges{seqType}==seq)>0
                    thisSeqType = seqType;
                end
            end
            
            seqs = 1:numSeqTypes;
            seqs(seqs ==thisSeqType) = [];
            
            seqInGroup = zeros(length(groups),1);
            for i = 1:nAFC
                seqInGroup = seqInGroup | groups(:,i) == thisSeqType;
            end
            seqGroups = groups(seqInGroup,:);
            
            for i = 1:length(totalsSeq(seq).seqWithGroupsAccRT(1,:,1))-nAFC
                seqWithGroupMeansData(seq,i) = responseSummary.totalsSeq(seq).meansWithGroups(:,1,seqs(i));
            end
            
            figure
            bar(seqWithGroupMeansData(seq,:));
            set(gca, 'XTickLabel', categoryLabels(seqs))
            xlabel('category type')
            ylabel('proportion correct')
            title(['Accuracy on image sequence ',num2str(seq), ' with other categories',10,'Subject ' num2str(subject) ', Session ' num2str(session)]);
        end
    end
    
end

% for seq = 1:numSeqTypes*sizeSeqType
%     seqInGroup = zeros(length(groups),1);
%     for i = 1:nAFC
%         seqInGroup = seqInGroup | groups(:,i) == thisSeqType;
%     end
%     groups(seqInGroup,:);
% end

% -------------------
% save data
% -------------------
if savedata
    save(savepath, 'responseArray','trialArray', 'stim','responseSummary')
end

% ----------
% save figs
% ----------
figNameExtensions = {'_groupTypeAcc.jpg', ...
    '_groupTypeRT.jpg', ...
    '_groupTypeAccByPos.jpg', ...
    '_groupTypeRTByPos.jpg'};
if savefigs
    for iF = 1:length(f)
        print(f(iF),'-djpeg','-r80',[figfiledir filebase figNameExtensions{iF}])
    end
end

