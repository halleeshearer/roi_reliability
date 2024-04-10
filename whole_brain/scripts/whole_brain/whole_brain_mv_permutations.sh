#!/bin/bash
#SBATCH --time=20:00:00                    # Request hours of runtime
#SBATCH --account=st-tv01-1            # Specify your allocation code
#SBATCH --job-name=mv_permutations         # Specify the job name
#SBATCH --nodes=1                       # Defines the number of nodes for each sub-job.
#SBATCH --ntasks-per-node=1             # Defines tasks per node for each sub-job.
#SBATCH --mem=8G                        # Request 8 GB of memory
#SBATCH --output=array_%A_%a.out        # Redirects standard output to unique files for each sub-job.
#SBATCH --error=array_%A_%a.err         # Redirects standard error to unique files for each sub-job.


# Load necessary software modules

module load r/4.3.0
module load apptainer

# Navigate to the job's working directory
cd $SLURM_SUBMIT_DIR

# Add your executable commands here

apptainer exec /arc/project/st-tv01-1/hallee/ReX/rex.sif Rscript whole_brain_mv_permutations.R
