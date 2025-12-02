function Invoke-PackageManager {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Install', 'Update', 'List', 'Status', 'Remove')]
        [string]$Action,
        [string]$PackageId,
        [string]$Scope = "user",
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not installed or not available in PATH"
        return
    }
    
    switch ($Action) {
        'Install' {
            if ($PackageId) {
                $result = winget list --id $PackageId --exact
                $command = if ($result -match $PackageId) {
                    "upgrade --id $PackageId"
                } else {
                    "install --id $PackageId --scope $Scope"
                }
                winget $command --silent --accept-package-agreements --accept-source-agreements
            } else {
                # Bulk installation from config
                Install-ConfiguredPackages -Force:$Force -SkipConfirmation:$SkipConfirmation
            }
        }
        'Update' { winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown }
        'List' { winget list }
        'Status' { winget upgrade }
        'Remove' { winget uninstall --id $PackageId --silent }
    }
}

# Package management functions and aliases
# Convenience function for package installation
function Install-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)][string]$PackageId,
        [string]$Scope = "user"
    )
    
    Invoke-PackageManager -Action Install -PackageId $PackageId -Scope $Scope
}

# Function to update all packages
function Update-AllPackages {
    [CmdletBinding()]
    param ()
    
    Invoke-PackageManager -Action Update
}

# Function to list installed packages
function Get-InstalledPackages {
    [CmdletBinding()]
    param ()
    
    Invoke-PackageManager -Action List
}

function Get-PackageStatus {
    [CmdletBinding()]
    param()
    
    Invoke-PackageManager -Action Status
}

function Update-ConfiguredPackages {
    [CmdletBinding()]
    param(
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    Invoke-PackageManager -Action Install -Force:$Force -SkipConfirmation:$SkipConfirmation
}

