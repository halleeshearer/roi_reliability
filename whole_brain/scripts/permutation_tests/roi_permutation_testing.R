# # currently testing

# library(ReX)
# library(data.table)

# # for a single ROI
# roi <- 2 # choosing a small one to start with

# # load ROI's rearranged matrix
# # this step can take a bit of time, but is faster with fread than read.csv
# input_mat <- fread(paste0('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_', roi, '.csv'))

# # create results dataframe
# results <- data.frame(permutation = numeric(), roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())

# # compute a distance matrix with all subjects and runs (4 total) 
# end_of_rows <- dim(input_mat)[2] # this will the the index for the last edge of the input_mat
# data <- as.matrix(input_mat[, 5:end_of_rows])
# Dmax <- dist(data, method = "euclidian") # this step also takes a while, longer than fread, but we should only have to do it once per roi this way
# Dmax <- as.matrix(Dmax) # need to change this to a matrix in order to index it by condition

# sub <- as.matrix(input_mat[,2])
# session <- as.matrix(input_mat[,4])



# # permutations!

# # load the permuted condition data
# permuted_conds <- fread('/home/hallee/scratch/hcp/reliability/permutations/permuted_condition_labels.csv')
# # the dimensions of permuted_conds are 1000,436 in this case
# # each row represents the permuted condition labels for one permutation

# sub <- as.matrix(sub[as.character(permuted_conds[1,])=="M"])

# # same for session
# session <- as.matrix(session[as.character(permuted_conds[1,])=="M"])

# for (perm in 1:20) { # increase to 1000 ideally
#     permuted_cond <- as.character(permuted_conds[perm,])
#     #permuted_cond <- as.character(permuted_cond)

#     # index the Dmax with the condition of interest
#     for (cond in c("M", "R")) {
#         Dmax_filtered <- Dmax[permuted_cond==cond, permuted_cond==cond]
#         i2c2 <- calc_i2c2(Dmax_filtered, sub, session)
#         discr <- calc_discriminability(Dmax_filtered, sub)
#         finger <- calc_fingerprinting(Dmax_filtered, sub)
#         result <- data.frame(permutation = perm, roi = roi, cond = cond, i2c2 = i2c2, discr = discr, finger = finger)
#         results <- rbind(results, result)
#     }
# }




library(ReX)
library(data.table)


roi <- Sys.getenv("SLURM_ARRAY_TASK_ID")
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


