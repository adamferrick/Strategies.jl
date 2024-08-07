function gbm_trajectory(s0, mu, sigma, dt, n)
    z = rand(Normal(0, sqrt(dt)), n)
    map!(x -> exp((mu - (sigma^2)/2) * dt + sigma * x), z, z)
    map(x -> s0 * x, cumprod(z))
end

function correlated_gbm_trajectories(s0::Vector{Float64}, r::Float64, volatilities::Vector{Float64}, epsilon::Matrix{Float64}, dt::Float64, n::Int64)
    L = cholesky(epsilon).L
    trajectories = [zeros(n) for i in 1:length(s0)]
    X = rand(Normal(), (length(s0), n))
    Y = L * X
    for i in 1:length(s0)
        for j in 1:n
            prev = j == 1 ? s0[i] : trajectories[i][j-1]
            trajectories[i][j] = prev * exp((r - 0.5 * volatilities[i]^2) * dt + volatilities[i] * sqrt(dt) * Y[i, j])
        end
    end
    trajectories
end
