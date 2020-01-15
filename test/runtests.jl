using TFIMSampler

using StatsBase
using LinearAlgebra
using BitBasis
# using ProgressMeter

using Test

Z = [1.0 0 ; 0 -1]
X = [0 1.0 ; 1 0]

function test_ed(h)
    L = 4
    @info "h = $h"
    H_XX =  kron(X, X, I(2), I(2)) + kron(I(2), X, X, I(2)) + kron(I(2), I(2), X, X) + kron(X, I(2), I(2), X)
    H_Z = kron(Z, I(2), I(2), I(2)) + kron(I(2), Z, I(2), I(2)) + kron(I(2), I(2), Z, I(2)) + kron(I(2), I(2), I(2), Z)
    H = -H_XX + h * H_Z |> Matrix
    e, psis = eigen(H)
    e = e[1]
    gs_exact = normalize(psis[:,1].^2, 1)

    M = TFIMSampler.pairing(L, h)
    unnormalizedamps, amps = TFIMSampler.get_all_probs(M)

    bits = [bitarray(i, L) for i in 0:2^L - 1]
    display(gs_exact)
    display(amps)
    # display(hcat(bits, amps, gs_exact))
    @test isapprox(gs_exact, amps; atol = 1e-5)
end

# @testset "ED test" begin
#     test_ed(1)
#     test_ed(2)
#     test_ed(0.21)
# end

# configs = TFIMSampler.sample()

function test_mc(L, h)
    N = 10^4
    bits = [bitarray(i, L) for i in 0:2^L - 1]
    configs = TFIMSampler.sample(L = L, h = h, N = N)# |> sort
    amps = countmap(configs)
    amps = filter(x->40506903398877536 > x > -40506031398877536, amps.vals) |> sort
    amps = amps / (2L)

ti
    amps_exact *= N
    amps_exact = filter(x->x > 2, amps_exact) |> sort
    amps_exact = round.(amps_exact, digits = 1) 

    Z = sum(amps)
    Z2 = sum(amps_exact)

    display(hcat(amps/Z, amps_exact/Z2))
    @test isapprox(amps/Z, amps_exact/Z2; atol = 1e-2)
end


@testset "MCMC test" begin
    test_mc(4, 1.0)
    test_mc(4, 2.0)
    test_mc(4, 0.21)
    test_mc(16, 1.0)
end

test_mc(32, 1.0)