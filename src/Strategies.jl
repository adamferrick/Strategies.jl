module Strategies

using DataFrames
using Dates

include("strategy.jl")
export Strategy, Bar, Order

include("backtest.jl")
export backtest

include("performance_metrics.jl")
export maximum_drawdown_duration

end
