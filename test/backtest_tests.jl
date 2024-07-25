
@testset "Testset 1" begin
    using DataFrames

    struct MockStrategy <: Strategy end
    function Strategies.update(s::MockStrategy, bars::Dict{String, DataFrameRow})
        [Order("asset", 1)]
    end
    mock = MockStrategy()
    result = backtest(
        mock,
        Dict("asset" => DataFrame(open=[1, 2, 3], high=[1, 2, 3], low=[1, 2, 3], close=[1, 2, 3])),
        10.,
    )
    @test result.ending_liquidity == 5.
    @test result.ending_assets_owned["asset"] == 2.
end
