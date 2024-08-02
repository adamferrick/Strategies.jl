function gbm_trajectory(s0, mu, sigma, dt, n)
    z = rand(Normal(0, sqrt(dt)), n)
    map!(x -> exp((mu - (sigma^2)/2) * dt + sigma * x), z, z)
    map(x -> s0 * x, cumprod(z))
end
