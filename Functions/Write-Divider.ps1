function Write-Divider {
    param(
        [Parameter(Mandatory)]
        [string] $Label
    )

    $UpperCaseLabel = $(Get-Culture).TextInfo.ToTitleCase($Label)

    Write-Host "`n---------- $UpperCaseLabel ----------`n"
}
