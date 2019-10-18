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


function EE(ψ; LA = LA)
    L = length(ψ)
    half = div(L, 2)
    C = buildC(ψ, L)
    Gred = C[1:2LA,1:2LA]
    u, v = eigen((Gred - Gred') / 2)
    nu = imag(u)
    entropy = 0
    for m = 1:2LA
        x = nu[m]
        if abs(x) < 1
            entropy -= (1 + x) / 2 * log2((1 + x) / 2)
        elseif abs(x) > 1 + 1e-5
            print("warning, single-particle eigenvalue x = $x (that is x<-1 or x>1)")
        end
    end
    return entropy 
end


E, ψ = Exact(4, 1)
println(EE(ψ, LA = 1))

function amplitudes(L = 4, h = 1)
    amp = zeros(2^L)
    E, ψ = Exact(L, h)
    D = buildC(ψ, L)
    C = buildC(ψ, L)[1:2:end, 2:2:end]
    # C2 = buildC(ψ, L)[2:2:end, 1:2:end]
    # C = C - C')/2
    # Gred = C[1:2LA,1:2LA]
    # C = buildC(l)
    # Z = det(I+C) 
    for i in 0:2^(L) - 1 
        x = bitarray(i, L)
        X = vcat(x, x)
        # f2 = C[x .> 0, x .> 0] #- C2[x.>0, x.>0]
        # f2 = D[1:2sum(x), 1:2sum(x)] 
        f2 = D[1:2sum(x), 1:2sum(x)]
        amp[i + 1] = det(f2) |> abs
    end
    return D, amp
end

C, A = amplitudes(4, 1) # 0.5 is close to correct
# C, A = amplitudes(4, 0.522) # 0.522 is close to correct
normalize!(A, 1)
display(A / A[1])

A2 = normalize(sqrt.(A), 2)
# display(A / A[1])

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
0.3325145444337074  ]

display(exact / exact[1])