rois = ["dlpfc", "tpj", "pre_sma"]

subject_list_n109 = readtable('/home/hallee/project/hcp/targets/m2m4_sub_n109.csv', 'ReadVariableNames', false);
subject_list_n109 = subject_list_n109.Var1;
conditions = {'REST1', 'REST4', 'MOVIE2', 'MOVIE4'};
num_subjects = numel(subject_list_n109);
num_conditions = numel(conditions);
trs = 20:20:680;
num_of_trs = numel(trs);

% loop through TRs: starting at 20, in 20 TR increments, until 680
parfor i = 1:num_of_trs
    tr = trs(i);

    % loop through rois
    for roi = rois

        % print progress
        disp(['Processing ROI: ', roi, ' with ', num2str(tr), ' TRs']);
        fc_matrix = csvread(append('/scratch/st-tv01-1/hcp/reliability/matrices/three_rois/data_amount/', num2str(subject_list_n109(1)), '/', conditions{1}, '_', roi, '_', num2str(tr), 'TRs.csv'));
        [num_rows, num_cols] = size(fc_matrix);
        num_edges = num_rows * num_cols;

        % save the results in a matrix:
        results = zeros(num_subjects * num_conditions, num_edges);

        % save subject number in a separate vector
        subject_numbers = zeros(num_subjects * num_conditions, 1);

        % save condition in a separate vector of strings
        condition = strings(num_subjects * num_conditions, 1);

        % save visit in a separate vector
        visit = zeros(num_subjects * num_conditions, 1);

        for sub = 1:num_subjects
            % print progress
            disp(['Processing subject ', num2str(sub), ' of ', num2str(num_subjects)]);
            for cond = 1:num_conditions
                fc_matrix = csvread(append('/scratch/st-tv01-1/hcp/reliability/matrices/three_rois/data_amount/', num2str(subject_list_n109(sub)), '/', conditions{cond}, '_', roi, '_', num2str(tr), 'TRs.csv'));
                results(((sub-1) * num_conditions + cond),:) = fc_matrix(:)';
                subject_numbers((sub - 1) * num_conditions + cond) = subject_list_n109(sub);
                if strcmp(conditions{cond}, 'REST1')
                    condition((sub - 1) * num_conditions + cond) = 'R';
                    visit((sub - 1) * num_conditions + cond) = 1;
                elseif strcmp(conditions{cond}, 'REST4')
                    condition((sub - 1) * num_conditions + cond) = 'R';
                    visit((sub - 1) * num_conditions + cond) = 2;
                elseif strcmp(conditions{cond}, 'MOVIE2')
                    condition((sub - 1) * num_conditions + cond) = 'M';
                    visit((sub - 1) * num_conditions + cond) = 1;
                elseif strcmp(conditions{cond}, 'MOVIE4')
                    condition((sub - 1) * num_conditions + cond) = 'M';
                    visit((sub - 1) * num_conditions + cond) = 2;
                end
            end
        end


        % check if there are any empty cells in the results
        empty_cells = nnz(results == 0);
        disp(['Number of empty cells: ', num2str(empty_cells)]);

        % Remove empty cells from results
        results = results(~all(results == 0, 2), :);

        % Save the results of this ROI and TR as a CSV
        writematrix(results, append('/scratch/st-tv01-1/hcp/reliability/data_amount/rearranged_matrices/roi_', roi, '_', num2str(tr), '.csv'));
    

    % Save the subject numbers, conditions, and visits as a CSV
    writematrix(subject_numbers, append('/scratch/st-tv01-1/hcp/reliability/data_amount/matlab_subject_numbers_roi_', roi, '.csv'));
    writematrix(condition, append('/scratch/st-tv01-1/hcp/reliability/data_amount/matlab_condition_roi_', roi, '.csv'));
    writematrix(visit, append('/scratch/st-tv01-1/hcp/reliability/data_amount/matlab_visit_roi_', roi, '.csv'));
    
    end

end