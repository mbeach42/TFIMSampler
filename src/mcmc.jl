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
    DQMC(L, h, falses(L), F, invF)
end

function fast_update!(x::AbstractArray, F::Matrix, L::Int, h::Float64)
    # println(" ")
    # display(x')
    old_weight = F[x .> 0, x .> 0] |> det
    # r = sample(1:L, rand(1:L), replace = false)
    r = rand(1:L, rand(2:2:L))
    @. x[r] = !x[r]
    new_weight = F[x .> 0, x .> 0] |> det
    ratio = new_weight / old_weight
    # if sum(x) > 0
    # D = F[x .> 0, x .> 0]
    # display(F[x .> 0, x .> 0])
    # display(pinv(F[x .> 0, x .> 0]))
    # end
    # newratio = 1 + inv(F[x .> 0, x .> 0])[r,r] * B' #* inv(F[x .> 0, x .> 0]) * B
    # println("old ratio - new ratio", ratio - newratio)

    if rand() > min(1, ratio)
        @. x[r] = !x[r] # flip back
    end
end

function sweep!(x::AbstractArray, F::Matrix, L::Int, h::Float64)
    for _ in 1:2 * L
        fast_update!(x, F, L, h)
    end
end

function sample(;L = 4, h = 1.0, N = 100, file = false)
    model = DQMC(L, h)
    configs = [] #Vector{BitVector}
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
