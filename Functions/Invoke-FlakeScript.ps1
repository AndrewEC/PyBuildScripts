. ./build-scripts/Write-Divider.ps1

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
