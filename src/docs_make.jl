function docs_make(t::Template)

    return "
rm(joinpath(@__DIR__, \"Manifest.toml\"), force = true)       # Remove local Manifest.toml
rm(joinpath(@__DIR__, \"..\", \"Manifest.toml\"), force = true) # Remove local Manifest.toml

# Avoiding having to add deps to docs/ environment:
env_viz = joinpath(@__DIR__, \"..\", \"env\", \"viz\")
env_doc = @__DIR__

using Pkg
push!(LOAD_PATH, env_viz); Pkg.activate(env_viz); Pkg.instantiate(; verbose=true)
push!(LOAD_PATH, env_doc); Pkg.activate(env_doc); Pkg.instantiate(; verbose=true)

cd(joinpath(@__DIR__, \"..\")) do
    Pkg.develop(PackageSpec(path=\".\"))
    Pkg.activate(pwd())
    Pkg.instantiate(; verbose=true)
end

using $(t.pkg_name_no_ext), Documenter

pages = Any[
    \"Home\" => \"index.md\",
]

mathengine = MathJax(Dict(
    :TeX => Dict(
        :equationNumbers => Dict(:autoNumber => \"AMS\"),
        :Macros => Dict(),
    ),
))

format = Documenter.HTML(
    prettyurls = get(ENV, \"CI\", nothing) == \"true\",
    mathengine = mathengine,
    collapselevel = 1,
)

makedocs(
    sitename = \"$(t.pkg_name)\",
    format = format,
    clean = true,
    strict = true,
    modules = [$(t.pkg_name_no_ext)],
    pages = pages,
)

deploydocs(
    repo = \"github.com/$(t.org)/$(t.pkg_name).git\",
    target = \"build\",
    push_preview = true,
)

"
end