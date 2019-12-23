module TFIMSampler

using BitBasis
using DelimitedFiles
using ProgressMeter
using Random
using StatsBase
using LinearAlgebra
using SparseArrays

set_zero_subnormals(true)

include("new.jl")
include("mcmc.jl")

export sample, DQMC, pairing, sweep!, fast_update!, get_probs, get_prob, get_all_probs

end # module 
