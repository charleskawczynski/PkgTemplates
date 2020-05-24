#### Azure

export Azure

"""
    Azure

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct Azure
    "Organization name"
    org::String
    "Package name (with extension)"
    pkg_name::String
    "Julia version"
    julia_version::String
    "Checks"
    checks::String="$(org).$(pkg_name)"
end

function toml(ci::Azure)
    return "trigger:
  batch: true
  branches:
    include:
    - staging
    - trying

jobs:
- job: Linux

  timeoutInMinutes: 0

  pool:
    vmImage: 'ubuntu-16.04'

  strategy:
    matrix:
      Julia $(ci.julia_version):
        JULIA_VERSION: '$(ci.julia_version)'

  steps:
  - bash: |
      set -o xtrace
      wget -nv https://julialang-s3.julialang.org/bin/linux/x64/\$(JULIA_VERSION)/julia-\$(JULIA_VERSION)-latest-linux-x86_64.tar.gz
      mkdir julia-\$(JULIA_VERSION)
      tar zxf julia-\$(JULIA_VERSION)-latest-linux-x86_64.tar.gz -C julia-\$(JULIA_VERSION) --strip-components 1
    displayName: 'Download and extract Julia'
  - bash: |
      set -o xtrace
      ./julia-\$(JULIA_VERSION)/bin/julia -e 'using InteractiveUtils; versioninfo()'
      ./julia-\$(JULIA_VERSION)/bin/julia --project=@. -e 'using Pkg; Pkg.instantiate()'
      ./julia-\$(JULIA_VERSION)/bin/julia --project=@. -e 'using Pkg; Pkg.test()'
    displayName: 'Run the tests'
    continueOnError: true

- job: macOS

  timeoutInMinutes: 0

  pool:
    vmImage: 'macOS-10.14'

  strategy:
    matrix:
      Julia $(ci.julia_version):
        JULIA_VERSION: '$(ci.julia_version)'

  steps:
  - bash: |
      set -o xtrace
      wget -nv https://julialang-s3.julialang.org/bin/mac/x64/\$(JULIA_VERSION)/julia-\$(JULIA_VERSION)-latest-mac64.dmg
      mkdir juliamnt
      hdiutil mount -readonly -mountpoint juliamnt julia-\$(JULIA_VERSION)-latest-mac64.dmg
      cp -a juliamnt/*.app/Contents/Resources/julia julia-\$(JULIA_VERSION)
    displayName: 'Download and extract Julia'
  - bash: |
      set -o xtrace
      ./julia-\$(JULIA_VERSION)/bin/julia -e 'using InteractiveUtils; versioninfo()'
      ./julia-\$(JULIA_VERSION)/bin/julia --project=@. -e 'using Pkg; Pkg.instantiate()'
      ./julia-\$(JULIA_VERSION)/bin/julia --project=@. -e 'using Pkg; Pkg.test()'
    env:
      MPICH_INTERFACE_HOSTNAME: localhost
    displayName: 'Run the tests'


- job: Windows

  timeoutInMinutes: 0

  pool:
    vmImage: 'VS2017-Win2016'

  strategy:
    matrix:
      Julia $(ci.julia_version):
        JULIA_VERSION: '$(ci.julia_version)'

  continueOnError: true

  steps:
  - powershell: |
      Set-PSDebug -Trace 1
      wget https://julialang-s3.julialang.org/bin/winnt/x64/\$(JULIA_VERSION)/julia-\$(JULIA_VERSION)-latest-win64.exe -OutFile julia-\$(JULIA_VERSION)-latest-win64.exe
      Start-Process -FilePath .\\julia-\$(JULIA_VERSION)-latest-win64.exe -ArgumentList \"/S /D=C:\\julia-$(JULIA_VERSION)\" -NoNewWindow -Wait
    displayName: 'Download and extract Julia'
  - powershell: |
      Set-PSDebug -Trace 1
      C:\\julia-$(JULIA_VERSION)\\bin\\julia.exe -e 'using InteractiveUtils; versioninfo()'
      C:\\julia-$(JULIA_VERSION)\\bin\\julia.exe --project=@. -e 'using Pkg; Pkg.instantiate()'
      C:\\julia-$(JULIA_VERSION)\\bin\\julia.exe --project=@. -e 'using Pkg; Pkg.test()'
    displayName: 'Run the tests'

"
end
