. ./build-scripts/Write-Divider.ps1

function Invoke-AuditScript {
    Write-Divider "Auditing dependencies"

    pip-audit -r ./requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "pip-audit failed with status [$LASTEXITCODE]."
        exit
    }
}