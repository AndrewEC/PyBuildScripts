. ./build-scripts/_Common.ps1

$ProgressPreference = "SilentlyContinue"
$global:ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$global:ErrorActionPreference = "Stop"

Write-Divider "Activating virtual environment"

$CurrentFolder = Get-Location | Split-Path -Leaf
$EnvFolder = "$CurrentFolder-venv"
Write-Host "Activating $EnvFolder"
Invoke-Expression "./$EnvFolder/Scripts/Activate.ps1"
