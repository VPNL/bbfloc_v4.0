function RUNME(participant, run)
%% Run this function to generate 1 unique bbfloc run containing blocks of Heather Kosakowski's stimuli and static floc
%% with 3 reps per category

%% INPUT:
% participant's initials/number as string i.e. ('BR') 
% run: run you're generating as integer (ie.: 1, 2, 3)

%% OUTPUT:
% Generates participant's necessary combinedData folders to run psychopy
% Generates a CSV and parfile for the run, as well as an mp4.video
% containing all the stimuli for the run (to be used in runMe.Py)

%% Generates participant's combinedData folder if doesn't exist yet

addpath(fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_4.0', 'matlab', 'functions'));
addpath(fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_4.0', 'matlab'));

participant_folder = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_4.0', 'psychopy', 'data', participant);

% Check if the folder doesn't already exist
if ~exist(participant_folder, 'dir')
    % Create the folder
    mkdir(participant_folder);
    disp(['Folder ''' participant_folder ''' created successfully.']);
else
    disp(['Folder ''' participant_folder ''' already exists.']);
end

%% Generate run CSV and parfile

% First generate the blocks for the runs 
% Generate blocks containing Kosakowkski's stimuli
make_kosakowski_blocks(participant, run)
% Generate blocks containing static fLoc stimuli
make_static_floc_blocks(participant, run)
% Generate baseline blocks
make_baseline_blocks(participant, run)

% Combine these blocks in a CSV and shuffle them!
makeorder_CSV_new(participant, run)

%Generate a par file
generateparfile(participant,run)

%% Generate video of the run
% Generate video
video_gen(participant, run)

