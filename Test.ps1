. ./build-scripts/_Common.ps1

function Invoke-TestScript {
    param(
        [Parameter(Mandatory)]
        [int]$CoverageRequirement,
        [Parameter(Mandatory)]
        [scriptblock]$CoverageCommand
    )
    Write-Divider "Running unit tests"

    $CoverageCommand.Invoke()

    if ($LASTEXITCODE -ne 0) {
        Write-Host "coverage command failed with status [$LASTEXITCODE]."
        exit
    }

    $CoverageReport = $(coverage report)
    if ($LASTEXITCODE -ne 0) {
        Write-Host "coverage report command failed with status [$LASTEXITCODE]."
        exit
    }

    $Expression = "(\d+)%$"

    $CumulativeCoverage = 0
    $Instances = 0
    foreach ($Line in $CoverageReport.Split("`n")) {
        if ($Line -match $Expression) {
            $CumulativeCoverage += [int]$Matches.1
            $Instances++
        }
    }

    Write-Host "Generating html coverage report..."
    coverage html
    if ($LASTEXITCODE -ne 0) {
        Write-Host "coverage html command failed with status [$LASTEXITCODE]."
        exit
    }

    Write-Host "Evaluating test coverage..."
    $CoverageLines = $CoverageReport.Split("`n")
    $Line = $CoverageLines[$CoverageLines.Length - 1]
    if ($Line -match $Expression) {
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