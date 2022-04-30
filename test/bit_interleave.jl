module BitInterleaveTests
# NOTE: Use SafeTestSets: https://github.com/YingboMa/SafeTestsets.jl

using AdaptiveHierarchicalRegularBinning: bit_interleave, InterleaveMethod, Brute
using InteractiveUtils
using Test

function bit_interleave_equivalence_test(n)
    methods = subtypes(InterleaveMethod)
    ground_truth_method = Brute
    filtered_methods = filter((x) -> x != ground_truth_method, methods)

    @testset "$(bit_interleave) equivalence" begin
        @testset "$M" for M in filtered_methods
            @testset "$T" for T in (UInt8, UInt16, UInt32, UInt64, UInt128)
                W = rand(T, n)

                expected = bit_interleave(ground_truth_method, W)
                actual   = bit_interleave(M, W)

                @test expected == actual
            end
        end
    end
end


function bit_interleave_test(n)
    @testset "$(bit_interleave)" begin
        @testset "$T" for T in (UInt8, UInt16, UInt32, UInt64, UInt128)
            WVec = [ [rand(Bool) for _ in 1:sizeof(T)*8] for _ in 1:n ]

            reducer(wVec) = foldr( (x, acc)->((acc<<1) | (x&0x1)), wVec; init=zero(T) )

            W = reducer.(WVec)

            R = Vector{Bool}(undef, n*sizeof(T)*8)
            for i in 1:n
                R[i:n:end] .= WVec[i]
            end

            R = R[1:sizeof(T)*8]

            expected = reducer(R)

            actual = bit_interleave(W)

            @test actual == expected
        end
    end

end


function runtest(n)
    @testset "All Tests [$n]" begin
        bit_interleave_equivalence_test(n)
        bit_interleave_test(n)
    end
end

@testset "Bit Interleave" begin
    for n in 1:128
        runtest(n)
    end
end

end