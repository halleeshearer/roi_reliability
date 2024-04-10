roi <- Sys.getenv("SLURM_ARRAY_TASK_ID")

subject_list_n109 <- read.csv('/home/hallee/project/hcp/targets/m2m4_sub_n109.csv', header = FALSE)
subject_list_n109 <- subject_list_n109[[1]]
conditions <- c("REST1", "REST4", "MOVIE2", "MOVIE4")


results <- c()
for (sub in subject_list_n109) {
        for (cond in conditions) {
                # load csv
                fc_matrix <- as.matrix(read.csv(paste0('/scratch/st-tv01-1/hcp/reliability/matrices/', as.character(sub), '/', cond, '/roi_' ,roi, '.csv'), header = FALSE))
                if (cond == "REST1") {
                        new_row <- c(sub, 'R', 1, as.vector(fc_matrix))
                }
                else if (cond == "REST4") {
                        new_row <- c(sub, 'R', 2, as.vector(fc_matrix))
                }
                else if (cond == "MOVIE2") {
                        new_row <- c(sub, "M", 1, as.vector(fc_matrix))
                }
                else if (cond == "MOVIE4") {
                        new_row <- c(sub, "M", 2, as.vector(fc_matrix))
                }
                results <- rbind(results, new_row)
        }
}
# save the results of this roi as a csv
write.csv(results, file = paste0('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_', roi, '.csv'))
