using LinearAlgebra
using Combinatorics
using BitBasis
using Primes

L = 4

A = with_replacement_combinations([true,false], L) |> collect
A = filter(x->iseven(sum(x)), A)
display(A)