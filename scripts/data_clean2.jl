using DelimitedFiles
using StatsFuns
using TFIMSampler
using LinearAlgebra

function clean(L;name="train", r=1, h=1.0)
    @info " " 
    @info "L is $L"
    @info "h is $h"

    # Read old data
    h = round(h, digits=2)
    dir = "/scratch/mbeach/nov22_tfim_data/L-$L/h-$h/"

    M = pairing(L, h)
    # logZ = logdet(M)
    # @info "log Z is $logZ"

    file = dir * "r-$r.txt" 
    train = readdlm(file)
    @info "Original training set size : $(size(train))"

    for R in r+1:r+5
        file = dir * "r-$R.txt" 
        train = vcat(train, readdlm(file))
    end

    @info "Training set size : $(size(train))"
    dir2 = "../new_new_tfim_data/L-$L/h-$h/"
    mkpath(dir2)

    un = unique(train, dims=1)
    @info "unique configurations size : $(size(un))"
    
    un_ps = [TFIMSampler.get_prob(un[i,:]|> BitArray, M) for i in 1:size(un,1)]
    ps = [TFIMSampler.get_prob(train[i,:]|> BitArray, M) for i in 1:size(train,1)]

    logZ = logsumexp(ps)
    @info "log Z is approx. $logZ"
    # @info "log Z of ps is ", log(sum(exp.(ps)))
    # @info "log Z of ps is $(logsumexp(ps))"
    # @info "Sum of ps is ", sum(exp.(ps))"
    ps = [ps[i] - logZ for i in 1:size(train,1)]
    un_ps = [un_ps[i] - logZ for i in 1:size(un,1)]
    # @info ("log Z is approx. ", exp(logZ))
    @info "Sum of ps is $(sum(exp.(ps)))"
    # println("Sum of ps is ", sum(exp.(un_ps)))

    writedlm(dir2 * "data_$name.txt", Int.(train))
    writedlm(dir2 * "logps_$name.txt", ps)

    writedlm(dir2 * "unique_$name.txt", Int.(un))
    writedlm(dir2 * "unique_logps_$name.txt", un_ps)
    writedlm(dir2 * "logZ_$name.txt", logZ)
end

clean(4, name="train", r=1)
for L in [8, 16, 32]
    println()
    clean(L, name="train", r=1)
    clean(L, name="test", r=11)
end
