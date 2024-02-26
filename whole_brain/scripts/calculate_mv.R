library(ReX)
library(data.table)

# # results <- data.frame(roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())
# # roi <- Sys.getenv("SLURM_ARRAY_TASK_ID")
# # input_mat <- fread(paste0('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_', roi, '.csv'))

# # for (cond in c("M", "R")) {
# #     cond_mat <- input_mat[input_mat[[3]]==cond,]
# #     end_of_rows <- dim(cond_mat)[2]
# #     data <- as.matrix(cond_mat[, 5:end_of_rows])
# #     subID <- as.matrix(cond_mat[,2])
# #     session <- as.matrix(cond_mat[,4])

# #     Dmax <- dist(data, method = "euclidian")

# #     i2c2_result <- calc_i2c2(Dmax, subID, as.matrix(session))
# #     discr_result <- calc_discriminability(Dmax, subID)
# #     finger_result <- calc_fingerprinting(Dmax, subID)

# #     result <- data.frame(roi=roi, cond=cond, i2c2=i2c2_result, discr=discr_result, finger=finger_result)
# #     results <- rbind(results, result)
# # }
# # write.csv(results, paste0('/scratch/st-tv01-1/hcp/reliability/results/roi_', roi, '_results.csv'), row.names=FALSE)




# library(ReX)
# library(data.table)

# results <- data.frame(roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())

# subID <- as.matrix(rep(1:109, each=2))
# session <- as.matrix(rep(1:2, 109))
# conditions <- as.matrix(rep(c("R", "R", "M", "M"), 109))

# for (roi in 1:379) {
#     input_dist <- fread(paste0('/scratch/st-tv01-1/hcp/reliability/dist_mats/roi_', roi, '_dist.csv'))

#     for (cond in c("M", "R")) {
#         cond_dist <- input_dist[permuted_cond==cond, permuted_cond==cond]
#         i2c2_result <- calc_i2c2(cond_dist, subID, as.matrix(session))
#         discr_result <- calc_discriminability(cond_dist, subID)
#         finger_result <- calc_fingerprinting(cond_dist, subID)

#         result <- data.frame(roi=roi, cond=cond, i2c2=i2c2_result, discr=discr_result, finger=finger_result)
#         results <- rbind(results, result)
#     }
#     write.csv(results, paste0('/scratch/st-tv01-1/hcp/reliability/results/roi_', roi, '_results.csv'), row.names=FALSE)
# }




# calculate multivariate reliability measures for each ROI for movie, rest and the difference between movie and rest (M minus R)

results <- data.frame(roi = numeric(), i2c2_m = numeric(), i2c2_r = numeric(), i2c2_diff = numeric(), discr_m = numeric(), discr_r = numeric(), discr_diff = numeric(), finger_m = numeric(), finger_r = numeric(), finger_diff = numeric())
conditions <- as.matrix(rep(c("R", "R", "M", "M"), 109))
subID <- as.matrix(rep(1:109, each=2))
session <- as.matrix(rep(1:2, 109))

for (roi in 366:379) {
    input_dist <- as.matrix(fread(paste0('/scratch/st-tv01-1/hcp/reliability/dist_mats/roi_', roi, '_dist.csv')))

    dist_m <- input_dist[conditions=="M", conditions=="M"]
    dist_r <- input_dist[conditions=="R", conditions=="R"]
    print(roi)

    i2c2_m <- calc_i2c2(dist_m, subID, as.matrix(session))
    discr_m <- calc_discriminability(dist_m, subID)
    finger_m <- calc_fingerprinting(dist_m, subID)

    i2c2_r <- calc_i2c2(dist_r, subID, as.matrix(session))
    discr_r <- calc_discriminability(dist_r, subID)
    finger_r <- calc_fingerprinting(dist_r, subID)

    i2c2_diff <- i2c2_m - i2c2_r
    discr_diff <- discr_m - discr_r
    finger_diff <- finger_m - finger_r


    result <- data.frame(roi=roi, i2c2_m=i2c2_m, i2c2_r=i2c2_r, i2c2_diff=i2c2_diff, discr_m = discr_m, discr_r = discr_r, discr_diff = discr_diff, finger_m=finger_m, finger_r = finger_r, finger_diff = finger_diff)
    results <- rbind(results, result)
}

write.csv(results, paste0('/scratch/st-tv01-1/hcp/reliability/results/all_rois_mv_results.csv'), row.names=FALSE)



