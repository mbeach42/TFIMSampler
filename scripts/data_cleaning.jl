using DelimitedFiles
using TFIMSampler
using LinearAlgebra

function clean(L)
        h = 1.0
        h = round(h, digits=2)
        dir = "/scratch/mbeach/TFIM_samples/PBC/h-1.0/L-$L/"
        dir2 = "/scratch/mbeach/cleaned_TFIM_samples/L-$L/"
        mkpath(dir2)
        @info "L is $L"
        @info "h is $h"

        M = pairing(L, h)
        file = dir * "run-1.txt" 
        train = readdlm(file)
        for r in 2:50
            file = dir * "run-$r.txt" 
            train = vcat(train, readdlm(file))
        end
        @info "training set size :", size(train)
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
        file = dir * "run-51.txt" 
        train = readdlm(file)

        for r in 52:100
            file = dir * "run-$r.txt" 
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

for L in [4,8,16,32,64,128,256]
    println(L)
    clean(L)
end
