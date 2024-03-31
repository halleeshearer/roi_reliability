library(ReX)
library(data.table)


# calculate multivariate reliability measures for each ROI for movie, rest and the difference between movie and rest (M minus R)

results <- data.frame(roi = numeric(), tr = numeric(), i2c2_m = numeric(), i2c2_r = numeric(), i2c2_diff = numeric(), discr_m = numeric(), discr_r = numeric(), discr_diff = numeric(), finger_m = numeric(), finger_r = numeric(), finger_diff = numeric())
conditions <- as.matrix(rep(c("R", "R", "M", "M"), 109))
subID <- as.matrix(rep(1:109, each=2))
session <- as.matrix(rep(1:2, 109))


for (roi in c("pre_sma", "dlpfc", "tpj")) {
    for (tr in seq(20, 680, 20)) {
        input_dist <- as.matrix(fread(paste0('/home/hallee/scratch/hcp/reliability/data_amount/dist_mats/roi_', roi, '_', tr, 'TR_dist.csv')))

        dist_m <- input_dist[conditions == "M", conditions == "M"]
        dist_r <- input_dist[conditions == "R", conditions == "R"]
        print(paste0(roi, ' ', tr))

        i2c2_m <- calc_i2c2(dist_m, subID, as.matrix(session))
        discr_m <- calc_discriminability(dist_m, subID)
        finger_m <- calc_fingerprinting(dist_m, subID)

        i2c2_r <- calc_i2c2(dist_r, subID, as.matrix(session))
        discr_r <- calc_discriminability(dist_r, subID)
        finger_r <- calc_fingerprinting(dist_r, subID)

        i2c2_diff <- i2c2_m - i2c2_r
        discr_diff <- discr_m - discr_r
        finger_diff <- finger_m - finger_r


        result <- data.frame(roi=roi, tr = tr, i2c2_m=i2c2_m, i2c2_r=i2c2_r, i2c2_diff=i2c2_diff, discr_m = discr_m, discr_r = discr_r, discr_diff = discr_diff, finger_m=finger_m, finger_r = finger_r, finger_diff = finger_diff)
        results <- rbind(results, result)
    }
}

write.csv(results, paste0('/scratch/st-tv01-1/hcp/reliability/data_amount/three_rois_mv_results_data_amount.csv'), row.names=FALSE)



####### PERMUTATION TESTING #######

library(ReX)
library(data.table)


roi <- 'tpj'
n_perms <- 5000

results <- data.frame(permutation = numeric(), roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())

Dmax <- read.csv(paste0('/scratch/st-tv01-1/hcp/reliability/dist_mats/roi_', roi, '_dist.csv'), header = FALSE)

permuted_conds <- fread('/home/hallee/scratch/hcp/reliability/permutations/permuted_condition_labels_5000.csv')

sub <- as.matrix(rep(1:109, each=2))

session <- as.matrix(rep(1:2, 109))

for (perm in 1:n_perms) { 
    
    permuted_cond <- as.character(permuted_conds[perm,])
    # print update of progress
    if (perm %% 100 == 0) {
        print(paste0("Permutation ", perm, " of ", n_perms, " for ROI ", roi))
    }
    # index the Dmax with the condition of interest
    for (cond in c("M", "R")) {
        Dmax_filtered <- Dmax[permuted_cond==cond, permuted_cond==cond]
        i2c2 <- calc_i2c2(Dmax_filtered, sub, session)
        discr <- calc_discriminability(Dmax_filtered, sub)
        finger <- calc_fingerprinting(Dmax_filtered, sub)
        result <- data.frame(permutation = perm, roi = roi, cond = cond, i2c2 = i2c2, discr = discr, finger = finger)
        results <- rbind(results, result)
    }
}

# save results
write.csv(results, paste0('/home/hallee/scratch/hcp/reliability/results/permutation_tests/roi_', roi, '.csv'))



# for each permutation, calculate the difference between movie and rest

# create dataframe to store the results
diff_results <- data.frame(permutation = numeric(), i2c2_diff = numeric(), discr_diff = numeric(), finger_diff = numeric())

for (perm in 1:n_perms) {
    # filter results by permutation
    this_perm <- results[results$permutation == perm,]
    # calculate the difference between movie and rest for each measure
    diff_i2c2 <- this_perm[this_perm$cond == "M", "i2c2"] - this_perm[this_perm$cond == "R", "i2c2"]
    diff_discr <- this_perm[this_perm$cond == "M", "discr"] - this_perm[this_perm$cond == "R", "discr"]
    diff_finger <- this_perm[this_perm$cond == "M", "finger"] - this_perm[this_perm$cond == "R", "finger"]  
    # add the differences to the diff_results dataframe
    diff_result <- data.frame(permutation = perm, i2c2_diff = diff_i2c2, discr_diff = diff_discr, finger_diff = diff_finger)
    diff_results <- rbind(diff_results, diff_result)
}

# save the difference results
write.csv(diff_results, paste0('/home/hallee/scratch/hcp/reliability/results/permutation_tests/roi_', roi, '_diffs.csv'))


# calculate p values
# read in the observed difference
obs <- read.csv(paste0('/scratch/st-tv01-1/hcp/reliability/results/three_rois/three_rois_mv_results.csv'))
obs_i2c2 <- obs$i2c2_diff[obs$roi == roi]
obs_discr <- obs$discr_diff[obs$roi == roi]
obs_finger <- obs$finger_diff[obs$roi == roi]

# calculate p for each measure
i2c2_p <- sum(abs(diff_results$i2c2_diff) > abs(obs_i2c2)) / nrow(diff_results)
discr_p <- sum(abs(diff_results$discr_diff) > abs(obs_discr)) / nrow(diff_results)
finger_p <- sum(abs(diff_results$finger_diff) > abs(obs_finger)) / nrow(diff_results)

# save p values for this roi
p_values <- data.frame(roi = roi, i2c2_p = i2c2_p, discr_p = discr_p, finger_p = finger_p)
write.csv(p_values, paste0('/scratch/st-tv01-1/hcp/reliability/results/three_rois/', roi, '_p_values.csv'), row.names = FALSE)
