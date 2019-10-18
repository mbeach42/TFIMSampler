using LinearAlgebra
using BitBasis

L = 4
h = 1

A = diagm(0 => -h * ones(L),
          1 => 0.5 *  ones(L - 1),
          - 1 => 0.5 *  ones(L - 1))
B = diagm(1 => -0.5 * ones(L - 1),
          -1 => 0.5 * ones(L - 1))

# C = [A B; -B -A]
# E, ϕ = eigen(C)
E, ϕ = eigen((A + B) * (A - B))

display(ϕ)

ψ  = inv(ϕ)
# sqrt.(E) .* ϕ * inv(A - B)
# ψ = ψ'

# display(ψ * (A + B) * (A - B) .- E' * ψ')

u = (ψ + ϕ ) / 2
v = (ψ - ϕ) / 2

display(v' * v + u' * u)
display(v' * u + u' * v)

# F1 = u \ v
# F = u \ v
F = v \ u
# F = round.(F, digits = 6)
# display(F)
# F2 = kron([0 1; -1 0], F)
# F = ψ' * ϕ
F = ϕ .* ψ

amp = zeros(2^L)
for i in 0:2^(L) - 1 
    x = bitarray(i, L)
    # X = vcat(ones(L), x)
    # X = vcat(x, x)
    # display(X)
    f = F[x .> 0, x .> 0]
    # f = F2[X .> 0, X .> 0]
    # f = F2[X .> 0, X .> 0]
    amp[i + 1] = det(f) |> abs
end
# normalize!(amp)

display(round.(amp, digits = 5))

# amp = amp / amp[1]
# amp = amp / amp[1]
normalize!(amp, 1)
display(amp)
display(sum(amp))