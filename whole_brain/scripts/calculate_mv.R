library(ReX)
library(data.table)

results <- data.frame(roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())
roi <- Sys.getenv("SLURM_ARRAY_TASK_ID")
input_mat <- fread(paste0('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_', roi, '.csv'))

for (cond in c("M", "R")) {
    cond_mat <- input_mat[input_mat[[3]]==cond,]
    end_of_rows <- dim(cond_mat)[2]
    data <- as.matrix(cond_mat[, 5:end_of_rows])
    subID <- as.matrix(cond_mat[,2])
    session <- as.matrix(cond_mat[,4])

    Dmax <- dist(data, method = "euclidian")

    i2c2_result <- calc_i2c2(Dmax, subID, as.matrix(session))
    discr_result <- calc_discriminability(Dmax, subID)
    finger_result <- calc_fingerprinting(Dmax, subID)

    result <- data.frame(roi=roi, cond=cond, i2c2=i2c2_result, discr=discr_result, finger=finger_result)
    results <- rbind(results, result)
}
write.csv(results, paste0('/scratch/st-tv01-1/hcp/reliability/results/roi_', roi, '_results.csv'), row.names=FALSE)