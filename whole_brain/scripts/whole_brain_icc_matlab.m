%% COPY UPDATED SCRIPT FROM SOCKEYE

mat = readmatrix('/scratch/st-tv01-1/hcp/reliability/whole-brain_rearranged_malab.csv');
session = readmatrix('/scratch/st-tv01-1/hcp/reliability/session.csv');
session = session(2:437,2);
cond = readtable('/scratch/st-tv01-1/hcp/reliability/cond.csv');
cond = cond.x;
cond = categorical(cond);

[nRows, nEdges] = size(mat);
%nEdges = 5
results = cell(nEdges,4);

idx = 1;

for i = 1:nEdges
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
observed_diffs_edges = cell2mat(results);

% save observed_diffs_edges.mat observed_diffs_edges
csvwrite('/scratch/st-tv01-1/hcp/reliability/whole-brain_icc.csv', observed_diffs_edges)



%%%% PERMUTATIONS:
mat = readmatrix('/scratch/st-tv01-1/hcp/reliability/whole-brain_rearranged_malab.csv');
observed_diffs = readmatrix('/scratch/st-tv01-1/hcp/reliability/whole-brain_icc_diffs.csv');
session = readmatrix('/scratch/st-tv01-1/hcp/reliability/session.csv');
session = session(2:437,2);
cond = readtable('/scratch/st-tv01-1/hcp/reliability/cond.csv');
cond = cond.x;
cond = categorical(cond);
nPerms = 1000;
%[nRows, nEdges] = size(mat);
nEdges=20;
%results = cell(nPerms,3);
results = cell(nPerms, 3);
p_vals = zeros(nEdges,2);
perm_labels = readtable('/scratch/st-tv01-1/hcp/reliability/permutations/permuted_condition_labels_5000.csv');


tic
parfor i = 1:nEdges %nEdges
    disp(i)
    idx = 1;
    results_local = cell(nPerms, 3);
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
        new_row = {p, i, result_diff};
        results_local(idx,:) = new_row;
        idx = idx + 1;
    end
    this_edge_perms = cell2mat(results_local(:,3));
    this_edge_obs = observed_diffs(i,2);
    this_edge_p = (sum(abs(this_edge_perms) > abs(this_edge_obs)))/nPerms;
    p_vals(i,:) = [i, this_edge_p];
end
toc

csvwrite('/scratch/st-tv01-1/hcp/reliability/whole-brain_icc_edge_pvals.csv', p_vals)