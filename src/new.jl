# using LinearAlgebra
# using BitBasis
# include("ed.jl")

half(L) = div(L - 1, 2)
# L = 4
# h = 1


function pairing(L, h)
    E(k) = sqrt(1 + h^2 + 2h * cospi((2k + 1) / L))
    ζ(k) = - (h + cospi((2k + 1) / L))
    u(k) = sqrt((1 + ζ(k) / E(k)) / 2)
    v(k) = sqrt((1 - ζ(k) / E(k)) / 2)
    g(r) = 2 / L * sum(sinpi((2k + 1) / L * r) * v(k) / u(k) for k in 0:div(L - 1, 2))

    M = zeros(L, L)
    for i in 1:L, j in 1:L
        M[i,j] = g(i -  j) 
    end
    return M
end

function get_amplitudes(M::Matrix)
    L = size(M, 1)
    Z = det(M)
    x = i->bitarray(i, L)
    amps = [det(M[x(i) .> 0, x(i) .> 0]) / Z for i in 0:2^L - 1]
    normalize!(amps, 1)
    return amps
end



    # bits = [bitarray(i, L) for i in 0:2^L - 1]
    # amps = round.(abs.(amps), digits = 6) 

    # H = TFIM(L, h = h)
    # Es, vs = Matrix(H) |> eigen
    # E_ed = Es[1]
    # gs0 = normalize!(vs[:,1].^2, 1)
    # amps = normalize!(amps, 1)
    # bits_amps = hcat(bits, amps, gs0)
# 
    # println("\nBitString | amplitude current | amp exact")
    # display(bits_amps)

    # E0 = -2 / h * sum(E(k) for k in 0:half(L))
    # println("Energy is \t$E0")
# println("ED Energy is \t$E_ed")

# Z = [1.0 0 ; 0 -1]
# X = [0 1.0 ; 1 0]
# # H_XX =  kron(X, X, I(2), I(2)) + kron(I(2), X, X, I(2)) + kron(I(2), I(2), X, X) + kron(X, I(2), I(2), X)
# # H_Z = kron(Z, I(2), I(2), I(2)) + kron(I(2), Z, I(2), I(2)) + kron(I(2), I(2), Z, I(2)) + kron(I(2), I(2), I(2), Z)
# H_XX =  kron(Z, Z, I(2), I(2)) + kron(I(2), Z, Z, I(2)) + kron(I(2), I(2), Z, Z) + kron(Z, I(2), I(2), Z)
# H_Z = kron(X, I(2), I(2), I(2)) + kron(I(2), X, I(2), I(2)) + kron(I(2), I(2), X, I(2)) + kron(I(2), I(2), I(2), X)

# H = -H_XX - H_Z |> Matrix

# display(H)
# e, psis = eigen(H)
# display(normalize!(psis[:,1].^2, 1))