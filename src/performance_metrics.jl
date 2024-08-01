function maximum_drawdown_duration(equity_curve)
    equity_high = -Inf
    max_duration = 0
    current_drawdown_duration = 0
    for i in 1:length(equity_curve)
        if equity_curve[i] < equity_high
            current_drawdown_duration += 1
        else
            current_drawdown_duration = 0
            equity_high = equity_curve[i]
        end
        max_duration = max(current_drawdown_duration, max_duration)
    end
    max_duration
end
