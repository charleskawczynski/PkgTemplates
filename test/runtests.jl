rm(joinpath(@__DIR__, "..", "Manifest.toml"), force = true) # Remove local Manifest.toml

test_env = joinpath(@__DIR__, "..", "env", "test")
push!(LOAD_PATH, test_env)
push!(LOAD_PATH, joinpath(@__DIR__, ".."))

using Pkg
Pkg.activate(test_env)
Pkg.instantiate(; verbose = true)

using Test
using PkgTemplates

@testset "Test generate" begin
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

    mkpath(directory)

    generate(t)

    rm(t.pkg_root, recursive=true, force=true) # Remove local generated packages
    rm(replace(t.pkg_root, ".jl" => ""), recursive=true, force=true) # Remove local generated packages
    generate(t)

    result = open(f->read(f, String), joinpath(t.pkg_root, ".gitignore"))
    expected = PkgTemplates.gitignore()
    @test result == expected

    result = open(f->read(f, String), joinpath(t.pkg_root, "test", "runtests.jl"))
    expected = PkgTemplates.runtests(t.pkg_name_no_ext)
    @test result == expected

    result = open(f->read(f, String), joinpath(t.pkg_root, "bors.toml"))
    expected = PkgTemplates.toml(t.bors)
    @test result == expected
end

