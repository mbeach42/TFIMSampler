#!/bin/bash
#SBATCH --account=rrg-rgmelko-ab
#SBATCH --ntasks=1
#SBATCH --mem=5GB
#SBATCH --time=3:00:00
#SBATCH --job-name=tfim_data
#SBATCH --output=tfim_data.log
#SBATCH --array=1-770%220

module load nixpkgs/16.09 gcc/7.3.0 julia

julia --project -O3 --check-bounds=no --math-mode=fast vita2d.jl
$SLURM_ARRAY_TASK_ID 10000
