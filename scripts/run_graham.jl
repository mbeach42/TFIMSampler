using TFIMSampler

N = 10000
# Ls = 2 .^ collect(2:10)
Ls = 2 .^ collect(8:10)
# hs = 0.1*collect(1:10)
# hs = [0.5, 1.0, 2.0]
hs = [1.0]
# append!(hs, [5.0, 10.0])
repeats = [i for i in 1:10]
# repeats = [i for i in 6:10]

arg = parse(Int, ARGS[1])

list = Iterators.product(Ls, hs, repeats) |> collect
println("length of array jobs is:\t", length(list))
# display(list)

L, h, r = list[arg]
println("\nL is $L")
println("h is $h")
println("r is $r")
println("N is $N")

# pre-compile once 
@time configs, amps = run!(L=1, h=1.0, N=1)

# make directory if none exists
h = round(h, digits=2)
dir = "../data/L-$L/h-$h/"
mkpath(dir)
file = dir * "N-$N-r-$r" 

@time configs, amps = run!(L=L, h=h, N=N, file=file)
