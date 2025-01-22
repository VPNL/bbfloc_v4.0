function make_order_CSV(participant, run)

%%Generates a run CSV by compiling the block CSVs 
% Participant folder and file paths
participant_folder = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0', 'psychopy', 'data', participant);

csvfile1 = fullfile(participant_folder, strcat('static_blocks_run', num2str(run), '.csv')); 
csvfile2 = fullfile(participant_folder, strcat('kosakowski_blocks_run', num2str(run), '.csv')); 
csvfile3 = fullfile(participant_folder, strcat('baseline_blocks_run', num2str(run), '.csv'));

% Read the CSV files into tables
data1 = readtable(csvfile1);
data2 = readtable(csvfile2);
data3 = readtable(csvfile3);

% Combine the datasets 
data = vertcat(data1, data2);

% Extract block numbers and task match (assuming block numbers are in the first column and task match in another column)
blockNumbers = data{:, 1};  % Assuming the first column contains the block numbers
taskMatch = data{:, 4};  % Assuming the fourth column contains the task match

% Identify unique block numbers
uniqueBlocks = unique(blockNumbers);

% Predefined block remapping
blockRemap = [2, 3, 5, 6, 8, 10, 11, 13, 14, 16, 17, 19, 20, 22, 24, 25, 27, 28, 30, 31, 33, 34, 36, 38, 39, 41, 42];

% Shuffle the blockRemap array randomly without repetition
shuffledBlockRemap = blockRemap(randperm(length(blockRemap))); 

% Shuffle the order of unique blocks
shuffledBlockOrder = uniqueBlocks(randperm(length(uniqueBlocks)));

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
for i = 1:length(shuffledBlockOrder)
    % Get the group corresponding to the current shuffled block number
    group = groupedData{i};
    
    % Update the block number in the current group to the new shuffled value
    group{:, 1} = shuffledBlockRemap(i);  % Replace block number (first column)
    
    % Extract the prefix of the task match (i.e., ignore the last two characters)
    currentTaskMatch = group{1, 4};  % Assuming task match is a column name
    currentTaskMatchPrefix = currentTaskMatch(1:end-2);  % Remove the last two characters
    
    % Check if the task match prefix of the current block is the same as the last one
    if strcmp(currentTaskMatchPrefix, lastTaskMatchPrefix)
        % Find another block with a different task match prefix
        for j = i+1:length(shuffledBlockOrder)
            nextGroup = groupedData{j};
            nextTaskMatch = nextGroup{1, 4};
            nextTaskMatchPrefix = nextTaskMatch(1:end-2);  % Remove last two characters
            
            if ~strcmp(nextTaskMatchPrefix, lastTaskMatchPrefix)
                % Swap the blocks
                groupedData{i} = nextGroup;  % Swap current group with next group
                groupedData{j} = group;  % Swap the next group with the current group
                break;
            end
        end
    end
    
    % Store the current task match prefix for the next iteration
    lastTaskMatchPrefix = currentTaskMatchPrefix;
    
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



