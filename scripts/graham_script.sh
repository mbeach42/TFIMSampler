#!/bin/bash
#SBATCH --account=rrg-rgmelko-ab
#SBATCH --ntasks=1
#SBATCH --mem=4GB
#SBATCH --time=18:00:00
#SBATCH --job-name=tfim_data
#SBATCH --array=1-100
#SBATCH --output=tfim_data.log

module load nixpkgs/16.09 gcc/7.3.0 julia
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export JULIA_NUM_THREADS=1

julia --project -O3 --check-bounds=no run_graham.jl $SLURM_ARRAY_TASK_ID
