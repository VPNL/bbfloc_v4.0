function combine_and_shuffle_blocks_v4(participant)
% Participant folder and file paths
participant_folder = fullfile('/Users', 'ctyagi', 'Desktop', 'bbfloc_2.0', 'psychopy', 'data', participant);

csvfile1 = fullfile(participant_folder, 'static_blocks.csv'); 
csvfile2 = fullfile(participant_folder, 'kosakowski_blocks.csv'); 
csvfile3 = fullfile(participant_folder, 'baseline_blocks.csv');

% Read the CSV files into tables
data1 = readtable(csvfile1);
data2 = readtable(csvfile2);
data3 = readtable(csvfile3);

% Combine the datasets 
data = vertcat(data1, data2);

% Extract block numbers and category numbers (assuming block numbers are in the first column and category in another column)
blockNumbers = data{:, 1};  % Assuming the first column contains the block numbers

% Predefined block remapping (this is fixed and not shuffled)
blockRemap = [2, 3, 5, 6, 8, 10, 11, 13, 14, 16, 17, 19, 20, 22, 24, 25, 27, 28, 30, 31, 33, 34, 36, 38, 39, 41, 42];

% Shuffle blockRemap and use each value once
shuffledBlockRemap = blockRemap(randperm(length(blockRemap)));

% Identify unique block numbers
uniqueBlocks = unique(blockNumbers);

% Initialize cell array to store grouped data by block
groupedData = cell(length(uniqueBlocks), 1);

% Group rows by block number and store them in a cell array
for i = 1:length(uniqueBlocks)
    blockIndices = blockNumbers == uniqueBlocks(i);
    groupedData{i} = data(blockIndices, :);
end

% Define category groups
group1 = [1, 2, 6, 7];  % Category numbers for group 1
group2 = [3, 4, 5, 8, 9];  % Category numbers for group 2

% Separate grouped data by category groups
group1Data = {}; 
group2Data = {};

% Assume groupedData is already populated
for i = 1:length(groupedData)
    currentGroup = groupedData{i};
    currentCategory = currentGroup{1, 3};  % Category number of the current block
    
    % If the block belongs to group 1
    if ismember(currentCategory, group1)
        group1Data{end+1} = currentGroup;  % Append to group1Data
    % If the block belongs to group 2
    elseif ismember(currentCategory, group2)
        group2Data{end+1} = currentGroup;  % Append to group2Data
    end
end

% Step 1: Shuffle the blocks within each group
shuffledGroup1 = group1Data(randperm(length(group1Data)));  % Shuffle group 1
shuffledGroup2 = group2Data(randperm(length(group2Data)));  % Shuffle group 2

% Step 2: Start alternating between shuffled blocks from both groups
alternatedData = {};  % To store the final alternating sequence
group1Idx = 1;  % Index for group1
group2Idx = 1;  % Index for group2

% We want to alternate between group 1 and group 2
while group1Idx <= length(shuffledGroup1) || group2Idx <= length(shuffledGroup2)
    if group1Idx <= length(shuffledGroup1)
        alternatedData{end+1} = shuffledGroup1{group1Idx};  % Add block from group 1
        group1Idx = group1Idx + 1;
    end
    
    if group2Idx <= length(shuffledGroup2)
        alternatedData{end+1} = shuffledGroup2{group2Idx};  % Add block from group 2
        group2Idx = group2Idx + 1;
    end
end

% Now alternatedData contains the blocks in the alternating order
% Ensure there is no consecutive block from the same group
finalAlternatedData = {};

% Start with the first block
finalAlternatedData{end+1} = alternatedData{1};
lastGroup = 'group1' .* ismember(group1, alternatedData{1}{1, 3}) + 'group2' .* ismember(group2, alternatedData{1}{1, 3});  % Keep track of last group

% Add the remaining blocks, ensuring alternation
for i = 2:length(alternatedData)
    currentBlock = alternatedData{i};
    currentGroup = 'group1' ismember(group1, currentBlock{1, 3}) + 'group2' .* ismember(group2, currentBlock{1, 3});
    
    if currentGroup ~= lastGroup  % Alternate group
        finalAlternatedData{end+1} = currentBlock;
        lastGroup = currentGroup;
    end
end

% Now finalAlternatedData should have no consecutive blocks from the same group
% Final block processing, e.g., reassign shuffled block numbers to remapped data
remappedData = cell(length(finalAlternatedData), 1);

for i = 1:length(finalAlternatedData)
    group = finalAlternatedData{i};
    % Assign the shuffled block number (use the shuffled value)
    group{:, 1} = shuffledBlockRemap(i);  % Replace block number (first column) with shuffled value
    remappedData{i} = group;  % Store the group in remappedData
end

% Add baseline data (data3) to remapped data
remappedData2 = vertcat(remappedData, data3);

% Step 6: Sort the data so that blocks are in numerical order
sortedData = sortrows(remappedData2, 1);  % Sorting based on the first column (block number)

% Step 7: Set the onset time for the first trial
sortedData.Onset_time_s_(1) = 0.0;  % First trial onset time is 0.0 seconds

% Step 8: Calculate onset times for subsequent trials based on StimDur
for i = 2:height(sortedData)
    % The onset time of the current trial is the onset time of the previous trial + its duration
    sortedData.Onset_time_s_(i) = sortedData.Onset_time_s_(i-1) + sortedData.StimDur(i-1);
end

% Step 9: Save the result to a new CSV file
outputFile = fullfile(participant_folder, 'shuffled_and_sorted_blocks_with_onsets.csv');
writetable(sortedData, outputFile, 'WriteVariableNames', true);

% Display the final sorted data with onset times
disp(sortedData);

end
