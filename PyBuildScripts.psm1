Set-StrictMode -Version Latest

$ProgressPreference = "SilentlyContinue"
$global:ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$global:ErrorActionPreference = "Stop"

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

function Invoke-AuditScript {
    Write-Divider "Auditing dependencies"

    pip-audit -r ./requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "pip-audit failed with status [$LASTEXITCODE]."
        exit
    }
}

function Invoke-InstallScript {
    Write-Divider "Installing dependencies"

    pip install -r .\requirements.txt

    if ($LASTEXITCODE -ne 0) {
        Write-Host "pip failed with status [$LASTEXITCODE]."
        exit
    }
}

function Invoke-OtherScript {
    param(
        [Parameter(Mandatory)]
        [string]$TitleMessage,
        [Parameter(Mandatory)]
        [int[]]$ExpectedStatuses,
        [Parameter(Mandatory)]
        [scriptblock]$Block
    )

    Write-Divider $TitleMessage

    Invoke-Command $Block
    if (-not ($ExpectedStatuses.Contains($LASTEXITCODE))) {
        Write-Host "Script failed with status [$LASTEXITCODE]"
        exit
    }
}

function Invoke-RuffScript {
    Write-Divider "Running ruff"

    $Results = (ruff check --config .\ruff.toml)

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ruff failed with status [$LASTEXITCODE]."
        Write-Host "Ruff report:"
        foreach ($Line in $Results.Split("`n")) {
            Write-Host $Line
        }
        exit
    } else {
        Write-Host "No linting errors to report."
    }
}

function Invoke-TestScript {
    param(
        [Parameter(Mandatory)]
        [int]$CoverageRequirement,
        [Parameter(Mandatory)]
        [scriptblock]$CoverageCommand
    )
    Write-Divider "Running unit tests"

    Invoke-Command $CoverageCommand
    if ($LASTEXITCODE -ne 0) {
        Write-Host "coverage command failed with status [$LASTEXITCODE]."
        exit
    }

    $CoverageReport = $(coverage report)
    if ($LASTEXITCODE -ne 0) {
        Write-Host "coverage report command failed with status [$LASTEXITCODE]."
        exit
    }

    Write-Host "Generating html coverage report..."
    coverage html
    if ($LASTEXITCODE -ne 0) {
        Write-Host "coverage html command failed with status [$LASTEXITCODE]."
        exit
    }

    Write-Host "Evaluating test coverage..."
    $CoverageLines = $CoverageReport.Split("`n")
    $LastLine = $CoverageLines[$CoverageLines.Length - 1]
    $Expression = "(\d+)%$"
    if ($LastLine -match $Expression) {
        $Percentage = [int]$Matches.1
        Write-Host "Test code coverage was [$Percentage%]."

        if ($Percentage -lt $CoverageRequirement) {
            Write-Host "Test code coverage was less than required coverage of [$CoverageRequirement]"
            exit
        }
    } else {
        Write-Host "Could not find coverage percent in `"coverage`" report."
        exit
    }
}
function Write-Divider {
    param(
        [Parameter(Mandatory)]
        [string] $Label
    )

    $UpperCaseLabel = $(Get-Culture).TextInfo.ToTitleCase($Label)

    Write-Host "`n---------- $UpperCaseLabel ----------`n"
}
