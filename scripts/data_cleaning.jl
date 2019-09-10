using TFIMSampler

function clean()

    for L in Int.(2 .^ collect(2:7))
        println("\nL is $L")
        N = 10000
        h = 1.0

        # Read old data
        h = round(h, digits=2)
        dir = "../data/L-$L/h-$h/"

        file = dir * "N-$N-r-1.txt" 
        train = readdlm(file)
        display(size(train))

        for r in 2:5
            file = dir * "N-$N-r-$r.txt" 
            train = vcat(train, readdlm(file))
        end
        dir2 = "../cleaned_data/L-$L/h-$h/train/"
        mkpath(dir2)
        writedlm(dir2 * "data_train.txt", train)

        un = unique(train, dims=1)
        display(size(un))
        ps = [TFIMSampler.get_prob(un[i,:]|> BitArray , L, h) for i in 1:size(un,1)]

        writedlm(dir2 * "unique_train.txt", un)
        writedlm(dir2 * "ps_train.txt", ps)



        # TEST DATA
        file = dir * "N-$N-r-1.txt" 
        test = readdlm(file)

        for r in 6:10
            file = dir * "N-$N-r-$r.txt" 
            test = vcat(test, readdlm(file))
        end
        dir3 = "../cleaned_data/L-$L/h-$h/test/"
        mkpath(dir3)
        writedlm(dir3 * "data_test.txt", test)
        un = unique(test, dims=1)
        ps = [TFIMSampler.get_prob(un[i,:]|> BitArray , L, h) for i in 1:size(un,1)]

        writedlm(dir3 * "unique_test.txt", un)
        writedlm(dir3 * "ps_test.txt", ps)

    end
end
clean()
