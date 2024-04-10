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