function series_to_ohlc(s, interval_size::UInt)
    n = div(length(s), interval_size)
    result = DataFrame(open = zeros(n), high = zeros(n), low = zeros(n), close = zeros(n))
    for i in 1:n
        first = (i - 1) * interval_size + 1
        last = i * interval_size
        result.open[i] = s[first]
        result.high[i] = maximum(s[first:last])
        result.low[i] = minimum(s[first:last])
        result.close[i] = s[last]
    end
    result
end
