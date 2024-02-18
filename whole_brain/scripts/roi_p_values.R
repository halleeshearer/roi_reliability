# calculate p values from stats

library(dplyr)
library(magrittr)

# load observed data/results
obs <- read.csv('/scratch/st-tv01-1/hcp/reliability/results/all_rois_mv_results.csv')
perms <- read.csv(paste0('/home/hallee/scratch/hcp/reliability/results/permutation_tests/all_roi_perms.csv'))

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

    i2c2_p <- sum(i2c2_diff_perms > i2c2_obs[['i2c2_diff']]) / length(i2c2_diff_perms)
    discr_p <- sum(discr_diff_perms > discr_obs[['discr_diff']]) / length(discr_diff_perms)
    finger_p <- sum(finger_diff_perms > finger_obs[['finger_diff']]) / length(finger_diff_perms)

    new_row <- data.frame(roi = r, i2c2_p = i2c2_p, discr_p = discr_p, finger_p = finger_p)
    results <- rbind(results, new_row)
}

# save results as csv
write.csv(results, '/scratch/st-tv01-1/hcp/reliability/results/all_rois_p_values.csv', row.names = FALSE)
