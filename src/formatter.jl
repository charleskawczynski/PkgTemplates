#### Formatter

function formatter()
    return "using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using JuliaFormatter

formatter_options = (
    indent = 4,
    margin = 80,
    always_for_in = true,
    whitespace_typedefs = true,
    whitespace_ops_in_indices = true,
    remove_extra_newlines = false,
)

filenames = readlines(`git diff --name-only --diff-filter=AM HEAD`)
filter!(f -> endswith(f, \".jl\"), filenames)

format(filenames; formatter_options...)"
end

function formatter_Project_toml()
    return "[deps]
JuliaFormatter = \"98e50ef6-434e-11e9-1051-2b60c6c9e899\"

[compat]
JuliaFormatter = \"0.3\"
"
end
