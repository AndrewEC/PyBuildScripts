$ErrorActionPreference = "Stop"

Write-Host "Creating combined module script..."

$FunctionScripts = Get-ChildItem ./Functions -File | Where-Object {
    $_.Extension -eq ".ps1"
}

if ($FunctionScripts.Length -eq 0) {
    throw "Could not find nay ps1 scripts in the ./Functions directory."
}

Write-Host "Found [$( $FunctionScripts.Length )] scripts to combine."

$FunctionsToExport = $FunctionScripts | ForEach-Object {
    $_.Name.Substring(0, $_.Name.Length - $_.Extension.Length)
}

$DestinationFile = "./BuildScripts.psm1"
Write-Host "Writing combined script to [$DestinationFile]."

if (Test-Path $DestinationFile -PathType Leaf) {
    Remove-Item $DestinationFile
}

$CombinedLines = $FunctionScripts | ForEach-Object {
    Get-Content $_
} | Where-Object {
    -not $_.StartsWith(".")
} | ForEach-Object {
    $_
}

$CombinedLines | Out-File $DestinationFile

Write-Host "Creating module manifest..."
New-ModuleManifest -Path ./Manifest.psd1 `
    -Guid (New-Guid) `
    -Author "AC" `
    -CompanyName "AC" `
    -FunctionsToExport $FunctionsToExport
