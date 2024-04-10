# slurm script to run the matrices on Sockeye (HPC)

#!/bin/bash
#SBATCH --time=4:00:00                    # Request hours of runtime
#SBATCH --account=st-tv01-1            # Specify your allocation code
#SBATCH --job-name=create_matrices         # Specify the job name
#SBATCH --nodes=10                       # Defines the number of nodes for each sub-job.
#SBATCH --ntasks-per-node=1             # Defines tasks per node for each sub-job.
#SBATCH --mem=30G                        # Request 8 GB of memory
#SBATCH --output=array_%A_%a.out        # Redirects standard output to unique files for each sub-job.
#SBATCH --error=array_%A_%a.err         # Redirects standard error to unique files for each sub-job.


# Load all the software modules
module load miniconda3
source activate /arc/project/st-tv01-1/jupyter/Sandbox

# Your job array commands go here
python3 create_matrices_all_rois.py
