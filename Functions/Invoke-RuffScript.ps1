. ./build-scripts/Write-Divider.ps1

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
