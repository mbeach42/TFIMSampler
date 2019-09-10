function exact_wf(L::Int; h=1.0)
    E, ψ = 0.0, zeros(L)
    for k in 0:div(L-1, 2)
        Ek = sqrt(1 + h^2 + 2h*cospi((2k+1)/L))
        zetak = -h - cospi((2k+1)/L)
        E += Ek 
        ψ[2k+1] = sqrt((Ek - zetak)/(2*Ek))
        ψ[2k+2] = sqrt((Ek + zetak)/(2*Ek))
    end
    return -2E, ψ
end

function amplitudes(L=4, h=1)
    amp = zeros(2^L)

    E = k -> sqrt(1 + h^2 + 2h*cospi((2k+1)/L))
    Cf(n, k) = 2/L * (h*cospi((2k+1)*n/L)) / E(k) + 2/L * (cospi((2k+1)*(n+1)/L)) / E(k)
    getC = n -> reduce(+, [Cf(n, k) for k in 0:div(L-1, 2)]) |> real
    Π(n) = [0 getC(n); -getC(-n) 0]
    function buildC(L)
        C = zeros(2L, 2L)
        for n in 0:L-1
            Πs = map(n -> Π(n), -n:L-n-1)
            Πs = hcat(Πs...)
            C[2n+1:2n+2, :] = Πs
        end
        return C
    end
    C = buildC(L)[1:2:end, 2:2:end]
    Z = det(I+C) #|> sqrt
    for i in 0:2^(L)-1 
        x = bitarray(i, L)
        f2 = C[x .> 0, x .> 0]
        amp[i+1] = det(f2) / Z
    end
    return C, amp
end

function get_prob(x::BitArray, L=4, h=1)
    E = k -> sqrt(1 + h^2 + 2h*cospi((2k+1)/L))
    Cf(n, k) = 2/L * (h*cospi((2k+1)*n/L)) / E(k) + 2/L * (cospi((2k+1)*(n+1)/L)) / E(k)
    getC = n -> reduce(+, [Cf(n, k) for k in 0:div(L-1, 2)]) |> real
    Π(n) = [0 getC(n); -getC(-n) 0]
    function buildC(L)
        C = zeros(2L, 2L)
        for n in 0:L-1
            Πs = map(n -> Π(n), -n:L-n-1)
            Πs = hcat(Πs...)
            C[2n+1:2n+2, :] = Πs
        end
        return C
    end
    C = buildC(L)[1:2:end, 2:2:end]
    Z = det(I+C) #|> sqrt
    f2 = C[x .> 0, x .> 0]
    logp = log(det(f2)) - log(Z)
    return logp
end
