
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
        python -m pip install --upgrade pip

        pip install -r requirements.txt
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

function Invoke-FlakeScript {
    Write-Divider "Running flake8"

    $Results = (python -m flake8)

    if ($LASTEXITCODE -ne 0) {
        Write-Host "flake8 failed with status [$LASTEXITCODE]."
        Write-Host "Flake report:"
        foreach ($Line in $Results.Split("`n")) {
            Write-Host $Line
        }
        exit
    } else {
        Write-Host "No linting errors to report."
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
