module Strategies

using DataFrames
using Dates
using Distributions

include("strategy.jl")
export Strategy, Bar, Order

include("backtest.jl")
export backtest

include("performance_metrics.jl")
export maximum_drawdown_duration, maximum_drawdown

include("simulation.jl")
export bm_trajectory, gbm_trajectory

end
