<#
.SYNOPSIS
    Deprovisions a departing employee's Active Directory account safely.

.DESCRIPTION
    Disables the account, removes all group memberships except Domain Users,
    moves it to a Disabled Users OU, hides it from the address list, and logs
    the action. Supports -WhatIf for dry runs.

    All organization-specific values are parameters with example defaults.

.PARAMETER SamAccountName
.PARAMETER DisabledOU   Example default: OU=Disabled,DC=corp,DC=example,DC=com

.EXAMPLE
    .\Disable-LeaverAccount.ps1 -SamAccountName "alex.rivera" -WhatIf
.EXAMPLE
    .\Disable-LeaverAccount.ps1 -SamAccountName "alex.rivera"
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$SamAccountName,
    [string]$DisabledOU = "OU=Disabled,DC=corp,DC=example,DC=com"
)

$ErrorActionPreference = "Stop"

$user = Get-ADUser -Identity $SamAccountName -Properties MemberOf
if (-not $user) { Write-Error "User '$SamAccountName' not found."; exit 1 }

if ($PSCmdlet.ShouldProcess($SamAccountName, "Disable and deprovision account")) {
    # Strip group memberships (keep Domain Users, which is the primary group)
    foreach ($groupDN in $user.MemberOf) {
        $group = Get-ADGroup -Identity $groupDN
        if ($group.Name -ne "Domain Users") {
            Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
            Write-Host "  - removed from $($group.Name)"
        }
    }

    Disable-ADAccount -Identity $user
    Set-ADUser -Identity $user -Replace @{msExchHideFromAddressLists = $true}
    Move-ADObject -Identity $user -TargetPath $DisabledOU

    "[$(Get-Date -Format s)] OFFBOARDED $SamAccountName" |
        Out-File -FilePath ".\offboarding.log" -Append -Encoding utf8

    Write-Host "Done. $SamAccountName disabled and moved to $DisabledOU." -ForegroundColor Green
}
