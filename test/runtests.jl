using TFIMSampler
using Test

@testset "TFIMSampler.jl" begin

    h = 0.0

    amps_exact = amplitudes(4, h)
    configs, amps = run!(L=4, h=h, N=100)
    # display(configs)
    # display(amps)
    # display(amps_exact - amps)
    
    diff = []
    for N in 10 .^ [3,4,5]
        @time configs, amps = run!(L=4, h=h, N=N)
        display(amps)
        # display(sum(abs.(amps_exact - amps)))
        # append!(diff, sum(abs.(amps_exact - amps)))
    end
    display(diff)

    @time configs, amps = run!(L=100, h=h, N=1000)

end