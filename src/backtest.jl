spread(price::Float64, commission::Float64) = (price * (1 - commission), price * (1 + commission))

function price_with_commission(price::Float64, commission::Float64, is_sell::Bool)
    (bid, ask) = spread(price, commission)
    is_sell ? bid : ask
end

entry_price(o::Order, bar::DataFrameRow, commission::Float64) = price_with_commission(bar.open, commission, o.size < 0)

function process_active_orders!(active_orders, trade_history, bars, commission)
    liquidity_delta = 0
    assets_owned_deltas = Dict{String, Float64}()
    for ticker in keys(bars)
        assets_owned_deltas[ticker] = 0
    end
    for active_order in active_orders
        price = exit_price(active_order[2], bars[active_order[2].ticker])
        if price != nothing
            exit_price_commission_adjusted = price_with_commission(price, commission, active_order[2].size > 0)
            liquidity_delta += exit_price_commission_adjusted * active_order[2].size
            assets_owned_deltas[active_order[2].ticker] -= active_order[2].size
            trade_history.exit_price[active_order[1]] = price
        end
    end
    filter!(x -> exit_price(x[2], bars[x[2].ticker]) == nothing, active_orders)
    (liquidity_delta, assets_owned_deltas)
end

function exit_price(o::Order, bar::DataFrameRow)
    sl = o.sl
    tp = o.tp
    open = bar.open
    high = bar.high
    low = bar.low
    close = bar.close
    if o.size < 0
        sl *= -1
        tp *= -1
        open *= -1
        high *= -1
        low *= -1
        close *= -1
    end
    if open < sl || open > tp
        return bar.open
    elseif low < sl
        return o.sl
    elseif high > tp
        return o.tp
    end
    return nothing
end

function backtest(s::Strategy, assets::Dict{String, DataFrame}, initial_liquidity, commission)
    n = nrow(assets[iterate(keys(assets))[1]])
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
        bars = Dict{String, DataFrameRow}()
        for ticker in keys(assets)
            bars[ticker] = assets[ticker][i, :]
        end

        (liquidity_delta, assets_owned_deltas) = process_active_orders!(active_orders, trade_history, bars, commission)
        liquidity += liquidity_delta
        for ticker in keys(assets)
            assets_owned[ticker] += assets_owned_deltas[ticker]
        end

        for order in new_orders
            price = entry_price(order, bars[order.ticker], commission)
            liquidity -= order.size * price
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
