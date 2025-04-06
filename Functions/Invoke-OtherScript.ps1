. ./build-scripts/Write-Divider.ps1

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