#Requires -RunAsAdministrator

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Start-AdminPowerShell {
    if (-not (Test-Administrator)) {
        Write-Host "This script requires Administrator privileges. Restarting with elevated permissions..." -ForegroundColor Yellow
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

# Call the admin check function
Start-AdminPowerShell

<#PSScriptInfo
.VERSION 1.0.1
.GUID 3b581edb-5d90-4fa1-ba15-4f2377275463
.AUTHOR Digital_Russkiy
.DESCRIPTION A comprehensive winget package management script with support for package installation, updates, and management
.TAGS Windows, winget, package-manager, installation
#>

#region Configuration
$script:DefaultScope = "user"
$script:DefaultSilent = $true
$script:DefaultAcceptAgreements = $true
$script:WingetReferenceUrls = @(
    "https://winget.run/",
    "https://github.com/microsoft/winget-pkgs/tree/master"
)
#endregion

#region Package Groups
$script:PackageGroups = @{
    DevelopmentTools = @(
        "IronmanSoftware.PowerShellUniversal",
        "Python.Python.3.12",
        "GoLang.Go",
        "OpenJS.NodeJS",
        "NodeJS.Node.LTS",
        "Rustlang.Rustup",
        "Anaconda.Miniconda3",
        "Microsoft.Git",
        "GitHub.cli"
    )

    TerminalTools    = @(
        "Microsoft.WindowsTerminal",
        "Microsoft.PowerShell",
        "Microsoft.PowerShellCore",
        "Microsoft.PowerShellPreview",
        "JanDeDobbeleer.OhMyPosh",
        "Nushell.Nushell",
        "vim.vim.nightly",
        "hpjansson.Chafa"
    )

    DatabaseTools    = @(
        "Oracle.MySQLShell",
        "Microsoft.SQLServerManagementStudio",
        "Oracle.MySQL",
        "Microsoft.AzureDataStudio"
    )

    Editors          = @(
        "Neovim.Neovim",
        "Anysphere.Cursor",
        "iA.iAWriter",
        "Figma.Figma",
        "Figma.FigmaAgent"
    )

    SystemTools      = @(
        "TranslucentTB",
        "Microsoft.DirectX",
        "Rufus.Rufus",
        "RevoUninstaller.RevoUninstaller",
        "Everything",
        "Microsoft.PowerToys",
        "GNU.Wget2"
    )

    MediaTools       = @(
        "KeePassXCTeam.KeePassXC",
        "Apple.iCloud",
        "Inkscape",
        "mpv.net",
        "BlenderFoundation.Blender"
    )

    GamingTools      = @(
        "Valve.Steam",
        "SteamCMD",
        "Hyper",
        "Odamex.Odamex",
        "GodotEngine.GodotEngine"
    )

    HardwareTools    = @(
        "SteelSeries.SteelSeriesEngine",
        "Elgato.StreamDeck"
    )
}
#endregion

#region Helper Functions
function Write-StatusMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    $color = switch ($Type) {
        'Info' { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
    }

    Write-Host $Message -ForegroundColor $color
}

function Test-WingetInstalled {
    [CmdletBinding()]
    param()

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-StatusMessage "winget is not installed. Please run winget-install.ps1 first to install winget." -Type Error
        Write-StatusMessage "You can download it from: https://github.com/asheroto/winget-install" -Type Warning
        return $false
    }
    return $true
}

function Get-WingetArguments {
    [CmdletBinding()]
    param(
        [string]$Command,
        [string]$PackageId,
        [string]$Scope = $script:DefaultScope,
        [bool]$Silent = $script:DefaultSilent,
        [bool]$AcceptAgreements = $script:DefaultAcceptAgreements
    )

    $arguments = @($Command, "--id", $PackageId)
    
    if ($Command -eq "install") {
        $arguments += "--scope", $Scope
    }

    if ($Silent) {
        $arguments += "--silent"
    }

    if ($AcceptAgreements) {
        $arguments += "--accept-package-agreements", "--accept-source-agreements"
    }

    return $arguments
}
#endregion

#region Core Functions
function Test-PackageInstalled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId
    )
    
    try {
        $output = winget list --id $PackageId --exact 2>&1
        return $output -match $PackageId
    }
    catch {
        Write-StatusMessage "Error checking package installation status: $_" -Type Error
        return $false
    }
}

function Install-WingetPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [string]$Scope = $script:DefaultScope,
        [bool]$Silent = $script:DefaultSilent,
        [bool]$AcceptAgreements = $script:DefaultAcceptAgreements
    )

    try {
        $arguments = Get-WingetArguments -Command "install" -PackageId $PackageId -Scope $Scope -Silent $Silent -AcceptAgreements $AcceptAgreements
        Write-StatusMessage "Installing $PackageId..."
        
        & winget @arguments
        
        if ($LASTEXITCODE -eq 0) {
            Write-StatusMessage "Successfully installed $PackageId" -Type Success
        }
        else {
            Write-StatusMessage "Failed to install $PackageId. Exit code: $LASTEXITCODE" -Type Warning
        }
    }
    catch {
        Write-StatusMessage "Error installing package: $_" -Type Error
    }
}

function Update-WingetPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [bool]$Silent = $script:DefaultSilent,
        [bool]$AcceptAgreements = $script:DefaultAcceptAgreements
    )

    try {
        $arguments = Get-WingetArguments -Command "upgrade" -PackageId $PackageId -Silent $Silent -AcceptAgreements $AcceptAgreements
        Write-StatusMessage "Updating $PackageId..." -Type Info
        
        & winget @arguments
        
        if ($LASTEXITCODE -eq 0) {
            Write-StatusMessage "Successfully updated $PackageId" -Type Success
        }
        else {
            Write-StatusMessage "No update needed or update failed for $PackageId" -Type Warning
        }
    }
    catch {
        Write-StatusMessage "Error updating package: $_" -Type Error
    }
}

function Install-OrUpdatePackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId,
        [string]$Scope = $script:DefaultScope
    )
    
    if (Test-PackageInstalled -PackageId $PackageId) {
        Update-WingetPackage -PackageId $PackageId
    }
    else {
        Install-WingetPackage -PackageId $PackageId -Scope $Scope
    }
}

function Install-PackageGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('DevelopmentTools', 'TerminalTools', 'DatabaseTools', 'Editors', 'SystemTools', 'MediaTools', 'GamingTools', 'HardwareTools')]
        [string]$GroupName
    )

    if (-not $script:PackageGroups.ContainsKey($GroupName)) {
        Write-StatusMessage "Invalid package group: $GroupName" -Type Error
        return
    }

    Write-StatusMessage "Installing packages from group: $GroupName" -Type Info
    foreach ($package in $script:PackageGroups[$GroupName]) {
        Install-OrUpdatePackage -PackageId $package
    }
}

function Update-AllPackages {
    [CmdletBinding()]
    param()

    Write-StatusMessage "Updating all installed packages..." -Type Info
    & winget upgrade --all --accept-package-agreements --accept-source-agreements
}

function Show-PackageInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$PackageId
    )

    Write-StatusMessage "Showing information for package: $PackageId" -Type Info
    & winget show $PackageId
}

function Search-Packages {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$SearchTerm
    )

    Write-StatusMessage "Searching for packages matching: $SearchTerm" -Type Info
    & winget search $SearchTerm
}

# Set up aliases for common commands
Set-Alias -Name wingets -Value Search-Packages
Set-Alias -Name winget-update -Value Update-AllPackages
Set-Alias -Name winget-info -Value Show-PackageInfo