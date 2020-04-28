using TFIMSampler

L = parse(Int, ARGS[1])
# h = parse(Float64, ARGS[2])
h = 1.0
N = parse(Int, ARGS[2])

println("L is $L")
println("h is $h")
println("N is $N")

# pre-compile once 
# @time configs, amps = run!(L=2, h=1.0, N=1)


# make directory if none exists
dir = "../new_data/"
mkpath(dir)
file = dir * "L-$L-h-$h" 

@time configs, logZ = TFIMSampler.sample(L = L, h = h, N = N, file = file)
