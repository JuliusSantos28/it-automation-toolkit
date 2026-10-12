<#
.SYNOPSIS
    Exports an Active Directory user report for access reviews.

.DESCRIPTION
    Lists users in a target OU with department, title, enabled status, and last
    logon time — the raw material for quarterly access reviews and audit evidence.
    Exports to CSV.

.PARAMETER SearchBase  Example default: OU=Users,DC=corp,DC=example,DC=com
.PARAMETER OutputPath  Example default: .\access-review.csv
.PARAMETER StaleDays   Flags accounts inactive longer than this (default 90).

.EXAMPLE
    .\Get-ADUserReport.ps1 -StaleDays 60 -OutputPath .\q3-review.csv
#>
[CmdletBinding()]
param(
    [string]$SearchBase = "OU=Users,DC=corp,DC=example,DC=com",
    [string]$OutputPath = ".\access-review.csv",
    [int]$StaleDays = 90
)

$cutoff = (Get-Date).AddDays(-$StaleDays)

$report = Get-ADUser -Filter * -SearchBase $SearchBase `
    -Properties Department, Title, Enabled, LastLogonDate |
    Select-Object @{n="Name";e={$_.Name}},
                  @{n="sAMAccountName";e={$_.sAMAccountName}},
                  Department, Title, Enabled,
                  @{n="LastLogon";e={$_.LastLogonDate}},
                  @{n="Stale(>$StaleDays d)";e={
                      if ($_.LastLogonDate -and $_.LastLogonDate -lt $cutoff) { "YES" } else { "" }
                  }} |
    Sort-Object Name

$report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding utf8
Write-Host "Exported $($report.Count) users to $OutputPath" -ForegroundColor Green
