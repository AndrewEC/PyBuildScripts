. ./Scripts/_Common.ps1

function Invoke-InstallScript {
    Write-Divider "Installing dependencies"

    pip install -r .\requirements.txt

    if ($LASTEXITCODE -ne 0) {
        Write-Host "pip failed with status [$LASTEXITCODE]."
        exit
    }
}