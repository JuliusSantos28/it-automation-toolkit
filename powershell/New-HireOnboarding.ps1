<#
.SYNOPSIS
    Provisions a new hire's Active Directory account end to end.

.DESCRIPTION
    Creates the AD user, assigns department-based security groups, creates a home
    folder, and logs every action. Designed to be triggered by an HR onboarding
    workflow (e.g. from a CSV export or HRIS webhook payload).

    All organization-specific values (domain, OUs, group names) are parameters with
    example defaults — replace them for your own environment.

.PARAMETER FirstName
.PARAMETER LastName
.PARAMETER Department  Used to look up the right security groups.
.PARAMETER StartDate
.PARAMETER Domain      Example default: corp.example.com

.EXAMPLE
    .\New-HireOnboarding.ps1 -FirstName "Alex" -LastName "Rivera" -Department "Engineering"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$FirstName,
    [Parameter(Mandatory)][string]$LastName,
    [Parameter(Mandatory)][string]$Department,
    [datetime]$StartDate = (Get-Date),
    [string]$Domain = "corp.example.com"
)

$ErrorActionPreference = "Stop"

# Department -> security groups mapping (example values)
$DepartmentGroups = @{
    "Engineering" = @("SG-Engineering", "SG-VPN-Access")
    "Sales"       = @("SG-Sales", "SG-CRM-Access")
    "Finance"     = @("SG-Finance", "SG-ERP-Access")
    "HR"          = @("SG-HR", "SG-HRIS-Access")
}

$sam = ("{0}.{1}" -f $FirstName, $LastName).ToLower()
$upn = "$sam@$Domain"
$ou  = "OU=Users,DC=corp,DC=example,DC=com"

Write-Host "Provisioning $FirstName $LastName ($sam)..."

try {
    New-ADUser -SamAccountName $sam `
               -UserPrincipalName $upn `
               -Name "$FirstName $LastName" `
               -GivenName $FirstName -Surname $LastName `
               -Path $ou `
               -AccountPassword (Read-Host "Temporary password" -AsSecureString) `
               -Enabled $true `
               -ChangePasswordAtLogon $true `
               -PassThru | Out-Null

    $groups = $DepartmentGroups[$Department]
    if (-not $groups) { Write-Warning "No group mapping for '$Department'; skipping groups." }
    foreach ($g in $groups) {
        Add-ADGroupMember -Identity $g -Members $sam
        Write-Host "  + added to $g"
    }

    $homeDir = "\\fileserver\home$\$sam"
    New-Item -ItemType Directory -Path $homeDir -Force | Out-Null
    Set-ADUser -Identity $sam -HomeDirectory $homeDir -HomeDrive "H:"

    "[$(Get-Date -Format s)] ONBOARDED $sam ($Department)" |
        Out-File -FilePath ".\onboarding.log" -Append -Encoding utf8

    Write-Host "Done. $sam provisioned." -ForegroundColor Green
}
catch {
    Write-Error "Onboarding failed: $_"
    exit 1
}
