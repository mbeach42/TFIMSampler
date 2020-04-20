using DelimitedFiles
using StatsFuns
using TFIMSampler
using LinearAlgebra

function clean(L;name="train", r=1, h=1.0, R=10)
    @info " " 
    @info "L is $L"
    @info "h is $h"

    # Read old data
    h = round(h, digits=2)
    dir = "/scratch/mbeach/nov22_tfim_data/L-$L/h-$h/"

    M = pairing(L, h)
    logZ = TFIMSampler.logZ(M)
    @info "log Z is $logZ"

    file = dir * "r-$r.txt" 
    train = readdlm(file)
    @info "Original training set size : $(size(train))"

    for i in r+1:R
        file = dir * "r-$i.txt" 
        train = vcat(train, readdlm(file))
    end

    @info "Training set size : $(size(train))"
    # dir2 = "~/project/tfim_data/L-$L/h-$h/"
    dir2 = "/home/mbeach/project/tfim_data_150/pbc/L-$L/h-$h/"
    mkpath(dir2)

    un = unique(train, dims=1)
    @info "unique configurations size : $(size(un))"
    
    un_ps = [TFIMSampler.get_prob(un[i,:]|> BitArray, M) for i in 1:size(un,1)]
    ps = [TFIMSampler.get_prob(train[i,:]|> BitArray, M) for i in 1:size(train,1)]

    @info "logZ is approx. $logZ"
    ps = [ps[i] - logZ for i in 1:size(train,1)] 
    un_ps = [un_ps[i] - logZ for i in 1:size(un,1)]
    @info "Sum of ps is $(sum(exp.(un_ps)))"

    writedlm(dir2 * "configs_$name.txt", Int.(train))
    writedlm(dir2 * "logps_$name.txt", ps)
    writedlm(dir2 * "unique_configs_$name.txt", Int.(un))
    writedlm(dir2 * "unique_logps_$name.txt", un_ps)
end

clean(4, name="train", r=1, R=15)
clean(4, name="test", r=16, R=20)

for L in [8, 16, 32, 64, 128, 256, 512]
    println()
    clean(L, name="train", r=1, R=15)
    clean(L, name="test", r=16, R=20)
end
