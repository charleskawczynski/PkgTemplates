#### ContinuousIntegration

export ContinuousIntegration

"""
    ContinuousIntegration

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct ContinuousIntegration
    "Azure CI"
    azure::Union{Nothing, Azure}=nothing
    "Travis CI"
    travis::Union{Nothing, Travis}=nothing
    "AppVeyor CI"
    appveyor::Union{Nothing, AppVeyor}=nothing
    "GitHub CI"
    github_ci::Union{Nothing, GitHubCI}=nothing
    "GitHub Docker CI"
    github_docker_ci::Union{Nothing, GitHubDockerCI}=nothing
end


function ci_checks(ci::ContinuousIntegration)
  checks = []
  ci.azure === nothing || push!(checks, ci.azure.checks)
  ci.travis === nothing || push!(checks, ci.travis.checks)
  ci.appveyor === nothing || push!(checks, ci.appveyor.checks)
  ci.github_ci === nothing || push!(checks, ci.github_ci.checks)
  ci.github_docker_ci === nothing || push!(checks, ci.github_docker_ci.checks)
  return checks
end
