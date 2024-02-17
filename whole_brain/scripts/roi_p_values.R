# calculate p values from stats

library(dplyr)
library(magrittr)

# load observed data/results
obs <- read.csv('/scratch/st-tv01-1/hcp/reliability/results/all_rois_mv_results.csv')

# for one ROI:
roi <- 1

# load permutation results
perms <- read.csv(paste0('/home/hallee/scratch/hcp/reliability/results/permutation_tests/roi_', roi, '.csv'))

m_perms <- perms %>% filter(cond == "M")
r_perms <- perms %>% filter(cond == "R")

i2c2_diff_perms <- m_perms$i2c2 - r_perms$i2c2
discr_diff_perms <- m_perms$discr - r_perms$discr
finger_diff_perms <- m_perms$finger - r_perms$finger

i2c2_obs <- obs %>% filter(roi == roi) %>% select(i2c2_diff)
discr_obs <- obs %>% filter(roi == roi) %>% select(discr_diff)
finger_obs <- obs %>% filter(roi == roi) %>% select(finger_diff)

i2c2_p <- sum(i2c2_diff_perms > i2c2_obs) / length(i2c2_diff_perms)
discr_p <- sum(discr_diff_perms > discr_obs) / length(discr_diff_perms)
finger_p <- sum(finger_diff_perms > finger_obs) / length(finger_diff_perms)