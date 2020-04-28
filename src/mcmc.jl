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

function DQMC(L::Int, h::Float64)
    F = pairing(L, h)
    invF = inv(F)
    if rand() > 0.5
        init_x = falses(L)
    else
        init_x = trues(L)
    end
    DQMC(L, h, init_x, F, invF)
end

function fast_update!(x::AbstractArray, F::Matrix, L::Int, h::Float64, old_weight::Float64)
    r = rand(1:L, rand(2:2:L))
    @. x[r] = !x[r]
    new_weight = F[x .> 0, x .> 0] |> det
    ratio = new_weight / old_weight
    
    if rand() > min(1, ratio)
        @. x[r] = !x[r] # flip back
        return old_weight
    else
        return new_weight
    end
end

function sweep!(x::AbstractArray, F::Matrix, L::Int, h::Float64)
    old_weight = F[x .> 0, x .> 0] |> det
    for _ in 1:2 * L
        old_weight = fast_update!(x, F, L, h, old_weight)
    end
end

function single_sample(;L = 4, h = 1.0, N = 100, file = false)
    model = DQMC(L, h)
    configs = [] # Vector{BitVector}
    @showprogress 1 "warming up..." for i in 1:N
        sweep!(model.x, model.F, model.L, model.h)
    end
    @showprogress 1 "running MC..." for i in 1:N
        sweep!(model.x, model.F, model.L, model.h)
        push!(configs, copy(model.x))
        if file ≠ false
            open(file * ".txt", "a") do f
                writedlm(f, Int.(model.x'))
            end
        end
    end
    return configs
end

function sample(;nrepeats = 4, L = 4, h = 1.0, N = 100, file = false)
    nrepeats = 2 * L
    configs = single_sample(L = L, h = h, N = N, file = file)
    for i in 1:nrepeats - 1
        configs = vcat(single_sample(L = L, h = h, N = N, file = file), configs)
    end
    return configs
end