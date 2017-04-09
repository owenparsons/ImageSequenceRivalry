function rd_combineRunsImageSequenceRivalry(subject)

% Combines data from multiple runs for a single subject into a large data
% set, as if the data had been collected in a single run, and saves this
% data set with session number specified by the user.
%
% Does not assume anything about number of sessions or number of trials per
% sessions. Session numbers are user-defined.

% Here we have responseArrays that are [1 x num_blocks] and trialArrays
% that are [num_blocks x num_trials], so we combine runs simply by stacking
% the blocks.

% -----------------------
% user-defined
% -----------------------
% subject = 1;
sessionsToCombine = 1:2; % session numbers (as in data file names)
numSessionsToCombine = length(sessionsToCombine);
outputSessionNumber = 9;

savefile = [sprintf('s%02d_run%02d_TestImageSequenceRivalryContResp_', subject, outputSessionNumber) datestr(now,'ddmmmyyyy')];
savepath = ['data/Test/' savefile];

savedata = 1;

% -----------------------
% combine sessions
% -----------------------
multiSessionResponseArray = [];
multiSessionTrialArray = [];
multiSessionRivalryPairsSequenceByBlock = [];

for j = 1:numSessionsToCombine
    
    session = sessionsToCombine(j);
    
    filebase = sprintf('s%02d_run%02d_TestImageSequenceRivalryContResp', subject, session);

    % load data, inc responseArray, randomOrderVector
    datafile = dir(['data/Test/' filebase '*']);
    try
        datafile = datafile.name;
    catch
        error('More or less than one matching data file! Check subject, session, and collected data files.')
    end
    load(['data/Test/' datafile]);
    
    multiSessionResponseArray = [multiSessionResponseArray; responseArray];
    multiSessionTrialArray = [multiSessionTrialArray; stim.trialArray];
    multiSessionRivalryPairsSequenceByBlock = cat(3, multiSessionRivalryPairsSequenceByBlock, ...
        stim.sequence);
    
end % end for all sessions to combine

% unify variable names with variables from regular experimental session
responseArray = multiSessionResponseArray;
trialArray = multiSessionTrialArray;
rivalryPairsSequenceByBlock = multiSessionRivalryPairsSequenceByBlock;

TYPES = stim.TYPES;

% note time 
whenCombined = datestr(now);

% ----------------------
% save data
% ----------------------
if savedata
    save(savepath, 'responseArray', 'trialArray', 'rivalryPairsSequenceByBlock', 'TYPES', 'subjectID', 'timeStamp', 'whenCombined', 'sessionsToCombine')
end


