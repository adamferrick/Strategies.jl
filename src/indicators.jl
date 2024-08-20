mutable struct SMA
    const n::Int
    values::Vector{Float64}
    sma
end

SMA(n) = SMA(n, Vector{Float64}(), undef)

function Base.push!(sma::SMA, value::Float64)
    if length(sma.values) === 0
        push!(sma.values, value)
        sma.sma = value
    elseif length(sma.values) < sma.n
        push!(sma.values, value)
        sma.sma = (sma.sma * (length(sma.values) - 1) + value) / length(sma.values)
    else
        push!(sma.values, value)
        last_value = popfirst!(sma.values)
        sma.sma -= last_value / length(sma.values)
        sma.sma += value / length(sma.values)
    end
end
