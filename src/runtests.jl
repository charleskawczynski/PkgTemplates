function runtests(name)
    return "rm(joinpath(@__DIR__, \"..\", \"Manifest.toml\"), force = true) # Remove local Manifest.toml

test_env = joinpath(@__DIR__, \"..\", \"env\", \"test\")
push!(LOAD_PATH, test_env)
push!(LOAD_PATH, joinpath(@__DIR__, \"..\"))

using Pkg
Pkg.activate(test_env)
Pkg.instantiate(; verbose = true)

using Test
using $name

@testset \"Test $name\" begin
    @test 1==1
end

"

end