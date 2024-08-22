mutable struct SMA
    const n::Int
    values::Vector{Float64}
    indicator
end

SMA(n) = SMA(n, Vector{Float64}(), undef)

function update!(indicator::SMA, item::Float64)
    if length(indicator.values) === 0
        push!(indicator.values, item)
        indicator.indicator = item
    elseif length(indicator.values) < indicator.n
        push!(indicator.values, item)
        indicator.indicator = (indicator.indicator * (length(indicator.values) - 1) + item) / length(indicator.values)
    else
        push!(indicator.values, item)
        last_value = popfirst!(indicator.values)
        indicator.indicator -= last_value / length(indicator.values)
        indicator.indicator += item / length(indicator.values)
    end
end
