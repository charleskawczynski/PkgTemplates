#### Bors

"""
    Bors

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct Bors
    "bors checks"
    checks::Vector{String}
    "repo ID"
    id::String = ""
end

function toml(bors::Bors)
    checks = bors.checks
    status = join(["\"$(x)\"" for x in checks], ",\n")
    return "status = [
$status
]
delete_merged_branches = true
timeout_sec = 86400
block_labels = [ \"do-not-merge-yet\" ]
cut_body_after = \"<!--\"
"
end
