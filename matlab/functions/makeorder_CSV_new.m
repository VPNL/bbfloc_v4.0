function makeorder_CSV_new(participant, run)

%% Generates the CSV for this run by compiling the blocks generated into one CSV and shuffling them to prevent consecutive category presentations

% Participant folder and file paths
participant_folder = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_4.0', 'psychopy', 'data', participant);

csvfile1 = fullfile(participant_folder, strcat('static_blocks_run', num2str(run), '.csv')); 
csvfile2 = fullfile(participant_folder, strcat('kosakowski_blocks_run', num2str(run), '.csv')); 
csvfile3 = fullfile(participant_folder, strcat('baseline_blocks_run', num2str(run), '.csv'));

% Read the CSV files into tables
data1 = readtable(csvfile1);
data2 = readtable(csvfile2);
data3 = readtable(csvfile3);

% Combine the datasets 
data = vertcat(data1, data2);

% Extract block numbers
blockNumbers = data{:, 1};  % Assuming the first column contains the block numbers

% Identify unique block numbers
uniqueBlocks = unique(blockNumbers);


BlockRemap = [2, 3, 5, 6, 8, 9, 10, 12, 13, 15, 16, 18, 19, 21, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 36, 38, 39];

% Define the arrays evens are kosakdowski odds are static
uniqueBlocks1 = [1, 2, 3, 4, 5, 6, 7, 8, 9]; % 4 kosakowski; 5 static
uniqueBlocks2 = [10, 11, 12, 13, 14, 15, 16, 17, 18]; %4 kosakowski - 18 has to be static 
uniqueBlocks3 = [19, 20, 21, 22, 23, 24, 25, 26, 27]; 


% Generate random permutations of indices for each array
shuffledBlockOrder1 = randperm(length(uniqueBlocks1));
shuffledBlockOrder2 = randperm(length(uniqueBlocks2));
shuffledBlockOrder3 = randperm(length(uniqueBlocks3));

% % Shuffle the arrays
% shuffledBlockOrder1 = randperm(length(uniqueBlocks1));
% shuffledBlockOrder2 = randperm(length(uniqueBlocks2));
% shuffledBlockOrder3 = randperm(length(uniqueBlocks3));
% 
% shuffledUniqueBlocks1 = uniqueBlocks1(shuffledBlockOrder1);
% shuffledUniqueBlocks2 = uniqueBlocks2(shuffledBlockOrder2);
% shuffledUniqueBlocks3 = uniqueBlocks3(shuffledBlockOrder3);

% Shuffle each array
shuffledBlocks1 = customshuffle(uniqueBlocks1);
shuffledBlocks2 = customshuffle(uniqueBlocks2);
shuffledBlocks3 = customshuffle(uniqueBlocks3);


uniqueBlocks = [shuffledBlocks1, shuffledBlocks2, shuffledBlocks3];

% Initialize cell array to store grouped data by block
groupedData = cell(length(uniqueBlocks), 1);


% Initialize cell array to store grouped data by block
groupedData = cell(length(uniqueBlocks), 1);

% Step 3: Group rows by block number and store them in a cell array
for i = 1:length(uniqueBlocks)
    % Find the indices of rows for the current block
    blockIndices = blockNumbers == uniqueBlocks(i);
    
    % Store the rows belonging to this block in the cell array
    groupedData{i} = data(blockIndices, :);
end

% Step 4: Remap block numbers according to the shuffled order
remappedData = [];  % Initialize empty array for remapped data

% Create a new variable to track task matches (by prefix)
lastTaskMatchPrefix = '';  % Initialize an empty string to store the task match prefix of the previous block

% Loop over the shuffled block order and remap block numbers
for i = 1:length(uniqueBlocks)
    % Get the group corresponding to the current shuffled block number
    group = groupedData{i};
    
    % Update the block number in the current group to the new shuffled value
    group{:, 1} = BlockRemap(i);  % Replace block number (first column)
    
    % Concatenate this group to the final data
    remappedData = [remappedData; group];  % Append to remapped data
end

remappedData2 = vertcat(remappedData, data3);
% Step 7: Sort the data so that blocks are in numerical order
sortedData = sortrows(remappedData2, 1);  % Sorting based on the first column (block number)

% Step 5: Set the onset time for the first trial
sortedData.Onset_time_s_(1) = 0.0;  % First trial onset time is 0.0 seconds

% Step 6: Calculate onset times for subsequent trials based on StimDur
for i = 2:height(sortedData)
    % The onset time of the current trial is the onset time of the previous trial + its duration
    sortedData.Onset_time_s_(i) = sortedData.Onset_time_s_(i-1) + sortedData.StimDur(i-1);
end

% Step 7: Save the result to a new CSV file
outputFile = fullfile(participant_folder, strcat('run', num2str(run), '.csv'));
writetable(sortedData, outputFile, 'WriteVariableNames', true);

% Display the final sorted data with onset times
disp(sortedData);

end
