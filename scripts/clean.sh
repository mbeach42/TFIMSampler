#!/bin/bash
#SBATCH --account=rrg-rgmelko-ab
#SBATCH --ntasks=1
#SBATCH --mem=15GB
#SBATCH --time=12:00:00
#SBATCH --job-name=cleaning
#SBATCH --output=cleaning.log

module load nixpkgs/16.09 gcc/7.3.0 julia
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export JULIA_NUM_THREADS=1

julia --project -O3 --check-bounds=no data_cleaning2.jl
