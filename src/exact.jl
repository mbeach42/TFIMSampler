
using LinearAlgebra
using BitBasis
using DelimitedFiles
using ProgressMeter
set_zero_subnormals(true)

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

function amplitudes(L = 4, h = 1)
    amp = zeros(2^L)
    E = k->sqrt(abs(1 + h^2 + 2h * cospi((2k + 1) / L)))
    # Cf(n, k) = 2 / L * (h * cospi((2k + 1) * n / L))))) / E(k)
    # Cf(n, k) = 2 / L * (cospi(abs((2k + 1) * (n + 1) / L))) / E(k)
    Cf(n, k) = 2 / L * (h * cospi((2k + 1) * n / L) + cospi(abs((2k + 1) * (n + 1) / L))) / E(k)
    getC = n->reduce(+, [Cf(n, k) for k in 0:div(L - 1, 2)]) |> real
    Π(n) = [0 getC(n); -getC(n) 0]
    function buildC(L)
        C = zeros(2L, 2L)
        D = zeros(L, L)
        for n in 0:L - 1
            Πs = map(n->Π(n), -n:L - n - 1)
            Πs = hcat(Πs...)
            C[2n + 1:2n + 2, :] = Πs
            D[n + 1,:] = hcat(map(n->getC(n), -n:L - n - 1)...)
            # C[:, 2n+1:2n+2] = Πs |> transpose
        end
        return C, D
    end
    C, D = buildC(L)#[1:2:end, 2:2:end]
    # println(D)
    # Z = det(I+C)
    for i in 0:2^(L) - 1 
        x = bitarray(i, L)
        if iseven(sum(x)) == true
            D = C[1:2:end, 2:2:end]
            f2 = D[x .> 0, x .> 0]# .|> abs #x .> 0, 1:sum(x)]#x .> 0]
            amp[i + 1] = det(f2) |> abs
        else
            D = C[1:2:end, 2:2:end]
            f2 = D[x .> 0, x .> 0]# .|> abs #x .> 0, 1:sum(x)]#x .> 0]
            amp[i + 1] = det(f2) |> abs
        end
        # f2 = -C[1:sum(x), 1:sum(x)]# .|> abs #x .> 0, 1:sum(x)]#x .> 0]
        # f2 = abs.(D[1:sum(x), 1:sum(x)])#x .> 0, 1:sum(x)]#x .> 0]
        # amp[i+1] = det(f2) |> abs
        # E = eigvals(1im*f2) .|> abs |> sum
    end
    return C, D, amp
end


C, D, A = amplitudes(4, 1)
println("\n Covariance matrix is :")
display(D)
println("\n Predicted ground state is :")
x = A * A[1] / A[2]
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