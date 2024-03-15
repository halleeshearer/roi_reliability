
roi = 'pre_sma';
mat = readmatrix(append('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_roi_', roi, '.csv'));
session = readmatrix('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_visit_roi_dlpfc.csv');
cond = readtable('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_condition_roi_dlpfc.csv', 'ReadVariableNames', false);
cond = cond.Var1;
cond = categorical(cond);

[nRows, nEdges] = size(mat);
%nEdges = 5
results = cell(nEdges,4);

idx = 1;

for i = 1:nEdges
    % print progress update:
    if mod(i, 100) == 0
        disp(i)
    end
    v1m = mat((session==1 & (cond == "M")), i);
    v2m = mat((session==2 & (cond == "M")), i);
    v1r = mat((session==1 & (cond == "R")), i);
    v2r = mat((session==2 & (cond == "R")), i);
    vm = cat(2,v1m, v2m);
    vr = cat(2,v1r, v2r);
    result_m = icc(vm, "1-1");
    result_r = icc(vr, "1-1");
    result_diff = result_m - result_r;
    new_row = {i, result_m, result_r, result_diff};
    results(idx,:) = new_row;
    idx = idx + 1;
end
% set column names for results
results = cell2table(results, 'VariableNames', {'edge', 'icc_m', 'icc_r', 'icc_diff'});


% save results as csv
writetable(results, append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_results_', roi, '.csv'));



%%%% PERMUTATION TESTING
%%%% PERMUTATIONS:
roi = 'dlpfc';
mat = readmatrix(append('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_roi_', roi, '.csv'));
observed_diffs = readtable(append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_results_', roi, '.csv'));
session = readmatrix('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_visit_roi_dlpfc.csv');
cond = readtable('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/matlab_condition_roi_dlpfc.csv', 'ReadVariableNames', false);
cond = cond.Var1;
cond = categorical(cond);

nPerms = 100;
[nRows, nEdges] = size(mat);
%nEdges=20;
%results = cell(nPerms,3);
results = cell(nPerms, 5);
p_vals = zeros(nEdges,2);
perm_labels = readtable('/scratch/st-tv01-1/hcp/reliability/permutations/permuted_condition_labels_5000.csv');

% create a matrix to store all of the results from all edges and permutations
all_results = zeros(nEdges, nPerms);


tic
parfor i = 1:nEdges %nEdges
    % display an update of progress
    if mod(i, 1000) == 0
        disp(i)
    end
    idx = 1;
    results_local = cell(nPerms, 5);
    for p = 1:nPerms
        cond_labels = categorical(table2array(perm_labels(p,:)));
        v1m = mat((session==1 & (cond_labels == "M")'), i);
        v2m = mat((session==2 & (cond_labels == "M")'), i);
        v1r = mat((session==1 & (cond_labels == "R")'), i);
        v2r = mat((session==2 & (cond_labels == "R")'), i);
        vm = cat(2,v1m, v2m);
        vr = cat(2,v1r, v2r);
        result_m = icc(vm, "1-1");
        result_r = icc(vr, "1-1");
        result_diff = result_m - result_r;
        new_row = {p, i, result_m, result_r, result_diff};
        results_local(idx,:) = new_row;
        idx = idx + 1;
    end
    this_edge_perms = cell2mat(results_local(:,5)); 
    this_edge_obs = observed_diffs(i,4);
    this_edge_p = (sum(abs(this_edge_perms) > abs(this_edge_obs.icc_diff)))/nPerms;
    p_vals(i,:) = [i, this_edge_p];
    all_results(i,:) = this_edge_perms;
end
toc

% parfor i = 1:10
%     disp(i)
% end

writematrix(p_vals, append('/scratch/st-tv01-1/hcp/reliability/icc_p_vals_three_rois_', roi, '.csv'))

% save all_results as csv
writematrix(all_results, append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_perms_', roi, '.csv'));

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