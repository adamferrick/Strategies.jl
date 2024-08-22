mutable struct SMA
    const n::Int
    values::Vector{Float64}
    indicator
end

SMA(n) = SMA(n, Vector{Float64}(), undef)

function Base.push!(sma::SMA, item::Float64)
    if length(sma.values) === 0
        push!(sma.values, item)
        sma.indicator = item
    elseif length(sma.values) < sma.n
        push!(sma.values, item)
        sma.indicator = (sma.indicator * (length(sma.values) - 1) + item) / length(sma.values)
    else
        push!(sma.values, item)
        last_value = popfirst!(sma.values)
        sma.indicator -= last_value / length(sma.values)
        sma.indicator += item / length(sma.values)
    end
end
