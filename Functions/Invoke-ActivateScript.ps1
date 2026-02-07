. ./build-scripts/Write-Divider.ps1

function Invoke-ActivateScript {
    Write-Divider "Activating virtual environment"

    $EnvFolder = ".venv"
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

        if ($WaitCount -ge 30) {
            Write-Host "Activate script could not be found. Virtual environment could not be activated."
            exit
        }

        & $ActivateScriptPath

        python -m pip install --upgrade pip
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to upgrade pip to the latest version. Pip install failed with status [$LASTEXITCODE]."
            exit
        }
    }
}
