using LinearAlgebra
using BitBasis

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

# Gf(n, k, L, u, v) = 2 / L * (2sinpi((2k - 1) * n / L) * u[k] * v[k])
# Gf(n, k, L, u, v) = 2 / L * (cospi((2k - 1) * n / L) * (-u[k]^2 + v[k]^2))
Gf(n, k, L, u, v) = 2 / L * (2sinpi((2k - 1) * n / L) * u[k] * v[k] + cospi((2k - 1) * n / L) * (-u[k]^2 + v[k]^2))

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


function amplitudes(L = 4, h = 1)
    amp = zeros(2^L)
    E, ψ = exact_wf(L; h = h)
    C = buildC(ψ, L)#[1:2:end, 2:2:end]
    for i in 0:2^(L) - 1 
        x = bitarray(i, L)
        D = C[1:2:end, 2:2:end]
        f2 = D[x .> 0, x .> 0]
        amp[i + 1] = det(f2) |> abs
    end
    return C, amp
end


C, A = amplitudes(4, 1)
println("\n Covariance matrix is :")
display(D)
println("\n Predicted ground state is :")
x = A #* A[1] / A[2]
display(x)

exact = [0.3325145444337043  
0.03124999999999992 
0.03124999999999992 
0.018305826175840843
0.03124999999999992 
0.00587380321461
0.018305826175840843
0.031250000000000146
0.03124999999999992 
0.01830582617584083 
0.00587380321461215 
0.031250000000000173
0.018305826175840843
0.03125000000000016 
0.03125000000000012 
0.3325145444337074]

println("\nExact ground state is:")
y = exact ./ exact[1]
display(y)

println("\n ratio is :")
display(round.(x .- y, digits = 5))