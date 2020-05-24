#### GitHub Actions

abstract type GitHubAction end

"""
    DocBuild

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct DocBuild <: GitHubAction
    "Build name"
    build_name::String
    "Julia version"
    julia_version::String
end

function yaml(gha::DocBuild)
    return "name: Documentation

on:
  push:
    branches:
      - master
      - trying
      - staging
    tags: '*'
  pull_request:

jobs:
  $(gha.build_name):
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: julia-actions/setup-julia@latest
        with:
          version: $(gha.julia_version)
      - name: Install dependencies
        run: julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
      - name: Build and deploy
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }} # For authentication with GitHub Actions token
          DOCUMENTER_KEY: \${{ secrets.DOCUMENTER_KEY }} # For authentication with SSH deploy key
        run: julia --project=docs/ docs/make.jl
"
end


Base.@kwdef struct TagBot <: GitHubAction
end

function yaml(::TagBot)
    return "name: TagBot
on:
  schedule:
    - cron: 0 * * * *
jobs:
  TagBot:
    runs-on: ubuntu-latest
    steps:
      - uses: JuliaRegistries/TagBot@v1
        with:
          token: \${{ secrets.GITHUB_TOKEN }}
"
end

Base.@kwdef struct CompatHelper <: GitHubAction
  julia_version::String
end

function yaml(gha::CompatHelper)
    return "name: CompatHelper

on:
  schedule:
    - cron: '00 00 * * *'

jobs:
  CompatHelper:
    runs-on: ubuntu-latest
    steps:
      - uses: julia-actions/setup-julia@latest
        with:
          version: $(gha.julia_version)
      - name: Pkg.add(\"CompatHelper\")
        run: julia -e 'using Pkg; Pkg.add(\"CompatHelper\")'
      - name: CompatHelper.main()
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
        run: julia -e 'using CompatHelper; CompatHelper.main()'
"
end


Base.@kwdef struct CodeCov <: GitHubAction
    "Package name (with extension)"
    pkg_name::String
    "Julia version"
    julia_version::String
end

function yaml(gha::CodeCov)
    return "name: CodeCov

on:
  schedule:
    # * is a special character in YAML so you have to quote this string
    # Run at 2am every day:
    - cron:  '0 2 * * *'

jobs:
  coverage:
    runs-on: ubuntu-16.04
    strategy:
      matrix:
        julia-version: ['$(gha.julia_version)']
        project: ['$(gha.pkg_name)']

    steps:
    - uses: actions/checkout@v1.0.0
    - name: \"Set up Julia\"
      uses: julia-actions/setup-julia@v1
      with:
        version: \${{ matrix.julia-version }}

    - name: Install deps
      run: |
        set -o xtrace
        sudo apt-get update

    - name: Test with coverage
      env:
        JULIA_PROJECT: \"@.\"
      run: |
        julia --project=@. -e 'using Pkg; Pkg.instantiate()'
        julia --project=@. -e 'using Pkg; Pkg.test(coverage=true)'

    - name: Generate coverage file
      env:
        JULIA_PROJECT: \"@.\"
      run: julia --project=@. -e 'using Pkg; Pkg.add(\"Coverage\");
                                  using Coverage;
                                  LCOV.writefile(\"coverage-lcov.info\", Codecov.process_folder())'
      if: success()
    - name: Submit coverage
      uses: codecov/codecov-action@v1.0.2
      with:
        token: \${{secrets.CODECOV_TOKEN}}
      if: success()

"
end

Base.@kwdef struct FormatterCheck <: GitHubAction
    julia_version::String
end

function yaml(gha::FormatterCheck)
    return "name: JuliaFormatter

on: [pull_request]

jobs:
  format:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0
    - run: git fetch origin
    - uses: julia-actions/setup-julia@latest
      with:
        version: $(gha.julia_version)
    - name: Apply JuliaFormatter
      run: |
        julia --project=.dev .dev/format.jl
    - name: Check formatting diff
      run: |
        git diff --color=always --exit-code
"
end
