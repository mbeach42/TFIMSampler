using TFIMSampler

L = parse(Int, ARGS[1])
h = parse(Float64, ARGS[2])
N = parse(Int, ARGS[3])

println("L is $L")
println("h is $h")
println("N is $N")

# pre-compile once 


# make directory if none exists
dir = "../april_17_data/"
mkpath(dir)
file = dir * "L-$L-h-$h" 

@time configs = TFIMSampler.sample(L=2, h=1.0, N=4, file=file)

@time configs = TFIMSampler.sample(L=L, h=h, N=N, file=file)
