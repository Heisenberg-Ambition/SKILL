[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Debug",

    [string]$CxxStandard = "",

    [int]$Jobs = [Environment]::ProcessorCount,

    [string]$Target = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SourceDir = (Get-Location).Path
$BuildDir = Join-Path $SourceDir "build"

if (-not (Test-Path (Join-Path $SourceDir "CMakeLists.txt"))) {
    throw "CMakeLists.txt not found in $SourceDir"
}

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    throw "cmake not found"
}

if ($Jobs -lt 1) {
    throw "Jobs must be a positive integer"
}

$cmakeArgs = @(
    "-S", $SourceDir,
    "-B", $BuildDir,
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
)

if ($CxxStandard) {
    $cmakeArgs += "-DCMAKE_CXX_STANDARD=$CxxStandard"
}

& cmake @cmakeArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$buildArgs = @("--build", $BuildDir, "--config", $BuildType, "--parallel", "$Jobs")
if ($Target) {
    $buildArgs += @("--target", $Target)
}

& cmake @buildArgs
exit $LASTEXITCODE
