using BitBasis
using DelimitedFiles
using LinearAlgebra

function Exact(L::Int, h::Real)
    σˣ = [0 1; 1 0]
    σᶻ = [1 0; 0 -1]
    E = 0.0
    Ψ = zeros(L)
    for k = 0:div(L - 1, 2)
        A = eigen(h * σᶻ + σˣ * sinpi((2k + 1) / L) + σᶻ * cospi((2k + 1) / L))
        V = findmax(A.values)
        E += V[1]
        Ψ[2k + 1:2k + 2] = normalize!(A.vectors[:, V[2]])
    end
    return -2E, Ψ
end

function exact_wf(L::Int; h = 1.0)
    E, ψ = 0.0, zeros(L)
    for k in 0:div(L - 1, 2)
        Ek = sqrt(1 + h^2 + 2h * cospi((2k + 1) / L))
        zetak = -h - cospi((2k + 1) / L)
        E += Ek 
        ψ[2k + 1] = sqrt((Ek - zetak) / (2 * Ek))
        ψ[2k + 2] = sqrt((Ek + zetak) / (2 * Ek))
    end
    return -2E, ψ
end

Gf(n, k, L, u, v) = 2 / L * (2sinpi((2k - 1) * n / L) * u[k] * v[k] + cospi((2k - 1) * n / L) * (-u[k]^2 + v[k]^2))
# Gf(n, k, L, u, v) = 2 / L * (2sinpi((2k - 1) * n / L) * u[k] * v[k] + cospi((2k - 1) * n / L) * (-u[k]^2 + v[k]^2))

function buildG(ψ, n, L)
    G = 0
    u = ψ[2:2:end]
    v = ψ[1:2:end]
    for i in 1:div(L, 2)
        G += Gf(n, i, L, u, v)
    end
    return G
end

Π(ψ, n, L) = [0 buildG(ψ, n, L); -buildG(ψ, -n, L) 0]

function buildC(ψ, L)
    C = zeros(2L, 2L)
    for n in 0:L - 1
        Πs = map(n->Π(ψ, n, L), -n:L - n - 1)
        Πs = hcat(Πs...)
        C[2n + 1:2n + 2, :] = Πs
    end
    return C
end



function Exact(L::Int, h::Real)
    σˣ = [0 1; 1 0]
    σᶻ = [1 0; 0 -1]
    E = 0.0
    Ψ = zeros(L)
    for k = 0:div(L - 1, 2)
        A = eigen(h * σᶻ + σˣ * sinpi((2k + 1) / L) + σᶻ * cospi((2k + 1) / L))
        V = findmax(A.values)
        E += V[1]
        Ψ[2k + 1:2k + 2] = normalize!(A.vectors[:, V[2]])
    end
    return -2E, Ψ
end


L = 4
h = 1

amp = zeros(2^L)
# E, ψ = Exact(L, h)
C = buildC(ψ, L)
C1 = [buildG(ψ, n + j, L) for n in 0:L - 1, j = 0:L - 1]
display(C1)
display(det(C1[1:2, 1:2]))
display(det(C1))