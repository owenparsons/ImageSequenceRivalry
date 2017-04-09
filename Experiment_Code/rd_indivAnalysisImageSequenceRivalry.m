% rd_indivAnalysisImageSequenceRivalry.m

%% setup
groupStr = 'g1-18_N18';
testRun = 1;
figdir = 'figures/CrossTask/';

saveFigs = 0;

%% get indiv subject data for training, test, and post test
train = load(sprintf('analysis/Training/%s_run01_TrainImageSequenceRivalry_a.mat',groupStr));
test = load(sprintf('analysis/Test/%s_run%02d_TestImageSequenceRivalry_a.mat',groupStr, testRun));
post = load(sprintf('analysis/PostTest/%s_run01_PostTestImageSequenceRivalry_a.mat',groupStr));
eye = load(sprintf('analysis/Test/%s_run%02d_TestImageSequenceEyeDom.mat', groupStr, testRun));

trainAcc = mean(squeeze(train.groupData.acc(:,5,:)),1)'; % mean across positions
testPrfm = test.groupData.propFirstRespMatching;
postAcc = post.groupData.acc;
eyeDom = abs(eye.firstRespRightEye-0.5)*2; % rel eye dom (scaled 0-1)

testPrfmE = [testPrfm(:,2)-testPrfm(:,1) testPrfm(:,4)-testPrfm(:,3)]; % matching effect

%% figures
% train vs. test
f(1) = figure;
plotmatrix(trainAcc,testPrfmE);
% plotmatrix_label({'cat id'}, {'im-effect','cat-effect'});

% post vs. test
f(2) = figure;
plotmatrix(postAcc,testPrfmE);
plotmatrix_label(post.groupLabels, {'im-effect','cat-effect'});

% train vs. post
f(3) = figure;
plotmatrix(trainAcc,postAcc);
% plotmatrix_label({'cat id'}, post.groupLabels);

%% save figs
if saveFigs
    figNameExtensions = {'trainVsTest.jpg', ...
        'postVsTest.jpg', ...
        'trainVsPost.jpg'};
    for iF = 1:length(f)
        figfile = sprintf('%s/%s_run%02d_CrossTaskImSeq2_%s', figdir, groupStr, testRun, figNameExtensions{iF});
        print(f(iF),'-djpeg','-r80',figfile)
    end
end

%% more stats
imLearning = postAcc(:, strcmp(post.groupLabels, 'trained_v_cat-match'));
catLearning = postAcc(:, strcmp(post.groupLabels, 'cat-match_v_cat-diff'));
anyLearning = postAcc(:, strcmp(post.groupLabels, 'trained_v_cat-diff'));

testPrfmEIm = testPrfmE(:,1);
testPrfmECat = testPrfmE(:,2);
testPrfmEOverall = mean(testPrfmE,2);

% get imseq4 (recall rate) from rd_interviewScore.m
ivScoreValsOverall = imseq4(:,1);

% Rivalry test vs. Post test
[rAny pAny rloAny rupAny] = corrcoef(anyLearning, testPrfmEOverall)
[rIm pIm rloIm rupIm] = corrcoef(imLearning, testPrfmEIm)
[rCat pCat rloCat rupCat] = corrcoef(catLearning, testPrfmECat)

% Post test vs. interview recall rate
[rPost pPost rloPost rupPost] = corrcoef(anyLearning, ivScoreValsOverall)
