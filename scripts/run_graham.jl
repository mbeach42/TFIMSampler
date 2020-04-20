using TFIMSampler

N = 10^4
h = 1.0
# Ls = [4, 8, 16]
# Ls = [32, 64, 128]
Ls = [256, 512, 1024]
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
@time configs = TFIMSampler.single_sample(L=2, h=2.0, N=1)

# make directory if none exists
h = round(h, digits=2)
dir = "/scratch/mbeach/TFIM_samples/PBC/h-$h/L-$L/"
mkpath(dir)
file = dir * "run-$r" 

@time configs = TFIMSampler.single_sample(L=L, h=h, N=N, file=file)
