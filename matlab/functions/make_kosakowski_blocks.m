function make_kosakowski_blocks(participant, user, run)
%% Generates blocks for Kosawkowskis's natural stimuli; 3 reps per category 
% six stimuli per block, presented for 2.667 seconds each = 16 second
% blocks

% INPUT: Should be the subject name
% 
% STIMULI: 4 main stimulus categories with 2 subcategories each (totaling
% 8 stim blocks)
% 6) Faces: side, front
% 7) Limbs: hands, feet
% 8) Objects: collisions, shapes 
% 9) Scenes: fences, egomotion
%
%% no task for the infant floc
%% VERSION: 1.0 12/2/2024 by CT
% Department of Psychology, Stanford University

%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENTAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%
participant_folder = fullfile('/Users', user, 'Desktop', 'bbfloc_4.0', 'psychopy', 'data', participant);
stim_dir = fullfile('/Users', user, 'Desktop', 'bbfloc_4.0', 'stimuli', 'saxestim_wfixation_grouped');

% Stimulus categories 
cats = {'Faces-D', 'Limbs-D', 'Objects-D', 'Scenes-D'};

ncats = length(cats); % number of stimulus conditions
nconds = ncats;  % number of conditions to be counterbalanced (including baseline blocks)
% Map the original category index to a new index
category_mapping = [6, 7, 8, 9];

% Presentation and design parameters
nruns = 1; % number of runs
nreps = 3; % number of  blocks per category per run
vidsperblock = 6;
viddur = 2.6667;  %stimulus presentation time (secs)

nblocks = nconds*nreps; % number of blocks in a run
ntrials = nblocks*vidsperblock; % number of trials in a run
blockdur =  vidsperblock*viddur; % block duration (sec)
rundur = nblocks*blockdur; % run duration (sec)

exp = 'bbfloc_4.0';

% Get user input and concatenate it into the file path

participant_folder = fullfile('/Users', user, 'Desktop', 'bbfloc_4.0', 'psychopy', 'data', participant);

% Create matrix for Block #
blockmat = zeros(ntrials,nruns);
for r = 1:nruns
    blockmat(:,r) = reshape(repmat(1:nblocks,vidsperblock,1),ntrials,1);
end

condmat = zeros(ntrials,nruns);
% Loop over runs
for r = 1:nruns
    % Generate a fixed order of the stimulus categories
    condvec = repmat([1:ncats], 1, 3);  % Each category repeats exactly 3 times
    % No need to reshuffle, this will ensure each category repeats 3 times
    condvec = condvec(:);  % Convert to a column vector
    
    % Ensure the total number of trials matches the number of categories
    condmat(:, r) = reshape(repmat(condvec', vidsperblock, 1), ntrials, 1);
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE MATRIX FOR STIMULI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimmat = cell(ntrials, nruns); % Initialize cell array for videos

for r = 1:nruns
        for cat = 1:ncats
            % Generate unique video numbers for this condition and run
            vidnums = randperm(vidsperblock); % Random permutation of numbers from 1 to vidsperblock
            vidcounter = 0;
            
            for tri = 1:ntrials
                if condmat(tri,r) == cat %check if current trial in the run corresponds with the category 
                   vidcounter = vidcounter + 1;
                   stimmat{tri,r} = strcat(lower(cats{cat}(1:end-2)),'-',num2str(vidnums(vidcounter)),'.mp4');
               % If all videos have been used for this category, regenerate vidnums and reset vidcounter
                if vidcounter == vidsperblock
                    vidcounter = 0;  % Reset the counter for the next block of videos
                    vidnums = randperm(vidsperblock);  % Generate a new random permutation for the next block
       
            end
        end
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE CSV containing blocks 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List of valid block numbers (kosakowski block sequence)
kosakowski = [2, 4, 6, 8, 10, 12, 14, 16, 20, 22, 24, 26];

stim_type = 'video';

% File path to save the CSV file
csvfilename = fullfile(participant_folder, strcat('kosakowski_blocks_run', num2str(run), '.csv'));
fid = fopen(csvfilename, 'w');
if fid == -1
    error('Failed to open file: %s', csvfilename);
end
fprintf(fid, 'Block #,Onset-time(s),Category,TaskMatch,Stim Name,Stim Path,Stim Type,Stim Dur\n');

onset_time = 0; 
current_block_idx = 1;  % Index to track the current block in kosakowski
current_block = kosakowski(current_block_idx);  % Start with the first valid block number

% Loop through trials
for tri = 1:ntrials 
    original_category_index = condmat(tri, r);
    mapped_category_index = category_mapping(original_category_index); 
    vid_name = stimmat{tri, r};
    stim_path = fullfile(stim_dir, vid_name);
    
    % Determine if the current trial is the last in the block
    if mod(tri, 6) == 0
        % Reduce the duration of the last trial by 0.0002 seconds
        fprintf(fid, '%i,%f,%i,%s,%s,%s,%s,%f\n', ...
            current_block, onset_time, mapped_category_index, cats{original_category_index}, vid_name, stim_path, stim_type, viddur - 0.0002);
    else
        fprintf(fid, '%i,%f,%i,%s,%s,%s,%s,%f\n', ...
            current_block, onset_time, mapped_category_index, cats{original_category_index}, vid_name, stim_path, stim_type, viddur);
    end

    % After every 6 trials (a full block), move to the next block
    if mod(tri, 6) == 0
        % Increment the block number (by 2) and check if we need to reset
        current_block_idx = current_block_idx + 1;
        
        % If we've reached the end of the kosakowski array, reset to start
        if current_block_idx > length(kosakowski)
            current_block_idx = 1;  % Start over from the first block
        end
        
        current_block = kosakowski(current_block_idx);  % Update current block number
    end

    % Update the onset time for the next trial (assuming it's a fixed interval, e.g., 1 second per trial)
    onset_time = onset_time + 1;  % Adjust this as necessary for your experiment's timing
end

% Close the file after writing all trials
fclose(fid);

end
