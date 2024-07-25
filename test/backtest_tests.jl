
@testset "Testset 1" begin
    using Dates

    struct MockStrategy <: Strategy end
    function Strategies.update(s::MockStrategy, bars::Dict{String, Bar})
        [Order(ticker, 1)]
    end
    mock = MockStrategy()
    bars = [
        Bar(1, 1, 1, 1, 1)
    ]
    backtest(
        mock,
        [Date(2000, 1, 1), Date(2000, 1, 2), Date(2000, 1, 3)],
        Dict("asset1" => [
            Bar(1., 1., 1., 1., 0.),
            Bar(2., 2., 2., 2., 0.),
            Bar(3., 3., 3., 3., 0.),
        ]),
        10.,
    )
    @test true == true
end
