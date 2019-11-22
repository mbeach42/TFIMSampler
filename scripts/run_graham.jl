using TFIMSampler

N = 10^4
Ls = 2 .^ collect(2:10)
# hs = 0.1*collect(1:10)
hs = [0.5, 1.0, 2.0]
repeats = [i for i in 1:100]

# arg = parse(Int, ARGS[1])

list = Iterators.product(Ls, hs, repeats) |> collect
println("length of array jobs is:\t", length(list))

L, h, r = list[arg]
println("\nL is $L")
println("h is $h")
println("r is $r")
println("N is $N")

# pre-compile once 
@time configs = TFIMSampler.sample(L=2, h=1.0, N=1)

# make directory if none exists
h = round(h, digits=2)
dir = "/scratch/mbeach/nov22_tfim_data/L-$L/h-$h/"
mkpath(dir)
file = dir * "r-$r" 

@time configs, amps = run!(L=L, h=h, N=N, file=file)
@time configs = TFIMSampler.sample(L=L, hh=, N=N, file=file)