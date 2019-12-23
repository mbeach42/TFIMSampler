using DelimitedFiles
using TFIMSampler
using LinearAlgebra

function clean(L)
        h = 1.0
        @info "L is $L"
        @info "h is $h"

        # Read old data
        h = round(h, digits=2)
        dir = "/scratch/mbeach/nov22_tfim_data/L-$L/h-$h/"

        M = pairing(L, h)
        # logZ = logdet(M)
        # @info "log Z is $logZ"

        file = dir * "r-1.txt" 
        train = readdlm(file)
        # @info "training set size :", size(train)

        for r in 2:5
            file = dir * "r-$r.txt" 
            train = vcat(train, readdlm(file))
        end
        @info "training set size :", size(train)
        dir2 = "../new_tfim_data/L-$L/h-$h/"
        mkpath(dir2)
        writedlm(dir2 * "data_train.txt", Int.(train))

        un = unique(train, dims=1)
        @info "unique configurations size :", size(un)
        
        un_ps = [TFIMSampler.get_prob(un[i,:]|> BitArray, M) for i in 1:size(un,1)]
        ps = [TFIMSampler.get_prob(train[i,:]|> BitArray, M) for i in 1:size(train,1)]

        logZ = sum(ps)
        @info "log Z is approx. $logZ"
        println("Sum of ps is ", sum(exp.(ps)))
        println("Sum of ps is ", sum(exp.(un_ps)))

        writedlm(dir2 * "unique_train.txt", Int.(un))
        writedlm(dir2 * "unique_logps_train.txt", un_ps)
        writedlm(dir2 * "logps_train.txt", ps)
        writedlm(dir2 * "logZ_train.txt", logZ)

        ### TEST DATA
        file = dir * "r-11.txt" 
        train = readdlm(file)

        for r in 12:15
            file = dir * "r-$r.txt" 
            train = vcat(train, readdlm(file))
        end
        @info "training set size :", size(train)
        mkpath(dir2)
        writedlm(dir2 * "data_train.txt", Int.(train))

        un = unique(train, dims=1)
        @info "unique configurations size :", size(un)
        
        un_ps = [TFIMSampler.get_prob(un[i,:]|> BitArray, M) for i in 1:size(un,1)]
        ps = [TFIMSampler.get_prob(train[i,:]|> BitArray, M) for i in 1:size(train,1)]

        logZ = sum(ps)
        @info "log Z is approx. $logZ"
        println("Sum of ps is ", sum(exp.(ps)))
        println("Sum of ps is ", sum(exp.(un_ps)))

        writedlm(dir2 * "unique_test.txt", Int.(un))
        writedlm(dir2 * "unique_logps_test.txt", un_ps)
        writedlm(dir2 * "logps_test.txt", ps)
        writedlm(dir2 * "logZ_test.txt", logZ)

end

clean(4)
for L in [8,16, 32, 64, 128, 256, 512]
    println()
    clean(L)
end
