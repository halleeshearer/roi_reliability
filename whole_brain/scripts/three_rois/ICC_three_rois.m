# TODO: check this mat reading in...
mat = readmatrix('/scratch/st-tv01-1/hcp/reliability/rearranged/matlab_roi_dlpfc.csv');
session = readmatrix('/scratch/st-tv01-1/hcp/reliability/session.csv');
session = session(2:437,2);
cond = readtable('/scratch/st-tv01-1/hcp/reliability/cond.csv');
cond = cond.x;
cond = categorical(cond);

%[nRows, nEdges] = size(mat);
nEdges = 5
results = cell(nEdges,2);

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
    new_row = {i, result_diff};
    results(idx,:) = new_row;
    idx = idx + 1;
end
observed_diffs_edges = cell2mat(results);

% save observed_diffs_edges.mat observed_diffs_edges
csvwrite('/scratch/st-tv01-1/hcp/reliability/whole-brain_icc_diffs.csv', observed_diffs_edges)