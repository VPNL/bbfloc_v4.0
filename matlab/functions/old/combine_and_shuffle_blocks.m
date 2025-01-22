function combine_and_shuffle_blocks(participant)

participant_folder = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0', 'psychopy', 'data', participant);

csvfile1 = fullfile(participant_folder, strcat('kosakowski_blocks.csv')); % Replace with the actual file path
csvfile2 = fullfile(participant_folder, strcat('static_blocks.csv')); % Replace with the actual file path
csvfile3 = fullfile(participant_folder, strcat('baseline_blocks.csv')); % Replace with the actual file path

% Read the CSV files into tables
data1 = readtable(csvfile1);
data2 = readtable(csvfile2);
data3 = readtable(csvfile3);

% Step 1: Combine the two datasets into one
data = vertcat(data3, data2, data1);

% Step 1: Extract block numbers (assuming block numbers are in the first column)
blockNumbers = data{:, 1};  % Assuming the first column contains the block numbers

% Step 2: Identify unique block numbers
uniqueBlocks = unique(blockNumbers);

% Step 3: Group rows by block number
% We'll create a cell array where each cell contains rows corresponding to a specific block
groupedData = cell(length(uniqueBlocks), 1);

for i = 1:length(uniqueBlocks)
    % Find the indices of rows for the current block
    blockIndices = blockNumbers == uniqueBlocks(i);
    
    % Store the rows belonging to this block in the cell array
    groupedData{i} = data(blockIndices, :);
end

% Step 4: Shuffle the order of the blocks
shuffledBlockOrder = uniqueBlocks(randperm(length(uniqueBlocks)));

% Step 5: Remap block numbers according to the shuffled order
remappedData = [];

for i = 1:length(shuffledBlockOrder)
    % Get the group corresponding to the current shuffled block number
    group = groupedData{i};
    
    % Update the block number in the current group to the new shuffled value
    group{:, 1} = shuffledBlockOrder(i);
    
    % Concatenate this group to the final data
    remappedData = [remappedData; group];
end

% Step 7: Sort the data so that blocks are in numerical order
sortedData = sortrows(remappedData, 1);  % Sorting based on the first column (block number)

% Step 5: Set the onset time for the first trial
sortedData.Onset_time_s_(1) = 0.0;  % First trial onset time is 0.0 seconds

% Step 6: Calculate onset times for subsequent trials based on StimDur
for i = 2:height(sortedData)
    % The onset time of the current trial is the onset time of the previous trial + its duration
    sortedData.Onset_time_s_(i) = sortedData.Onset_time_s_(i-1) + sortedData.StimDur(i-1);
end

% Step 7: Save the result to a new CSV file
outputFile = fullfile(participant_folder, 'shuffled_and_sorted_blocks_with_onsets.csv');
writetable(sortedData, outputFile, 'WriteVariableNames', true);

% Display the final sorted data with onset times
disp(sortedData);
