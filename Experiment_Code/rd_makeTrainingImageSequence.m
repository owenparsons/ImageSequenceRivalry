function imageSequence = rd_makeTrainingImageSequence(nImageBs, nRepsB, repsPerSubstack)

% Now for image sequence sets that are triplets (Z-A-B) 
% Make one image sequence per block

% Key to image codes:
% B (targets)            : 1-100
% A1 (zero predictive)   : 101-200
% A2 (low predictive)    : 201-300
% A3 (high predictive)   : 301-400
% C3 (rival with B)      : 601-700 
% C4 (rival with D)      : 701-800
% D (category match to B): 801-900
% Z1 (precedes A1)       : 1101-1200
% Z2 (precedes A2)       : 1201-1300
% Z3 (precedes A3)       : 1301-1400

% useSeparateZeroSet = 1 if a1 is a different set of images from a3, 
% 0 if a1 is drawn from a3 (but still zero predictive)
useSeparateZeroSet = 0; 

% option to have zero, low, and high predictive conditions, or just zero
% and high predictive (set highPredProb = 1, lowPredProb = 0)
% precision of these probabilities depends on number of repsPerSubstack.
highPredProb = 1;
lowPredProb = 0;

% set number of target B images, training reps, block size
if nargin==0
    % default values
    nImageBs = 4;
    nRepsB = 18;
    repsPerSubstack = 6;
end

a1Constant = 100; % predicts b with zero probability
a2Constant = 200; % predicts b with low probability
a3Constant = 300; % predicts b with high probability

z1Constant = 1100; % precedes a1
z2Constant = 1200; % precedes a2
z3Constant = 1300; % precedes a3 

if highPredProb == 1 && useSeparateZeroSet == 0
    nSets = 1; % no contraBSet, no a1
elseif highPredProb == 1
    nSets = 2; % no contraBSet
elseif useSeparateZeroSet == 0
    nSets = 2; % no a1
else
    nSets = 3; % bSet, contraBSet, a1Set
end

% Make substacks to ensure no triplet repeats in sequence
nSubRepsB = floor(nRepsB/repsPerSubstack); % 6 is a viable number of reps for no repeats
subRepsB = repmat(repsPerSubstack, 1, nSubRepsB);
if mod(nRepsB,repsPerSubstack)~=0
    subRepsB = [subRepsB mod(nRepsB,repsPerSubstack)];
end

repeatFlag = 1; count = 0;
while repeatFlag
    asss = zeros(3, nImageBs*repsPerSubstack*nSets,length(subRepsB));
    for substack = 1:length(subRepsB)
        ass = makeSetStack(...
            nImageBs, nSets, subRepsB(substack), ...
            useSeparateZeroSet, lowPredProb, highPredProb, ...
            a1Constant, a2Constant, a3Constant, ...
            z1Constant, z2Constant, z3Constant);
        
        asss(:, 1:subRepsB(substack)*nImageBs*nSets, substack) = shuffleSetStack(ass)';
    end
    
    % check for repeats across substacks
    repeatFlag = 0;
    for substack = 1:length(subRepsB)-1
        if asss(end,end,substack) == asss(end,1,substack+1)
            repeatFlag = 1;
        end
    end
    count = count+1;
end

allSetStackShuffled = reshape(asss, 3, size(asss,2)*size(asss,3))';
    
% reshape into a 1-D list (already shuffled)
imageSequence = reshape(allSetStackShuffled', nImageBs*nRepsB*nSets*3, 1);

% take out dummy zeros
imageSequence(imageSequence==0) = [];

return


