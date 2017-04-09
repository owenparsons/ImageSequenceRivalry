function imageSequence = rd_makePostTestImageSequence(sequenceNumbers)

a3Constant = 300; % predicts b with high probability
z3Constant = 1300; % precedes a3 

nImageBs = length(sequenceNumbers);

allSetStack = zeros(nImageBs, 3);

for imageB = 1:nImageBs

    b = sequenceNumbers(imageB);

    % beforeB contains the ids of images presented right before b
    beforeB = [(b + z3Constant) (b + a3Constant)];
    bSet = [beforeB b];

    % put the sets in the big stack of sets for all B images
    allSetStack(imageB,:) = bSet;

end

imageSequence = reshape(allSetStack', nImageBs * size(allSetStack,2), 1);

return
