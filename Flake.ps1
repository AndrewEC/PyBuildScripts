. ./Scripts/_Common.ps1

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
    }

    if (($null -ne $Results) -and ($Results.Trim() -ne "")) {
    } else {
        Write-Host "No errors to report."
    }
}