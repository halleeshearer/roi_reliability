## upload the final version of this from sockeye once confirmed...



# takes a matrix with the following columns (not named): dummy col, sub, cond, session, edge1 ... edge n
# filters first by movie, and creates a movie distance matrix of dims n_sub * n_session by n_sub * n_session
# this distance matrix is the input for i2c2, discr, and fingerprinting analyses is ReX package

# for roi # 2 as an example:
# load the input matrix:
input_mat <- read.csv('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_2.csv', header = FALSE)

# filter by condition
input_mat <- input_mat[input_mat[[3]]=="R",]

# extract information in proper format for ReX
end_of_rows <- dim(input_mat)[2]
data <- as.matrix(input_mat[, 5:end_of_rows])
subID <- as.matrix(input_mat[,2])
cond <- as.matrix(input_mat[,3])
session <- as.matrix(input_mat[,4])

Dmax <- dist(data, method = "euclidian")







for (roi in 1:360) {

    results <- data.frame(roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())

    input_mat <- read.csv(paste0('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_', roi, '.csv'), header = FALSE)
    
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
}




results <- data.frame(roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())
roi <- Sys.getenv("SLURM_ARRAY_TASK_ID")
input_mat <- read.csv(paste0('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_', roi, '.csv'), header = FALSE)

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



#!/bin/bash
#SBATCH --account=st-tv01-1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --job-name=serial_job
#SBATCH --time=0-3:00
#SBATCH --array=2,3,5,6

# Load necessary software modules

module load r/4.3.0
module load apptainer

# Navigate to the job's working directory
cd $SLURM_SUBMIT_DIR

# Execute the apptainer .sif file
apptainer exec /arc/project/st-tv01-1/hallee/ReX/rex.sif Rscript rearrange_matrices.R $SLURM_ARRAY_TASK_ID

# Add your executable commands here


library(ReX)
library(data.table)

#### for the large regions, trying to reset after each loop...
results <- data.frame(roi = numeric(), cond = character(), i2c2 = numeric(), discr = numeric(), finger = numeric())
roi <- Sys.getenv("SLURM_ARRAY_TASK_ID")
input_mat <- read.csv(paste0('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/roi_', roi, '.csv'), header = FALSE)

cond <- "M"
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

write.csv(results, paste0('/scratch/st-tv01-1/hcp/reliability/results/roi_', roi, cond, '_results.csv'), row.names=FALSE)



#!/bin/bash
#SBATCH --account=st-tv01-1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=24G
#SBATCH --job-name=serial_job
#SBATCH --time=0-0:30
#SBATCH --array=1,8,181,188

# Load necessary software modules

module load r/4.3.0
module load apptainer

# Navigate to the job's working directory
cd $SLURM_SUBMIT_DIR

# Execute the apptainer .sif file
apptainer exec /arc/project/st-tv01-1/hallee/ReX/rex.sif Rscript calculate_mv.R $SLURM_ARRAY_TASK_ID

# Add your executable commands here



calc_i2c2(Dmax, subID, as.matrix(session))
calc_discriminability(Dmax, subID)
calc_fingerprinting(Dmax, subID)


for roi 2:
R:
I2C2 - .325
D - 0.81
F - 0.229

M:
I2C2 - 0.2869
D - 0.90
F - 0.37