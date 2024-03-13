% create distance matrices that will be used as input for ReX MV reliability analyses using matlab to improve efficiency
% for each roi:
% input: rearranged matrix for a given roi
% output: distance matrix for a given roi

roi = 1

% load the rearranged matrix as a table (because there are some strings and some numbers)
m = readtable(sprintf('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_%d.csv', roi));

% select just the FC columns
data = m(:,5:end);

% transform the table to an array
data = table2array(data); 

% calculate the distance matrix with euclidian distance
% the output of pdist() is a vector, so squareform turns the vector into a square matrix
D = squareform(pdist(data));

%% checking if the output from this is the same as the distance matrix I get from Ting's rex dist() function...
% yes it is!

% export the distance matrix as csv
csvwrite(sprintf('/scratch/st-tv01-1/hcp/reliability/dist_mats/roi_%d_dist.csv', roi), D)


% as a for loop across rois:

num_of_rois = 379

for roi = 1-379
    % load the rearranged matrix as a table (because there are some strings and some numbers)
    m = readtable(sprintf('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_%d.csv', roi));

    % select just the FC columns
    data = m(:,5:end);

    % transform the table to an array
    data = table2array(data); 

    % calculate the distance matrix with euclidian distance
    % the output of pdist() is a vector, so squareform turns the vector into a square matrix
    D = squareform(pdist(data));

    % export the distance matrix as csv
    csvwrite(sprintf('/scratch/st-tv01-1/hcp/reliability/dist_mats/roi_%d_dist.csv', roi), D)
end




D = squareform(pdist(results));

csvwrite(sprintf('/scratch/st-tv01-1/hcp/reliability/dist_mats/roi_%d_dist.csv', roi), D)