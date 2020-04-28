using DelimitedFiles
using StatsFuns
using TFIMSampler
using LinearAlgebra
using ProgressMeter

function clean(L; name = "train", r = 1, R = 50)
    h = 1.0
    h = round(h, digits = 2)
    dir = "/scratch/mbeach/TFIM_samples/PBC/h-1.0/L-$L/"
    dir2 = "/scratch/mbeach/new_new_cleaned_TFIM_samples/L-$L/$name/"
    Base.Filesystem.rm(dir2, force = true, recursive = true)
    mkpath(dir2)

    @info "L is $L"
    @info "h is $h"

    M = pairing(L, h)
    logZ = TFIMSampler.logZ(M)
    @info "log Z is $logZ"
    @info "Z is $(exp(logZ))"

    file = dir * "run-$r.txt" 
    train = readdlm(file)
    @info "Original training set size : $(size(train))"
    @showprogress for i in r + 1:R
        file = dir * "run-$i.txt" 
        train = vcat(train, readdlm(file))
    end

    @info "Training set size : $(size(train))"
    un = unique(train, dims = 1)
    @info "unique configurations size : $(size(un))"
    
    un_ps = [TFIMSampler.get_prob(un[i,:] |> BitArray, M) for i in 1:size(un, 1)]
    ps = [TFIMSampler.get_prob(train[i,:] |> BitArray, M) for i in 1:size(train, 1)]

    @info "logZ is approx. $logZ"
    ps = [ps[i] - logZ for i in 1:size(train, 1)] 
    un_ps = [un_ps[i] - logZ for i in 1:size(un, 1)]
    @info "Sum of ps is $(sum(exp.(un_ps)))"

    writedlm(dir2 * "logZ_$name.txt", logZ)
    writedlm(dir2 * "configs_$name.txt", Int.(train))
    writedlm(dir2 * "unique_configs_$name.txt", Int.(un))
    writedlm(dir2 * "logps_$name.txt", ps)
    writedlm(dir2 * "unique_logps_$name.txt", un_ps)
end

clean(4, name = "train", r = 1, R = 50)
clean(4, name = "test", r = 51, R = 100)

# for L in [8, 16, 32, 64, 128, 256]
# for L in [8, 16, 32, 64, 128, 256, 512]
for L in [512]
    @info L
    clean(L, name = "train", r = 1, R = 50)
    clean(L, name = "test", r = 51, R = 100)
end
