using Strategies
using Test

@testset "Strategies tests" begin
    @testset "Backtest tests" begin
        include("backtest_tests.jl")
    end
end
