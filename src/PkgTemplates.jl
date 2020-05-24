module PkgTemplates

using DocStringExtensions
using Pkg

export Template,
    generate

include("gitignore.jl")
include("runtests.jl")
include("runtests_gpu.jl")
include("formatter.jl")

include("azure.jl")
include("travis.jl")
include("appveyor.jl")
include("github_docker_ci.jl")
include("github_ci.jl")
include("ci.jl")

include("github_actions.jl")

include("bors.jl")


"""
    Template

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct Template
    "Organization name"
    org::String="charleskawczynski"
    "Directory where package is located"
    directory::String=""
    "Description"
    description::String="Package description goes here"
    "Add GPU test environment and gpu test runtests"
    gpu::Bool=true
    "Package name"
    pkg_name::String=""
    "Julia version"
    julia_version::String
    "Package name without the extension"
    pkg_name_no_ext::String=replace(pkg_name, ".jl" => "")
    "Package root directory"
    pkg_root::String=joinpath(directory, pkg_name)

    # CI
    "Continuous Integration"
    ci::ContinuousIntegration = ContinuousIntegration(
        azure=Azure(;org=org, pkg_name=pkg_name, julia_version=julia_version),
        travis=Travis(;julia_version=julia_version),
        appveyor=AppVeyor(;julia_version=julia_version),
        # github_ci=GitHubCI(;org=org, pkg_name=pkg_name, julia_version=julia_version),
        # github_docker_ci=GitHubDockerCI(;org=org, pkg_name=pkg_name, julia_version=julia_version),
    )

    # GitHub Actions
    "Doc build"
    doc_build::DocBuild = DocBuild("docs-build", julia_version)
    "TagBot"
    tag_bot::TagBot = TagBot()
    "CompatHelper"
    compat_helper::CompatHelper = CompatHelper(julia_version)
    "Code-coverage configuration"
    code_cov::CodeCov = CodeCov(pkg_name, julia_version)
    "Formatter Check"
    formatter_check::FormatterCheck = FormatterCheck(julia_version)

    "Bors configuration"
    bors::Bors = Bors(;checks=[ci_checks(ci)..., doc_build.build_name])
end

include("readme.jl")
include("docs_make.jl")
include("index_md.jl")

function write_contents_to_file(file, contents)
  open(file, "w") do io
    print(io, contents)
  end
end

function generate(t)

    # Use Pkg.generate
    cd(t.directory) do
      Pkg.generate(t.pkg_name_no_ext)
      # rename folder if ".jl" is in package name
      mv(t.pkg_name_no_ext, t.pkg_name)
    end

    mkpath(joinpath(t.pkg_root, "test"))

    mkpath(joinpath(t.pkg_root, "docs"))
    mkpath(joinpath(t.pkg_root, "docs", "src"))

    mkpath(joinpath(t.pkg_root, "env"))
    mkpath(joinpath(t.pkg_root, "env", "test"))
    mkpath(joinpath(t.pkg_root, "env", "viz"))

    if t.gpu
        env_gpu = joinpath(@__DIR__, "env_gpu.jl")
        cd(t.pkg_root) do
            run(`julia --project=env/gpu/ $(env_gpu)`)
        end
    end
    env_test = joinpath(@__DIR__, "env_test.jl")
    cd(t.pkg_root) do
        run(`julia --project=env/test/ $(env_test)`)
    end

    env_docs = joinpath(@__DIR__, "env_docs.jl")
    cd(t.pkg_root) do
        run(`julia --project=docs/ $(env_docs)`)
    end

    env_viz = joinpath(@__DIR__, "env_viz.jl")
    cd(t.pkg_root) do
        run(`julia --project=env/viz/ $(env_viz)`)
    end

    mkpath(joinpath(t.pkg_root, ".github"))
    mkpath(joinpath(t.pkg_root, ".github", "workflows"))

    mkpath(joinpath(t.pkg_root, ".dev"))

    contents = gitignore()
    file = joinpath(t.pkg_root, ".gitignore")
    write_contents_to_file(file, contents)

    contents = docs_make(t)
    file = joinpath(t.pkg_root, "docs", "make.jl")
    write_contents_to_file(file, contents)

    contents = index_md(t)
    file = joinpath(t.pkg_root, "docs", "src", "index.md")
    write_contents_to_file(file, contents)

    contents = formatter()
    file = joinpath(t.pkg_root, ".dev", "format.jl")
    write_contents_to_file(file, contents)

    contents = formatter_Project_toml()
    file = joinpath(t.pkg_root, ".dev", "Project.toml")
    write_contents_to_file(file, contents)

    contents = yaml(t.doc_build)
    file = joinpath(t.pkg_root, ".github", "workflows", "Docs.yml")
    write_contents_to_file(file, contents)

    contents = yaml(t.tag_bot)
    file = joinpath(t.pkg_root, ".github", "workflows", "TagBot.yml")
    write_contents_to_file(file, contents)

    contents = yaml(t.compat_helper)
    file = joinpath(t.pkg_root, ".github", "workflows", "CompatHelper.yml")
    write_contents_to_file(file, contents)

    contents = yaml(t.code_cov)
    file = joinpath(t.pkg_root, ".github", "workflows", "CodeCov.yml")
    write_contents_to_file(file, contents)

    contents = yaml(t.formatter_check)
    file = joinpath(t.pkg_root, ".github", "workflows", "Formatter.yml")
    write_contents_to_file(file, contents)

    contents = runtests(t.pkg_name_no_ext)
    file = joinpath(t.pkg_root, "test", "runtests.jl")
    write_contents_to_file(file, contents)

    if t.gpu
        contents = runtests_gpu(t.pkg_name_no_ext)
        file = joinpath(t.pkg_root, "test", "runtests_gpu.jl")
        write_contents_to_file(file, contents)
    end

    contents = toml(t.bors)
    file = joinpath(t.pkg_root, "bors.toml")
    write_contents_to_file(file, contents)

    contents = readme(t)
    file = joinpath(t.pkg_root, "README.md")
    write_contents_to_file(file, contents)

end

end # module
