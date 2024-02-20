# calculate p values from stats

library(dplyr)
library(magrittr)

# load observed data/results
obs <- read.csv('/scratch/st-tv01-1/hcp/reliability/results/all_rois_mv_results.csv')
perms <- read.csv(paste0('/home/hallee/scratch/hcp/reliability/results/permutation_tests/all_roi_perms.csv'))


# one-tailed (M>R)
# results <- data.frame()

# for (r in 1:379) {

#     m_perms <- perms %>% filter(cond == "M", roi == r)
#     r_perms <- perms %>% filter(cond == "R", roi == r)

#     i2c2_diff_perms <- m_perms$i2c2 - r_perms$i2c2
#     discr_diff_perms <- m_perms$discr - r_perms$discr
#     finger_diff_perms <- m_perms$finger - r_perms$finger

#     i2c2_obs <- obs %>% filter(roi == r) %>% select(i2c2_diff)
#     discr_obs <- obs %>% filter(roi == r) %>% select(discr_diff)
#     finger_obs <- obs %>% filter(roi == r) %>% select(finger_diff)

#     i2c2_p <- sum(i2c2_diff_perms > i2c2_obs[['i2c2_diff']]) / length(i2c2_diff_perms)
#     discr_p <- sum(discr_diff_perms > discr_obs[['discr_diff']]) / length(discr_diff_perms)
#     finger_p <- sum(finger_diff_perms > finger_obs[['finger_diff']]) / length(finger_diff_perms)

#     new_row <- data.frame(roi = r, i2c2_p = i2c2_p, discr_p = discr_p, finger_p = finger_p)
#     results <- rbind(results, new_row)
# }

# # save results as csv
# write.csv(results, '/scratch/st-tv01-1/hcp/reliability/results/all_rois_p_values.csv', row.names = FALSE)


# two-tailed (M!=R)
# now the p value is the proportion of abs(permutations) that are more extreme than the abs(observed value)

results <- data.frame()

for (r in 1:379) {

    m_perms <- perms %>% filter(cond == "M", roi == r)
    r_perms <- perms %>% filter(cond == "R", roi == r)

    i2c2_diff_perms <- m_perms$i2c2 - r_perms$i2c2
    discr_diff_perms <- m_perms$discr - r_perms$discr
    finger_diff_perms <- m_perms$finger - r_perms$finger

    i2c2_obs <- obs %>% filter(roi == r) %>% select(i2c2_diff)
    discr_obs <- obs %>% filter(roi == r) %>% select(discr_diff)
    finger_obs <- obs %>% filter(roi == r) %>% select(finger_diff)

    i2c2_p <- sum(abs(i2c2_diff_perms) > abs(i2c2_obs[['i2c2_diff']])) / length(i2c2_diff_perms)
    discr_p <- sum(abs(discr_diff_perms) > abs(discr_obs[['discr_diff']])) / length(discr_diff_perms)
    finger_p <- sum(abs(finger_diff_perms) > abs(finger_obs[['finger_diff']])) / length(finger_diff_perms)

    new_row <- data.frame(roi = r, i2c2_p = i2c2_p, discr_p = discr_p, finger_p = finger_p)
    results <- rbind(results, new_row)
}

write.csv(results, '/scratch/st-tv01-1/hcp/reliability/results/all_rois_p_values_two-way.csv', row.names = FALSE)

# correct for the p-values with fdr within a measure:
corrected_p_fdr_i2c2 <- p.adjust(results$i2c2_p, method = "fdr")
corrected_p_fdr_discr <- p.adjust(results$discr_p, method = "fdr")
corrected_p_fdr_finger <- p.adjust(results$finger_p, method = "fdr")

# create an index for the significant p-values (fdr corrected) where 1 is M>R and 2 is M<R
#significant_p_i2c2 <- ifelse(corrected_p_fdr_i2c2 < 0.05, ifelse(results$i2c2_p < 0.5, 1, 2), 0)

directional_sig_p_i2c2 <- data.frame(roi = results$roi, p = corrected_p_fdr_i2c2, m_better = ifelse(corrected_p_fdr_i2c2 < 0.05, ifelse(obs$i2c2_diff > 0, 1, -1), 0))
directional_sig_p_finger <- data.frame(roi = results$roi, p = corrected_p_fdr_finger, m_better = ifelse(corrected_p_fdr_finger < 0.05, ifelse(obs$finger_diff > 0, 1, -1), 0))
directional_sig_p_discr <- data.frame(roi = results$roi, p = corrected_p_fdr_discr, m_better = ifelse(corrected_p_fdr_discr < 0.05, ifelse(obs$discr_diff > 0, 1, -1), 0))

write.csv(directional_sig_p_i2c2, '/scratch/st-tv01-1/hcp/reliability/results/directional_sig_p_i2c2.csv', row.names = FALSE)
write.csv(directional_sig_p_finger, '/scratch/st-tv01-1/hcp/reliability/results/directional_sig_p_finger.csv', row.names = FALSE)
write.csv(directional_sig_p_discr, '/scratch/st-tv01-1/hcp/reliability/results/directional_sig_p_discr.csv', row.names = FALSE)

# correct across ALL p values
# create a vector of all p values
all_p_values <- c(results$i2c2_p, results$discr_p, results$finger_p)

# correct for the p-values with fdr across all measures
corrected_p_fdr_all <- p.adjust(all_p_values, method = "fdr")

# separate by measure again
corrected_p_fdr_i2c2_all <- corrected_p_fdr_all[1:379]
corrected_p_fdr_discr_all <- corrected_p_fdr_all[380:758]
corrected_p_fdr_finger_all <- corrected_p_fdr_all[759:1137]

# create an index for the significant p-values (fdr corrected) where 1 is M>R and 2 is M<R
directional_sig_p_i2c2_all <- data.frame(roi = results$roi, p = corrected_p_fdr_i2c2_all, m_better = ifelse(corrected_p_fdr_i2c2_all < 0.05, ifelse(obs$i2c2_diff > 0, 1, -1), 0))
directional_sig_p_finger_all <- data.frame(roi = results$roi, p = corrected_p_fdr_finger_all, m_better = ifelse(corrected_p_fdr_finger_all < 0.05, ifelse(obs$finger_diff > 0, 1, -1), 0))
directional_sig_p_discr_all <- data.frame(roi = results$roi, p = corrected_p_fdr_discr_all, m_better = ifelse(corrected_p_fdr_discr_all < 0.05, ifelse(obs$discr_diff > 0, 1, -1), 0))

write.csv(directional_sig_p_i2c2_all, '/scratch/st-tv01-1/hcp/reliability/results/directional_sig_p_i2c2_all.csv', row.names = FALSE)
write.csv(directional_sig_p_finger_all, '/scratch/st-tv01-1/hcp/reliability/results/directional_sig_p_finger_all.csv', row.names = FALSE)
write.csv(directional_sig_p_discr_all, '/scratch/st-tv01-1/hcp/reliability/results/directional_sig_p_discr_all.csv', row.names = FALSE)
