using TFIMSampler

function clean(L)

        println("\nL is $L")
        h = 1.0

        # Read old data
        h = round(h, digits=2)
        dir = "data/L-$L/h-$h/"

        file = dir * "r-1.txt" 
        train = readdlm(file)
        logZ = TFIMSampler.get_prob(train[1,:]|> BitArray, L, h)[2]
        println("log Z is", logZ)
        display(size(train))

        for r in 2:5
            file = dir * "r-$r.txt" 
            train = vcat(train, readdlm(file))
        end
        display(size(train))
        dir2 = "cleaned_data/L-$L/h-$h/train/"
        mkpath(dir2)
        writedlm(dir2 * "data_train.txt", Int.(train))

        un = unique(train, dims=1)
        
        display(size(un))
        un_ps = [TFIMSampler.get_prob(un[i,:]|> BitArray , L, h)[1] for i in 1:size(un,1)]
        ps = [TFIMSampler.get_prob(train[i,:]|> BitArray , L, h)[1] for i in 1:size(train,1)]
        println("Sum of ps is ", sum(exp.(ps)))
        println("Sum of ps is ", sum(exp.(un_ps)))

        writedlm(dir2 * "unique_train.txt", Int.(un))
        writedlm(dir2 * "unique_logps_train.txt", un_ps)
        writedlm(dir2 * "logps_train.txt", ps)
        writedlm(dir2 * "logZ.txt", logZ)



        # # TEST DATA
        file = dir * "r-51.txt" 
        test = readdlm(file)

        for r in 52:55
            file = dir * "r-$r.txt" 
            test = vcat(test, readdlm(file))
        end
        dir2 = "cleaned_data/L-$L/h-$h/test/"
        mkpath(dir2)
        writedlm(dir2 * "data_test.txt", Int.(test))
        un = unique(test, dims=1)
        un_ps = [TFIMSampler.get_prob(un[i,:]|> BitArray , L, h)[1] for i in 1:size(un,1)]
        ps = [TFIMSampler.get_prob(train[i,:]|> BitArray , L, h)[1] for i in 1:size(test,1)]
        println("Sum of ps is ", sum(exp.(ps)))
        println("Sum of ps is ", sum(exp.(un_ps)))

        writedlm(dir2 * "unique_train.txt", Int.(un))
        writedlm(dir2 * "unique_logps_train.txt", un_ps)
        writedlm(dir2 * "logps_train.txt", ps)
        writedlm(dir2 * "logZ.txt", logZ)

end

clean(4)
