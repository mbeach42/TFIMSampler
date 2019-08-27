using Random
using StatsBase

# TODO 
# (1) faster updates with single determinant or matrix inverse
# (2) monitor energy, magnetization, etc.

mutable struct DQMC
    L::Int
    h::Float64
    x::BitArray # state
    F::Matrix{Float64} # Pfaffian
    invF::Matrix{Float64} # inverse Pfaffian
end

function pairing_function(L::Int, h::Float64)
    F = zeros(2L, 2L)
    E = k -> sqrt(1 + h^2 + 2h*cospi((2k+1)/L))
    Cf(n, k) = 2/L * (h*cospi((2k+1)*n/L)) / E(k) + 2/L * (cospi((2k+1)*(n+1)/L)) / E(k)
    getC = n -> reduce(+, [Cf(n, k) for k in 0:div(L-1, 2)]) |> real
    Π(n) = [0 getC(n); -getC(-n) 0]
    for n in 0:L-1
        Πs = map(n -> Π(n), -n:L-n-1)
        Πs = hcat(Πs...)
        F[2n+1:2n+2, :] = Πs
    end 
    F = F[1:2:end, 2:2:end]
    return F
end

function DQMC(L::Int, h::Float64)
    F = pairing_function(L, h)
    invF = inv(F)
    DQMC(L, h, falses(L), F, invF)
end

function fast_update!(x::AbstractArray, F::Matrix, L::Int, h::Float64)
    x2 = copy(x)
    old_weight = F[x.>0, x.>0] |> det
    r = sample(1:L, rand(1:L), replace = false)
    @. x2[r] = !x[r]
    new_weight = F[x2.>0, x2.>0] |> det
    ratio = new_weight/old_weight
    if rand() < min(1, ratio)
        x .= x2
    end
end

function sweep!(x::AbstractArray, F::Matrix, L::Int, h::Float64)
    for _ in 1:5*L
        fast_update!(x, F, L, h)
    end
end

function run!(;L=4, h=1.0, N=100, file=false)
    model = DQMC(L, h)
    configs = []
    @showprogress 1 "warming up..." for i in 1:N
        sweep!(model.x, model.F, model.L, model.h)
    end
    @showprogress 1 "running MC..." for i in 1:N
        sweep!(model.x, model.F, model.L, model.h)
        push!(configs, copy(model.x))
        if file ≠ false
            open(file * ".txt", "a") do f
                writedlm(f, Int.(model.x'), ",")
            end
        end
    end
    Amps = countmap(configs) |> sort
    amps = normalize(Amps.vals)
    if file ≠ false
        writedlm(file * "-amps.txt", amps)
    end
    return configs, amps
end

run!(N=1)