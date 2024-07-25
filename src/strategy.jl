abstract type Strategy end

function update end

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
