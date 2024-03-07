# TODO: check this mat reading in...
roi = 'dlpfc';
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


%observed_diffs_edges = cell2mat(results);

% save observed_diffs_edges.mat observed_diffs_edges
csvwrite(append('/scratch/st-tv01-1/hcp/reliability/results/three_rois/icc_', roi, '.csv'), results)