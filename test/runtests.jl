using Test
using TFIMSampler
using StatsBase
using LinearAlgebra
using BitBasis
using ProgressMeter

#=function ED(h)=#
    # Z = [0 1.0 ; 1 0]
    # X = [1 0.0 ; 0 -1]
    # J = 1
    # H_XX =  kron(X, X, I(2), I(2)) + kron(I(2), X, X, I(2)) + kron(I(2), I(2), X, X) # + kron(X, I(2), I(2), X)
    # H_Z = kron(Z, I(2), I(2), I(2)) + kron(I(2), Z, I(2), I(2)) + kron(I(2), I(2), Z, I(2)) + kron(I(2), I(2), I(2), Z)
    # H = -J * H_XX - h * H_Z |> Matrix
    # e, psis = eigen(H)
    # e = e[1]
    # gs_exact = psis[:,1]

    # EJ = gs_exact' * J * H_XX * gs_exact# / norm(gs_exact)
    # Eh = gs_exact' * h * H_Z * gs_exact # / norm(gs_exact)


    # M = 0.0
    # ##### Calculate the groundstate magnetization <m^2> in the Z direction
    # magnetization = 0
    # Dim = 2^N
    # for Ket = 0:Dim - 1  # Loop over Hilbert Space
        # SumSz = 0.
        # for SpinIndex = 0:N - 1  # Loop over spin index (base zero, stop one spin before the end of the chain)
            # Spin1 = 2 * ((Ket >> SpinIndex) & 1) - 1
            # SumSz += Spin1 # spin is +1 or -1
            # # print(Spin1," ")
        # end
        # # println(SumSz," ",GroundState[Ket+1])
        # magnetization += SumSz * SumSz * gs_exact[Ket + 1]^2  # Don't forgot to square the coefficients...
    # end
    # M = magnetization / (N * N)
    # return Eh + EJ, M
#=end=#


@testset "Z" begin
    for L in [4, 6, 8]
        for h in [0.5, 1.0, 2.45]
            M = pairing(L, h)
            logZ = TFIMSampler.logZ(M)
            logZ_sum = log(sum(get_all_probs(M)[1]))
            println(logZ)
            println(logZ_sum)
            @test logZ - logZ_sum  < 1e-6
        end
    end
end

    # display(gs_exact)
# function test_ed(h)
#     L = 4
#     @info "h = $h"
#     H_XX =  kron(X, X, I(2), I(2)) + kron(I(2), X, X, I(2)) + kron(I(2), I(2), X, X) + kron(X, I(2), I(2), X)
#     H_Z = kron(Z, I(2), I(2), I(2)) + kron(I(2), Z, I(2), I(2)) + kron(I(2), I(2), Z, I(2)) + kron(I(2), I(2), I(2), Z)
#     H = -H_XX + h * H_Z |> Matrix
#     e, psis = eigen(H)
#     e = e[1]
#     gs_exact = normalize(psis[:,1].^2, 1)

#     M = TFIMSampler.pairing(L, h)
#     unnormalizedamps, amps = TFIMSampler.get_all_probs(M)

#     bits = [bitarray(i, L) for i in 0:2^L - 1]
#     display(gs_exact)
#     display(amps)
#     # display(hcat(bits, amps, gs_exact))
#     @test isapprox(gs_exact, amps; atol = 1e-5)
# end

# # @testset "ED test" begin
# #     test_ed(1)
# #     test_ed(2)
# #     test_ed(0.21)
# # end

# # configs = TFIMSampler.sample()

# function test_mc(L, h)
#     N = 10^4
#     bits = [bitarray(i, L) for i in 0:2^L - 1]
#     configs = TFIMSampler.sample(L = L, h = h, N = N)# |> sort
#     amps = countmap(configs)
#     amps = filter(x->40506903398877536 > x > -40506031398877536, amps.vals) |> sort
#     amps = amps / (2L)

#     M = TFIMSampler.pairing(L, h)
#     amps_exact = TFIMSampler.get_all_probs(M)[2] |> sort
#     amps_exact *= N
#     amps_exact = filter(x->x > 2, amps_exact) |> sort
#     amps_exact = round.(amps_exact, digits = 1) 

#     Z = sum(amps)
#     Z2 = sum(amps_exact)
#     @test isapprox(amps/Z, amps_exact/Z2; atol = 1e-2)
# end


# @testset "MCMC test" begin
#     test_mc(4, 1.0)
#     test_mc(4, 2.0)
#     test_mc(4, 0.21)
#     test_mc(16, 1.0)
# end

# test_mc(32, 1.0)
