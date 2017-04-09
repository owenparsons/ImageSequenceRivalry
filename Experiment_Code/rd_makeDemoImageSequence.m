function imageSequence = rd_makeDemoImageSequence(nImageBs, nRepsB)

% Just show all the images in random order, to train subjects on key
% mapping.

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

a1Constant = 100; % predicts b with zero probability
a2Constant = 200; % predicts b with low probability
a3Constant = 300; % predicts b with high probability

z1Constant = 1100; % precedes a1
z2Constant = 1200; % precedes a2
z3Constant = 1300; % precedes a3 

bs = 1:nImageBs;
a3s = bs + a3Constant;
z3s = bs + z3Constant;

images = repmat([bs, a3s, z3s], 1, nRepsB);

imageSequence = Shuffle(images)';


