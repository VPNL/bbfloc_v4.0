function write_baseline_blocks(participant)
%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENTAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0', 'matlab', 'functions'));
participant_folder = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0', 'psychopy', 'data', participant);
stim_dir = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0', 'stimuli', 'saxestim_wfixation_grouped');

% Stimulus categories 
cats = {'blank'};

ncats = length(cats); % number of stimulus conditions
nconds = ncats;  % number of conditions to be counterbalanced (including baseline blocks)
% Map the original category index to a new index
category_mapping = 0;

% Presentation and design parameters
nruns = 1; % number of runs
nreps = 16; % number of  blocks per category per run
vidsperblock = 2;
viddur = 4;  %stimulus presentation time (secs)

nblocks = nconds*nreps; % number of blocks in a run
ntrials = nblocks*vidsperblock; % number of trials in a run
blockdur =  vidsperblock*viddur; % block duration (sec)
rundur = nblocks*blockdur; % run duration (sec)

exp = 'bbfloc_2.0';

% Get user input and concatenate it into the file path

participant_folder = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0', 'psychopy', 'data', participant);

% Create matrix for Block #
blockmat = zeros(ntrials,nruns);
for r = 1:nruns
    blockmat(:,r) = reshape(repmat(1:nblocks,vidsperblock,1),ntrials,1);
end

% Create matrix for Condition without consecutive repetitions
condmat = zeros(ntrials,nruns);
for r = 1:nruns
    condvec = [randperm(ncats)];    % generate the order of the stim presentation
    % Check for consecutive repetitions and reshuffle if found
    while any(diff(condvec) == 0)
        condvec = [randperm(ncats)];
    end
    condvec = [condvec'];
    condmat(:, r) = reshape(repmat(condvec', vidsperblock, 16), ntrials, 1);
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
                   stimmat{tri,r} = strcat(lower(cats{cat}),'-',num2str(vidnums(vidcounter)),'.mp4');
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
stim_type = 'video';
stim_directory = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0',  'stimuli', 'saxestim_wfixation_regrouped');

    csvfilename = fullfile(participant_folder, strcat('baseline_blocks.csv'));
    fid = fopen(csvfilename, 'w');
    if fid == -1
        error('Failed to open file: %s', csvfilename);
    end
    fprintf(fid, 'Block #,Onset-time(s),Category,TaskMatch,Stim Name,Stim Path,Stim Type,Stim Dur\n');

    onset_time = 0; 
    current_block = 1;

    % Loop through trials
    for tri = 1:ntrials 
        original_category_index = condmat(tri, r);
        mapped_category_index = category_mapping(original_category_index); 
        vid_name = stimmat{tri, r};
        stim_path = fullfile(stim_dir, vid_name);
        
        % Determine if the current trial is the last in the block
        if mod(tri,2) == 0
            % Reduce the duration of the last trial by 0.0002 seconds
            fprintf(fid, '%i,%f,%i,%s,%s,%s,%s,%f\n', ...
                current_block, onset_time, mapped_category_index, cats{original_category_index}, vid_name, stim_path, stim_type, viddur);
                if mod(current_block, 7) ~= 0
                    current_block = current_block + 3;
                else 
                    current_block = current_block + 2; 
                end
         else
            fprintf(fid, '%i,%f,%i,%s,%s,%s,%s,%f\n', ...
                current_block, onset_time, mapped_category_index, cats{original_category_index}, vid_name, stim_path, stim_type, viddur);
        end
    end

    % Write closing baseline block
    current_block = current_block + 1;
end