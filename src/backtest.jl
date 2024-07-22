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
    liquidity = initial_liquidity
    liquidity_curve = zeros(n)
    liquidity_curve[1] = liquidity
    assets_owned = Dict{String, Float64}()
    assets_owned_curves = Dict{String, Vector{Float64}}()
    active_orders = Vector{Tuple{UInt64, Order}}()
    trade_history = DataFrame(
        ticker = String[],
        size = Number[],
        sl = Float64[],
        tp = Float64[],
        entry_price = Float64[],
        exit_price = Union{Float64, Nothing}[],
    )
    for ticker in keys(assets)
        assets_owned[ticker] = 0
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
        for active_order in active_orders
            ticker = active_order[2].ticker
            size = active_order[2].size
            sl = active_order[2].sl
            tp = active_order[2].tp
            open = bars[ticker].open
            high = bars[ticker].high
            low = bars[ticker].low
            close = bars[ticker].close
            if size < 0
                sl *= -1
                tp *= -1
                open *= -1
                high *= -1
                low *= -1
                close *= -1
            end
            if open < sl || open > tp
                liquidity += bars[ticker].open * size
                assets_owned[ticker] -= size
                trade_history.exit_price[active_order[1]] = bars[ticker].open
            elseif low < sl
                liquidity += active_order[2].sl * size
                assets_owned[ticker] -= size
                trade_history.exit_price[active_order[1]] = active_order[2].sl
            elseif high > tp
                liquidity += active_order[2].tp * size
                assets_owned[ticker] -= size
                trade_history.exit_price[active_order[1]] = active_order[2].tp
            end
        end
        filter!(
            x -> begin
                high = bars[x[2].ticker].high
                low = bars[x[2].ticker].low
                return low < x[2].sl || low > x[2].tp || high > x[2].tp || high < x[2].sl
            end,
            active_orders
        )
        for order in new_orders
            liquidity -= order.size * bars[order.ticker].open
            assets_owned[order.ticker] += order.size
            push!(trade_history, (
                order.ticker,
                order.size,
                order.sl,
                order.tp,
                bars[order.ticker].open,
                nothing,
            ))
            push!(active_orders, (nrow(trade_history), order))
        end
        liquidity_curve[i] = liquidity
        for ticker in keys(assets)
            assets_owned_curves[ticker][i] = assets_owned[ticker]
        end
        new_orders = update(s, bars)
    end

    (
        ending_liquidity = liquidity,
        ending_assets_owned = assets_owned,
        liquidity_curve = liquidity_curve,
        assets_owned_curves = assets_owned_curves,
        equity_curve = compute_equity_curve(liquidity_curve, assets_owned_curves, assets),
        trade_history = trade_history,
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
