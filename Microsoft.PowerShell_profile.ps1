function Import-VsVars {
    param(
        [ValidateSet("x64", "x86", "arm64")]
        [string]$Arch = "x64"
    )

    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (!(Test-Path $vswhere)) {
        Write-Warning "vswhere not found: $vswhere"
        return
    }

    # Best: ask vswhere to locate the file directly (avoids path/newline weirdness)
    $vcvars = & $vswhere -latest -products * `
        -requires Microsoft.Component.MSBuild `
        -find "VC\Auxiliary\Build\vcvarsall.bat" | Select-Object -First 1

    # Normalize to a clean single-line string
    $vcvars = ([string]$vcvars).Trim() -replace "[`r`n]", ""

    if ([string]::IsNullOrWhiteSpace($vcvars) -or !(Test-Path $vcvars)) {
        # Fallback: get install path then build the expected path
        $vsPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath | Select-Object -First 1
        $vsPath = ([string]$vsPath).Trim() -replace "[`r`n]", ""

        if ([string]::IsNullOrWhiteSpace($vsPath)) {
            Write-Warning "Visual Studio path not found via vswhere."
            return
        }

        $vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat"
        if (!(Test-Path $vcvars)) {
            Write-Warning "vcvarsall.bat not found at: $vcvars"
            return
        }
    }

    # Import environment variables from vcvarsall
    cmd /c "`"$vcvars`" $Arch >nul && set" |
        ForEach-Object {
            if ($_ -match "^(.*?)=(.*)$") {
                Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
            }
        }
}

# Auto-load MSVC environment
Import-VsVars -Arch x64
