function imageSequenceImages = getImageLabels(imageSequence, TYPES, imageKey)

% function imageSequenceImages = getImageLabels(imageSequence, imageKey)
% returns image ids for each image in the image sequence
%
% imageKey is an nx2 cell array with key pairs {fileName, imageLabel} in
% each row

imageTypeNames = {'b','a1','a2','a3','c1','c2','c3','c4','d','z1','z2','z3'}'; 
lowerbounds = [(0:100:800) (1100:100:1300)]';
upperbounds = lowerbounds + 101;

for trial = 1:length(imageSequence)

    imageNumber = imageSequence(trial);
    imageType = imageTypeNames{(imageNumber > lowerbounds) & (imageNumber < upperbounds)};
    image = rem(imageNumber, 100);

    imageSequenceFile = TYPES.(imageType).imageFiles(image).name;
    keyPair = find(strcmp(imageKey(:,1),imageSequenceFile));
    imageSequenceImages{trial,1} = imageKey{keyPair,2};

end