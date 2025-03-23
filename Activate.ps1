. ./build-scripts/_Common.ps1

$ProgressPreference = "SilentlyContinue"
$global:ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$global:ErrorActionPreference = "Stop"

Write-Divider "Activating virtual environment"

$CurrentFolder = Get-Location | Split-Path -Leaf
$EnvFolder = "$CurrentFolder-venv"
Write-Host "Using venv folder of [$EnvFolder]"

if (Test-Path $EnvFolder -PathType Container) {
    Write-Output "Virtual environment already exists. Activating virtual environment..."
    Invoke-Expression "./$EnvFolder/Scripts/Activate.ps1"
} else {
    Write-Output "Virtual environment not found. Creating virtual environment and installing dependencies..."

    python -m venv $EnvFolder `
        && Invoke-Expression "./$EnvFolder/Scripts/Activate.ps1" `
        && pip install -r requirements.txt
}
