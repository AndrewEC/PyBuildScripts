. ./build-scripts/Write-Divider.ps1

$ProgressPreference = "SilentlyContinue"
$global:ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$global:ErrorActionPreference = "Stop"

function Invoke-ActivateScript {
    Write-Divider "Activating virtual environment"

    $CurrentFolder = Get-Location | Split-Path -Leaf
    $EnvFolder = "$CurrentFolder-venv"
    Write-Host "Using venv folder of [$EnvFolder]"

    $ActivateScriptPath = Join-Path ($PSScriptRoot | Split-Path -Parent) "$EnvFolder/Scripts/Activate.ps1"

    if (Test-Path $EnvFolder -PathType Container) {
        Write-Output "Virtual environment already exists. Activating virtual environment..."
        & $ActivateScriptPath
    } else {
        Write-Output "Virtual environment not found. Creating virtual environment and installing dependencies..."

        python -m venv $EnvFolder `
            && & $ActivatePath `
            && pip install -r requirements.txt
    }
}
