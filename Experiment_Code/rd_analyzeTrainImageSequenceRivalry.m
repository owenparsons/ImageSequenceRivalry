function rd_analyzeTrainImageSequenceRivalry(subject)
% rd_analyzeTrainImageSequenceRivalry(subject)

% --------------
% user-defined
% --------------
% subject = 1;
session = 1;

plotfigs = 1; % 1 for on, 0 for off
savefigs = 1; % 1 for on, 0 for off
savedata = 1; % 1 for on, 0 for off

nImageBs = 4;

bConstant = 0;
a3Constant = 300;
z3Constant = 1300;

typeNames = {'z3','a3','b'};
typeConstants = [z3Constant a3Constant bConstant];

filebase = sprintf('s%02d_run%02d_TrainImageSequenceRivalry', subject, session);
savefile = [filebase '_a.mat']; 
savedir = 'analysis/';
savepath = ([savedir savefile]);
figsavedir = 'figures/';
figfilebase = sprintf('s%02d_run%02d_Train', subject, session);

% -----------
% load data 
% -----------
datafile = dir(['data/' filebase '*']);
try
    datafile = datafile.name;
catch
    error('More or less than one matching data file! Check subject, session, and collected data files.')
end
load(['data/' datafile]);

% --------------
% data analysis
% --------------
% read out trial information from blocks
sequenceByBlock = stim.sequence;
sequenceImageSetsByBlock = mod(sequenceByBlock,100);
sequenceConstantsByBlock = sequenceByBlock - mod(sequenceByBlock,100);

nTrialsPerBlock = size(sequenceByBlock,1);
nBlocks = size(sequenceByBlock,2);
nTrials = nTrialsPerBlock*nBlocks;
blockNumByBlock = repmat(1:nBlocks,nTrialsPerBlock,1);

for block = 1:length(responseArray)
    rtByBlock(:,block) = responseArray(block).keyTimes;
    accByBlock(:,block) = responseArray(block).responseAcc;
end

% trials from all blocks
sequence = reshape(sequenceByBlock,nTrialsPerBlock*nBlocks,1);
rt = reshape(rtByBlock,nTrialsPerBlock*nBlocks,1);
acc = reshape(accByBlock,nTrialsPerBlock*nBlocks,1);
blockNum = reshape(blockNumByBlock,nTrialsPerBlock*nBlocks,1);
sequenceImageSets = mod(sequence,100);
sequenceConstants = sequence - mod(sequence,100);

% missed trials, set rt to nan
missedTrials = find(rt==0)
numMissedTrials = length(missedTrials)
rt(missedTrials) = NaN;

% store data in trials
trials_headers = {'trialNum','blockNum','imageNum','imageTypeConstant',...
    'imageSetNum','acc','rt'};

trials(:,1) = 1:nTrials;
trials(:,2) = blockNum;
trials(:,3) = sequence;
trials(:,4) = sequenceConstants;
trials(:,5) = sequenceImageSets;
trials(:,6) = acc;
trials(:,7) = rt;

blockIdx = find(strcmp(trials_headers,'blockNum'));
imageIdx = find(strcmp(trials_headers,'imageNum'));
typeConstantIdx = find(strcmp(trials_headers,'imageTypeConstant'));
imageSetIdx = find(strcmp(trials_headers,'imageSetNum'));
accIdx = find(strcmp(trials_headers,'acc'));
rtIdx = find(strcmp(trials_headers,'rt'));

% totals
totals_headers = {'blockNum','imageNum','acc','rt'};

for block = 1:nBlocks
    for type = 1:length(typeConstants)
        for im = 1:nImageBs

            w_block = trials(:,blockIdx)==block;
            w_type = trials(:,typeConstantIdx)==typeConstants(type);
            w_im = trials(:,imageSetIdx)==im;
            
            w = w_block & w_type & w_im;
            
            totals(:,:,im,type,block) = trials(w,[blockIdx imageIdx accIdx rtIdx]);
            
        end
    end
end

totals_all = totals;
clear totals

totals.means = nanmean(totals_all);
totals.meansIm = nanmean(totals.means,3); % collapsed across images
totals.meansIm_ste = nanstd(totals.means,0,3)/sqrt(size(totals.means,3));

totalsAccIdx = find(strcmp(totals_headers,'acc'));
totalsRTIdx = find(strcmp(totals_headers,'rt'));

% [type x block]
totals.accMeans = squeeze(totals.meansIm(:,totalsAccIdx,:,:,:));
totals.accSte = squeeze(totals.meansIm_ste(:,totalsAccIdx,:,:,:));
totals.rtMeans = squeeze(totals.meansIm(:,totalsRTIdx,:,:,:));
totals.rtSte = squeeze(totals.meansIm_ste(:,totalsRTIdx,:,:,:));

% --------------------------------
% store the trial info and data
% --------------------------------
responseSummary.subject = subject;
responseSummary.session = session;
responseSummary.nImageBs = nImageBs;
responseSummary.types.typeNames = typeNames;
responseSummary.types.typeConstants = typeConstants;
responseSummary.trials_headers = trials_headers;
responseSummary.trials = trials;
responseSummary.totals_headers = totals_headers;
responseSummary.totals = totals;
responseSummary.whenAnalyzed = datestr(now);

% --------------
% save analysis
% --------------
if savedata
    save(savepath,'expt','stim','responseArray','responseSummary')
end

% ------
% plots
% ------
if plotfigs
    blockLabels = {'block 1','block 2','block 3','block 4','block 5'};
    xlims = [.8 3.2];

    f(1) = figure;
    errorbar(totals.accMeans, totals.accSte);
    xlim(xlims)
    set(gca,'XTick',1:3)
    xlabel('Position in image sequence')
    ylabel('Accuracy (proportion correct)')
    legend(blockLabels,'Location','best')
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])

    f(2) = figure;
    errorbar(totals.rtMeans, totals.rtSte);
    xlim(xlims)
    set(gca,'XTick',1:3)
    xlabel('Position in image sequence')
    ylabel('RT (s)')
    legend(blockLabels,'Location','best')
    title(['Subject ' num2str(subject) ', Session ' num2str(session)])
end

% ----------
% save figs
% ----------
figNameExtensions = {'_acc.jpg', ...
                     '_rt.jpg'};
if savefigs
    for iF = 1:length(f)
        print(f(iF),'-djpeg','-r80',[figsavedir figfilebase figNameExtensions{iF}])
    end
end
    
            
            

