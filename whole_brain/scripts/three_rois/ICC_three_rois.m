%%%% CALCULATE THE ICC FOR ONE ROI

% select ROI (dlpfc, tpj, or pre_sma)
roi = 'tpj';

% read in the rearranged matrix for the selected ROI
% the rearranged matrix has the rows as the subjects and runs, and the columns as the edges
% for example, the first row is the first subject's first run, the second row is the first subject's second run, 
% the fifth row is the second subject's first run, etc. (4 runs, 109 subjects = 436 rows total)
% the first column is the first edge, second column is the second edge, etc. (# of edges depends on the ROI)
% for the DLPFC, it has 2207 vertices, so there are 2207 vertices * 379 parcels = 836,453 edges
% for the TPJ, it has 722 vertices, so there are 722 vertices * 379 parcels = 273,638 edges
% for the pre-SMA, it has 209 vertices, so there are 209 vertices * 379 parcels = 79,211 edges

% since the DLPFC has so many edges, it takes a long time to run the ICC on all of them and uses a lot of memory


mat = readmatrix(append('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_roi_', roi, '.csv'));

% load session and condition labels
% session labels are 1 or 2, corresponding to the first or second visit
% condition labels are "M" or "R", corresponding to the Movie or Rest condition
session = readmatrix('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_visit_roi_dlpfc.csv');
cond = readtable('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_condition_roi_dlpfc.csv', 'ReadVariableNames', false);
cond = cond.Var1;
cond = categorical(cond);

% find the number of rows and edges for this ROI
[nRows, nEdges] = size(mat);

% initialize a cell array to store the results
results = cell(nEdges,4);

% start an index to keep track of the row in the results array
idx = 1;

% loop through all of the edges, calculate the ICC for the movie and rest conditions, and calculate the difference
for i = 1:nEdges
    % print progress update:
    if mod(i, 10000) == 0
        disp(i)
    end
    v1m = mat((session==1 & (cond == "M")), i); % get the values for the first visit and movie condition
    v2m = mat((session==2 & (cond == "M")), i); % get the values for the second visit and movie condition
    v1r = mat((session==1 & (cond == "R")), i); % get the values for the first visit and rest condition
    v2r = mat((session==2 & (cond == "R")), i); % get the values for the second visit and rest condition
    vm = cat(2,v1m, v2m); % concatenate the movie values
    vr = cat(2,v1r, v2r); % concatenate the rest values
    result_m = icc(vm, "A-1"); % calculate the ICC for the movie condition
    result_r = icc(vr, "A-1"); % calculate the ICC for the rest condition
    result_diff = result_m - result_r; % calculate the difference between Movie and Rest ICCs
    new_row = {i, result_m, result_r, result_diff}; % store the results in a new row
    results(idx,:) = new_row; % store the new row in the results array
    idx = idx + 1; % update the index
end

% set column names for results
results = cell2table(results, 'VariableNames', {'edge', 'icc_m', 'icc_r', 'icc_diff'});

% save results as csv
writetable(results, append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_2_1_results_', roi, '.csv'));



%%%% PERMUTATION TESTING FOR ICC
% This is permutation testing for comparing the mean ICC between movie and rest in this ROI, not comparing at every edge
roi = 'tpj';
mat = readmatrix(append('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_roi_', roi, '.csv'));
session = readmatrix('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_visit_roi_dlpfc.csv');
cond = readtable('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_condition_roi_dlpfc.csv', 'ReadVariableNames', false);
cond = cond.Var1;
cond = categorical(cond);
[nRows, nEdges] = size(mat);

% load the observed differences between movie and rest ICCs (calculated in the previous section)
observed_diffs = readtable(append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_2_1_results_', roi, '.csv'));
% calculate the observed difference in mean ICC between movie and rest
observed_diff = mean(observed_diffs(:,2)).icc_m - mean(observed_diffs(:,3)).icc_r; 

% set the number of permutations (I used 500 for the TPJ and pre-SMA, but the DLPFC has so many edges that I tried 100 and that didn't even work)
nPerms = 500; % ideally larger than 100 if possible!

% ignore this for now, this was for edge-wise permutation testing
% p_vals = zeros(nEdges,2);

% read in the shuffled condition labels (contains 5000 different shuffles of the condition labels)
perm_labels = readtable('/scratch/st-tv01-1/hcp/reliability/permutations/permuted_condition_labels_5000.csv');

% create a matrix to store all of the results from all edges and permutations
% each row is an edge, each column is a permutation's movie-rest mean ICC difference
all_results = zeros(nEdges, nPerms);


tic
parfor i = 1:nEdges % loop through all of the edges with parallel processing
    % display an update of progress
    if mod(i, 500) == 0
        disp(i)
    end
    idx = 1;
    results_local = cell(nPerms, 5); % initialize a cell array to store the results for this edge
    for p = 1:nPerms % loop through all of the permutations
        cond_labels = categorical(table2array(perm_labels(p,:))); % get the condition labels for this permutation
        v1m = mat((session==1 & (cond_labels == "M")'), i); % get the values for the first visit and movie condition
        v2m = mat((session==2 & (cond_labels == "M")'), i); % get the values for the second visit and movie condition
        v1r = mat((session==1 & (cond_labels == "R")'), i); % get the values for the first visit and rest condition
        v2r = mat((session==2 & (cond_labels == "R")'), i); % get the values for the second visit and rest condition
        vm = cat(2,v1m, v2m); % concatenate the movie values
        vr = cat(2,v1r, v2r); % concatenate the rest values
        result_m = icc(vm, "A-1"); % calculate the ICC for the movie condition
        result_r = icc(vr, "A-1"); % calculate the ICC for the rest condition
        result_diff = result_m - result_r; % calculate the difference between Movie and Rest ICCs
        new_row = {p, i, result_m, result_r, result_diff}; % store the results in a new row
        results_local(idx,:) = new_row; % store the new row in the results array for this edge
        idx = idx + 1; % update the index
    end

    % store the results for this edge in the all_results matrix
    all_results(i,:) = cell2mat(results_local(:,5));;
end
toc

% calculate the mean ICC (across edges) for movie and rest conditions for each permutation
mean_diff = mean(all_results,1); % mean ICC difference for each permutation (mean across edges)

% calculate p-value
p_val = sum(abs(mean_diff) > abs(observed_diff))/nPerms % p-value (proportion of permutations with a mean ICC difference greater than the observed difference

p_val

% for edge-wise, ignore for now...
% writematrix(p_vals, append('/scratch/st-tv01-1/hcp/reliability/redo_icc_p_vals_three_rois_', roi, '.csv'))

% save all_results as csv
writematrix(all_results, append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_2_1_perms_', roi, '.csv'));

% rewrite the above function looping through the permutations first, then the edges
% this will allow us to parallelize the permutation testing

% all_results = cell(nPerms, 4);

% for p = 1:nPerms
%     disp(p)
%     idx = 1;
%     results_local = cell(nEdges, 5);
%     for i = 1:nEdges
%         cond_labels = categorical(table2array(perm_labels(p,:)));
%         v1m = mat((session==1 & (cond_labels == "M")'), i);
%         v2m = mat((session==2 & (cond_labels == "M")'), i);
%         v1r = mat((session==1 & (cond_labels == "R")'), i);
%         v2r = mat((session==2 & (cond_labels == "R")'), i);
%         vm = cat(2,v1m, v2m);
%         vr = cat(2,v1r, v2r);
%         result_m = icc(vm, "1-1");
%         result_r = icc(vr, "1-1");
%         result_diff = result_m - result_r;
%         new_row = {p, i, result_m, result_r, result_diff};
%         results_local(idx,:) = new_row;
%         idx = idx + 1;
%     end
%     mean_r = mean(cell2mat(results_local(:,4)));
%     mean_m = mean(cell2mat(results_local(:,3)));
%     mean_diff = mean(cell2mat(results_local(:,5)));

%     all_results(p,:) = {p, mean_m, mean_r, mean_diff};
% end

% % set column names for results
% all_results = cell2table(all_results, 'VariableNames', {'perm', 'mean_m', 'mean_r', 'mean_diff'});

% % save results as csv
% writetable(all_results, append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_perms_meanICC_', roi, '.csv'));