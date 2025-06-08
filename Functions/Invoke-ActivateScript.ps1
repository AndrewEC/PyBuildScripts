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

        python -m venv $EnvFolder

        $WaitCount = 0
        while ((-not (Test-Path $ActivateScriptPath -PathType Leaf)) -and ($WaitCount -lt 30)) {
            Start-Sleep -Seconds 0.1
            $WaitCount++
        }

        & $ActivateScriptPath
        pip install -r requirements.txt
    }
}
