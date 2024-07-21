module Strategies

using DataFrames
using Dates

include("strategy.jl")
export Strategy, Bar, Order

include("backtest.jl")
export backtest

end
