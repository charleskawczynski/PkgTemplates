
julia_version = "1.4"
org = "charleskawczynski"
pkg_name = "MyGeneratedPkg.jl"
directory = joinpath(@__DIR__, "..", "..", "GeneratedPackages")


ci = ContinuousIntegration(
    azure=Azure(;org=org, pkg_name=pkg_name, julia_version=julia_version),
    travis=Travis(;julia_version=julia_version),
    appveyor=AppVeyor(;julia_version=julia_version),
)

t = Template(;
    julia_version=julia_version,
    directory=directory,
    pkg_name=pkg_name,
    ci=ci,
)

generate(t)
