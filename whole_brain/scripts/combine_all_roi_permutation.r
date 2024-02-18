# combine all permutation results to one csv

results <- data.frame()

for (roi in 1:379) {
    df <- read.csv(paste0('/home/hallee/scratch/hcp/reliability/results/permutation_tests/roi_', roi, '.csv'))
    print(roi)
    results <- rbind(results, df)
}
write.csv(results, '/home/hallee/scratch/hcp/reliability/results/permutation_tests/all_roi_perms.csv')