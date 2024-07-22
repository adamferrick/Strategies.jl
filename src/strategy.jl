abstract type Strategy end

function update end

struct Bar
    open::Float64
    high::Float64
    low::Float64
    close::Float64
    volume::Float64
end

Bar(df_row::DataFrameRow) = Bar(
    df_row.datetime,
    df_row.open,
    df_row.high,
    df_row.low,
    df_row.close,
    df_row.volume,
)

struct Order
    ticker::String
    size::Float64
    sl::Float64
    tp::Float64
end

Order(
    ticker::String,
    size::Number;
    sl::Float64 = size < 0 ? Inf : -Inf,
    tp::Float64 = size < 0 ? -Inf : Inf,
) = Order(ticker, size, sl, tp)
