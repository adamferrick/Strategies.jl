function backtest(s::Strategy, bars::DataFrame, initial_liquidity::Float64)
    n = nrow(bars)
    new_orders = []
    curves = DataFrame(
        datetime = bars.datetime,
        liquidity = zeros(n),
        assets_owned = zeros(n),
    )
    curves.liquidity[1] = initial_liquidity

    for i in 1:n
        bar = Bar(bars.open[i], bars.high[i], bars.low[i], bars.close[i], bars.volume[i])
        for order in new_orders
            curves.liquidity[i] = curves.liquidity[i-1] - order.size * bar.open
            curves.assets_owned[i] = curves.assets_owned[i-1] + order.size
        end
        new_orders = update(s, bar)
    end

    curves.equity = curves.liquidity + bars.open .* curves.assets_owned

    (
        liquidity = curves.liquidity[n],
        assets_owned = curves.assets_owned[n],
        equity = curves.equity[n],
        curves = curves,
    )
end

function backtest(s::Strategy, times, assets::Dict{String, DataFrame}, initial_liquidity)
    n = length(times)
    new_orders = []
    liquidity_curve = zeros(n)
    liquidity_curve[1] = initial_liquidity
    assets_owned_curves = Dict{String, Vector{Float64}}()
    for ticker in keys(assets)
        assets_owned_curves[ticker] = zeros(n)
    end

    for i in 1:n
        bars = Dict{String, Bar}()
        for ticker in keys(assets)
            bars[ticker] = Bar(
                assets[ticker].open[i],
                assets[ticker].high[i],
                assets[ticker].low[i],
                assets[ticker].close[i],
                assets[ticker].volume[i],
            )
        end
        for order in new_orders
            liquidity_curve[i] = liquidity_curve[i-1] - order.size * bars[order.ticker].open
            assets_owned_curves[order.ticker][i] = assets_owned_curves[order.ticker][i-1] + order.size
        end
        new_orders = update(s, bars)
    end

    (
        liquidity_curve = liquidity_curve,
        assets_owned_curves = assets_owned_curves,
        equity_curve = compute_equity_curve(liquidity_curve, assets_owned_curves, assets),
    )
end

function compute_equity_curve(
    liquidity_curve::Vector{Float64},
    assets_owned_curves::Dict{String, Vector{Float64}},
    bars::Dict{String, DataFrame},
)
    n = length(liquidity_curve)
    result = zeros(n)
    tickers = keys(bars)
    for i in 1:n
        positions = [bars[ticker].close[i] * assets_owned_curves[ticker][i] for ticker in tickers]
        result[i] = liquidity_curve[i] + sum(positions)
    end
    result
end
