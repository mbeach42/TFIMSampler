using TFIMSampler

N = 10^4
h = 1.0
Ls = [4, 8, 16]
# Ls = [32, 64, 128]
# Ls = [512]#, 1024] 
# 512 takes about 10 hours for 10^4 samples (5h warm up and 5h run)
# 1024 takes about 4 or 5 days 
repeats = [i for i in 1:100]

arg = parse(Int, ARGS[1])
list = Iterators.product(Ls, repeats) |> collect
println("length of array jobs is:\t", length(list))
L, r = list[arg]
println("\nL is $L")
println("h is $h")
println("r is $r")
println("N is $N")

# pre-compile once 
@time configs, logZ = TFIMSampler.sample(L = 2, h = h, N = 4, file = false)

# make directory if none exists
h = round(h, digits = 2)
dir = "/scratch/mbeach/april_28_TFIM_samples/PBC/h-$h/L-$L/"
mkpath(dir)
file = dir * "run-$r" 

@time configs, logZ = TFIMSampler.sample(L = L, h = h, N = N, file = file)
