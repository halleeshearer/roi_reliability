# load observed data
obs <- read.csv('/Users/neuroprism/Desktop/roi_paper/all_rois_mv_results.csv')

# select roi
r <- 5
perms <- read.csv(paste0('/Users/neuroprism/Desktop/roi_paper/permutation_results/roi_', r, '.csv'))

# filter obs by roi
obs_filtered <- filter(obs, roi == r)


movie <- filter(perms, cond == "M")
rest <- filter(perms, cond == "R")

i2c2 <- movie[['i2c2']] - rest[['i2c2']]
discr <- movie[['discr']] - rest[['discr']]
finger <- movie[['finger']] - rest[['finger']]

par(mfrow = c(1, 3))

# plot i2c2
hist(i2c2, main = paste0('ROI ', r, ' I2C2'), xlab = "Difference in I2C2 between movie and rest", breaks = 15)
abline(v = obs_filtered$i2c2_diff, col = "red")

# plot discr
hist(discr, main = paste0('ROI ', r, ' Discr'), xlab = "Difference in Discr between movie and rest", breaks = 15)
abline(v = obs_filtered$discr_diff, col = "red")

# plot finger
hist(finger, main = paste0('ROI ', r, ' Fingerprinting'), xlab = "Difference in Fingerprinting between movie and rest", breaks = 15)
abline(v = obs_filtered$finger_diff, col = "red")