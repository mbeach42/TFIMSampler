using TFIMSampler

N = 10000
Ls = 2 .^ collect(2:10)
hs = 0.1*collect(1:20)
append!(hs, [5.0, 10.0])
repeats = [i for i in 1:5]

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
dir = "../data/"
mkpath(dir)
file = dir * "L-$L-h-$h-N-$N" 

@time configs, amps = run!(L=L, h=h, N=N, file=file)
