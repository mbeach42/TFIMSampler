#!/bin/bash
#SBATCH --account=rrg-rgmelko-ab
#SBATCH --ntasks=1
#SBATCH --mem=5GB
#SBATCH --time=8:00:00
#SBATCH --job-name=tfim_data
#SBATCH --output=tfim_data.log
#SBATCH --array=1-990%200

module load nixpkgs/16.09 gcc/7.3.0 julia

julia --project -O3 --check-bounds=no run_graham.jl $SLURM_ARRAY_TASK_ID 10000
