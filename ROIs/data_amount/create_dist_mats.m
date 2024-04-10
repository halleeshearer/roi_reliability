% create distance matrices that will be used as input for ReX MV reliability analyses using matlab to improve efficiency
% for each roi:
% input: rearranged matrix for a given roi
% output: distance matrix for a given roi

roi = 'dlpfc' % change to do a different ROI

trs = 20:20:680;
num_of_trs = numel(trs);

% loop through TRs: starting at 20, in 20 TR increments, until 680
for i = 1:num_of_trs
    tr = trs(i);
    % print update
    fprintf('Calculating distance matrix for %s at %d TRs\n', roi, tr)

    % load the rearranged matrix as a table (because there are some strings and some numbers)
    m = readmatrix(sprintf('/home/hallee/scratch/hcp/reliability/data_amount/rearranged_matrices/roi_%s_%d.csv', roi, tr));

    % select just the FC columns
    % data = m(:,5:end); Not applicable for the rearranged matrices that start with matlab_

    % transform the table to an array
    %data = table2array(data);  

    % calculate the distance matrix with euclidian distance
    % the output of pdist() is a vector, so squareform turns the vector into a square matrix
    D = squareform(pdist(m));

    %% checking if the output from this is the same as the distance matrix I get from Ting's rex dist() function...
    % yes it is!

    % export the distance matrix as csv
    csvwrite(sprintf('/home/hallee/scratch/hcp/reliability/data_amount/dist_mats/roi_%s_%dTR_dist.csv', roi, tr), D)

end


