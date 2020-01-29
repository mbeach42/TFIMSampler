half(L) = div(L - 1, 2)

Z(M::Matrix) = det(I + M)

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

function get_prob(x::BitVector, M::Matrix)
    amp = logdet(M[x .> 0, x .> 0] + eps() * I)
    return amp
end

function get_all_probs(M::Matrix)
    L = size(M, 1)
    logZ = logdet(M)
    x = i->bitarray(i, L)
    amps = [get_prob(x(i), M) for i in 0:2^L - 1]
    amps = exp.(amps)
    amps2 = normalize(amps, 1)
    return round.(amps, digits = 7), round.(amps2, digits = 7)
end
