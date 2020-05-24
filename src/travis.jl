#### Travis

export Travis

"""
    Travis

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct Travis
    "Julia version"
    julia_version::String
    "Checks"
    checks::String="continuous-integration/travis-ci/push"
end

function yaml(ci::Travis)
    return "language: julia
julia:
  - $(ci.julia_version)

script:
  - julia --project --color=yes --check-bounds=yes -e 'using Pkg;
                                                       Pkg.instantiate();
                                                       Pkg.build();
                                                      '

  - julia --project --color=yes --check-bounds=yes -e 'using Pkg;
                                                       Pkg.test();
                                                      '
"
end
