%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub-function to make a substack given a certain number of nRepsB
% nRepsB must be low enough to result in repeat-free sequences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allSetStackShuffled] = makeShuffledSetStack(nImageBs, nSets, nRepsB, useSeparateZeroSet, lowPredProb, highPredProb, a1Constant, a2Constant, a3Constant, z1Constant, z2Constant, z3Constant)

nA2BeforeB = round(nRepsB * lowPredProb);
% nA3BeforeB = round(nRepsB * highPredProb);

allSetStack = zeros(nImageBs * nSets * nRepsB, 3);

for imageB = 1:nImageBs

    b = zeros(nRepsB,1) + imageB;
    dummy = zeros(size(b));

    % beforeB contains the ids of images presented right before b in training
    beforeB = [b b];
    beforeB(1:nA2BeforeB,:) = [(b(1:nA2BeforeB) + z2Constant) (b(1:nA2BeforeB) + a2Constant)];
    beforeB(nA2BeforeB + 1:end,:) = [(b(nA2BeforeB + 1:end) + z3Constant) (b(nA2BeforeB + 1:end) + a3Constant)];
    bSet = [beforeB b];

    if highPredProb < 1
        % contraB contains the mirror of beforeB in order to make the probabilities
        % work out; these images are presented in no particular stream location
        contraB = [b b];
        contraB(1:nA2BeforeB,:) = [(b(1:nA2BeforeB) + z3Constant) (b(1:nA2BeforeB) + a3Constant)];
        contraB(nA2BeforeB + 1:end,:) = [(b(nA2BeforeB + 1:end) + z2Constant) (b(nA2BeforeB + 1:end) + a2Constant)];
        contraBSet = [contraB dummy];
    end

    % a1 contains the zero-predictive images, presented in no particular stream
    % location
    a1 = b + a1Constant;
    z1 = b + z1Constant;
    a1Set = [z1 a1 dummy];

    % stack up the sets
    if highPredProb == 1 && useSeparateZeroSet == 0
        setStack = bSet;
    elseif highPredProb == 1
        setStack = [bSet; a1Set]; 
    elseif useSeparateZeroSet == 0
        setStack = [bSet; contraBSet];
    else
        setStack = [bSet; contraBSet; a1Set];
    end

    % put the sets in the big stack of sets for all B images
    inds = ((imageB-1)*nRepsB*nSets + 1):(imageB*nRepsB*nSets);
    allSetStack(inds,:) = setStack;

end

% shuffle the sets
% if we require no set repeats, we need to do this in segments involving 8
% nRepsB or fewer. otherwise, the chance is too low of it finding a viable
% sequence in a reasonable time.
repeatFlag = 1;
counter = 0;
while repeatFlag
    shuffleInds = randperm(length(allSetStack))';
    allSetStackShuffled = allSetStack(shuffleInds,:);
    repeatFlag = any(diff(allSetStackShuffled(:,1))==0);
    counter = counter+1;
    
    if counter==100000
        error('Was not able to find a repeat-free ordering of the image sets!')
    end
end

return
