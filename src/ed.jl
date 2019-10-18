using SparseArrays
using LinearAlgebra

function TFIM(N::Int64; h = 1.0)
    basis = buildbasis(N)
    HA_i = zeros(Int64, N * 2^N)
    HA_j = zeros(Int64, N * 2^N)
    HA_elems = zeros(Float64, N * 2^N)
    HZZ = sparse(1.0I, 2^N, 2^N)
    HZ = sparse(1.0I, 2^N, 2^N)
    countA = 0
    for a = 1:2^N
        diag_term = 0.
        for i = 1:N
            countA += 1
            j = mod1(i + 1, N)

            HZ[a,a] -= 2basis[a][i] - 1

            diag_term += 2 * xor(basis[a][i], basis[a][j]) - 1
            basis[a][i] = ~ basis[a][i]
            b = converttointeger(basis[a], N)
            basis[a][i] = ~ basis[a][i]
            HA_i[countA] = a
            HA_j[countA] = b
            HA_elems[countA] = -1
        end
        HZZ[a, a] = diag_term
    end
    HX = sparse(HA_i, HA_j, HA_elems)
    return h * HX + HZZ
end

function buildbasis(N::Int64)
    basis = fill(falses(N), 2^N)
    for i = 1:2^N
        basis[i] = converttobinary(i - 1, N)
    end
    return basis
end

function converttobinary(i::Int64, N::Int64)
    return BitArray(digits(i, base = 2, pad = N))
end

function converttointeger(element::BitArray{1}, L::Integer)
    int = 1
    for site in 1:L
        int += (element[site] << (site - 1))
    end
    return int
end

# H = Matrix(TFIM(4))
Es, vs = Matrix(TFIM(4, h = 1)) |> eigen
println(Es[1])
display(normalize!(vs[:,1]))
ψ0 =  normalize!(vs[:,1].^2, 1)
# ψ0 = ψ0 / ψ0[1]
display(ψ0)
display(sum(ψ0))