#### GitHubDockerCI

"""
    GitHubDockerCI

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct GitHubDockerCI
    "Organization name"
    org::String
    "Package name (with extension)"
    pkg_name::String
    "Package name (no extension)"
    pkg_name_no_ext::String = replace(pkg_name, ".jl" => "")
    "Julia version"
    julia_version::String
    "Build name"
    build_name::String="dockerci"
    "Checks"
    checks::String="$(build_name) ($(julia_version), ubuntu-latest)"
end

function yaml(ci::GitHubDockerCI)
    return "name: DockerCI

on:
  push:
    branches: [ master, staging, trying ]
  pull_request:
    branches: [ master, staging, trying ]

jobs:
  $(ci.build_name):
    runs-on: \${{ matrix.os }}
    strategy:
      matrix:
        julia-version: [$(ci.julia_version)]
        os: [ubuntu-latest]

    steps:
    - uses: actions/checkout@v2
    - name: Build and test
      run: |
        docker build . --file Dockerfile --tag $(ci.pkg_name_no_ext):PR
        docker images
        docker run $(ci.pkg_name_no_ext):PR
"
end
