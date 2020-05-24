#### AppVeyor

export AppVeyor

"""
    AppVeyor

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct AppVeyor
    "Julia version"
    julia_version::String
    "Checks"
    checks::String="continuous-integration/appveyor/branch"
end

function yaml(ci::AppVeyor)
    return "environment:
  matrix:
    - julia_version: $(ci.julia_version)

platform:
  - x64 # 64-bit

notifications:
  - provider: Email
    on_build_success: false
    on_build_failure: false
    on_build_status_changed: false

install:
  - ps: iex ((new-object net.webclient).DownloadString(\"https://raw.githubusercontent.com/JuliaCI/Appveyor.jl/version-1/bin/install.ps1\"))
  - ps: \"[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12\"
  - ps: (new-object net.webclient).DownloadFile(
        \"https://download.microsoft.com/download/2/E/C/2EC96D7F-687B-4613-80F6-E10F670A2D97/msmpisetup.exe\",
        \"C:\\projects\\MSMpiSetup.exe\")
  - C:\\projects\\MSMpiSetup.exe -unattend -minimal
  - set PATH=C:\\Program Files\\Microsoft MPI\\Bin;%PATH%

build_script:
  - echo \"%JL_BUILD_SCRIPT%\"
  - C:\\julia\\bin\\julia -e \"%JL_BUILD_SCRIPT%\"

test_script:
  - echo \"%JL_TEST_SCRIPT%\"
  - C:\\julia\\bin\\julia -e \"%JL_TEST_SCRIPT%\"

"
end
