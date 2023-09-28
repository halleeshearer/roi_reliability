conds <- list("REST", "MOVIE")
rois <- list("dlpfc", "pre_sma", "tpj")

.libPaths(c("/scratch/st-tv01-1/R/x86_64-pc-linux-gnu-library/4.1", .libPaths()))
library("data.table")

source("/home/hallee/scratch/hcp/targets/i2c2/I2C2_software/R/I2C2_inference.R")

i2c2_all <- function() {
    result <- data.frame()
    for(roi in rois) {
        for(cond in conds) {
            y <- fread(sprintf("/home/hallee/scratch/hcp/targets/i2c2/rearranged_%s_%s_109.csv", roi, cond))
            # compute I2C2:
            y.lambda <- I2C2(y, I=109, J=2, twoway=FALSE, demean=FALSE)
            # compute the 95% CI of I2C2:
            y.ci <- I2C2.mcCI(y, I=109, J=2, rseed=1, ncores=1, R = 200, demean=FALSE, ci=0.95) # change R to change # of bootstrap samples
            output <- data.frame(condition = cond, roi = roi, lambda = y.lambda$lambda, CI_low = y.ci$CI[1], CI_high = y.ci$CI[2], row.names = NULL)
            result <- rbind(result, output)
        }
    }
    # export the result to csv
    write.csv(result, "/home/hallee/scratch/hcp/targets/i2c2/i2c2_results/i2c2_results_109.csv", row.names=FALSE)
 #  return(result)
}

i2c2_all()
