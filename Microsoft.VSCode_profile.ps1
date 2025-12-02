#region Script Configuration
<#
.SYNOPSIS
Enhanced PowerShell profile with modern features and utilities.

.DESCRIPTION
A feature-rich PowerShell profile that provides:
- Modern command-line experience with syntax highlighting
- Smart command prediction and history
- Git integration and custom prompt
- Useful aliases and utility functions
- Performance-optimized module loading
- Enhanced error handling and command suggestions

.NOTES
Author: Svyatoslav Oleg Russkiy
Version: 5.0 (Optimized)
#>

#region Initialization
$ErrorActionPreference = 'Continue'
$profileLoadStart = Get-Date

# Display PowerShell version information
if (Get-Command Write-Banner -ErrorAction SilentlyContinue) {
    Write-Banner "|Power Shell!|" -FontName "Consolas" -FontSize 14
}
Write-Host "`nPowerShell Version Information:" -ForegroundColor Cyan
Write-Host "─────────────────────────────" -ForegroundColor DarkGray
$PSVersionTable.GetEnumerator() | Sort-Object Key | ForEach-Object {
    Write-Host ("{0,-20}: {1}" -f $_.Key, $_.Value) -ForegroundColor Gray
}
Write-Host "─────────────────────────────`n" -ForegroundColor DarkGray
# Load configuration first
. "$PSScriptRoot\Scripts\Core\Configuration.ps1"

#region Environment Setup
# Set up environment paths efficiently
$newPaths = @()
if ($Config -and $Config.EnvironmentPaths) {
    $newPaths = $Config.EnvironmentPaths | Where-Object { $_ -and (Test-Path $_) } | ForEach-Object { (Resolve-Path $_).Path }
    $env:PATH = ($env:PATH.Split(';') + $newPaths | Select-Object -Unique) -join ";"
}
# Check for admin privileges
$isAdmin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "⚡ Running with administrator privileges" -ForegroundColor Yellow
}
else {
    Write-Host " Is not currently Admin."
}

# node
# NOTE: Commented out because --openssl-legacy-provider is not allowed in NODE_OPTIONS
# by newer Node.js versions (used by Cursor/Electron apps). If needed for specific projects,
# set it manually: $env:NODE_OPTIONS = "--openssl-legacy-provider"
# $env:NODE_OPTIONS = "--openssl-legacy-provider"

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "Node.js is installed" -ForegroundColor Green
}
else {
    Write-Host "Node.js is not installed" -ForegroundColor Red
}

. "$PSScriptRoot\Scripts\Core\Logging.ps1"                              #Logging Functions.
. "$PSScriptRoot\Scripts\Core\Aliases.ps1"                              #main Alias Navigation.
. "$PSScriptRoot\Scripts\Core\Module-Management.ps1"                    #Module Managment Functions.
. "$PSScriptRoot\Scripts\Core\System\FileManagement\FetchDownload.ps1"  #Fetch Download Functions.
. "$PSScriptRoot\Scripts\Core\Navigation\Directory-Navigation.ps1"      #Directory Navigation
. "$PSScriptRoot\Scripts\Programs\Aseprite.ps1"                         #Asperite Functions.
. "$PSScriptRoot\Scripts\UI\Prompt-Configuration.ps1"                   #Prompt Configuration Functions.
. "$PSScriptRoot\Scripts\Networking\SSH-Tools.ps1"                      #SSH Tools.
. "$PSScriptRoot\Scripts\Networking\NetworkTools.ps1"                    #Network Tools.
. "$PSScriptRoot\Scripts\URL\LLM-Funk.ps1"                              #LLM functiwons Shortcuts.
. "$PSScriptRoot\Scripts\URL\Search-pkgs.ps1"                           #Search-pkgs Shortcuts.
. "$PSScriptRoot\Scripts\Core\Utility-Functions.ps1"                    #Utility Functions.
. "$PSScriptRoot\Scripts\Programs\Windows.ps1"                          #windows Funtions.
. "$PSScriptRoot\Scripts\Development\git\Github\GitHubFunctions.ps1"    #Github Funtionality.
. "$PSScriptRoot\Scripts\Development\git\Github\GitHubVisibility.ps1"   #GitHub Visibility Functions.
. "$PSScriptRoot\Scripts\Development\git\Github\Repositories.ps1"       #Github Repository Functions.
. "$PSScriptRoot\Scripts\URL\URL.ps1"                                   #URL Functions. 
. "$PSScriptRoot\Scripts\URL\passwords.ps1"                             #Password Functions.
. "$PSScriptRoot\Scripts\URL\Art.ps1"                                   #Art Functions.
. "$PSScriptRoot\Scripts\Core\FineAndFolderHandler.ps1"                 #Fine and Folder Handler Functions.
# Load scripts efficiently
# foreach ($category in $Config.LoadOrder) { ... }
#region Navigation 
function home { . "$PSScriptRoot\Scripts\Core\Navigation\cd-home.ps1" }
function fonts { . "$PSScriptRoot\Scripts\Core\Navigation\cd-fonts.ps1" }
#region End
#region Profile Completion
$loadTime = (Get-Date) - $profileLoadStart
Write-Host "PowerShell profile loaded in $([math]::Round($loadTime.TotalMilliseconds))ms!" -ForegroundColor Green

# Display available commands
Write-Host "`nAvailable Commands:" -ForegroundColor Cyan
Get-Content ".\text\Available Commands.txt"       
Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
# Helper function for pretty printing commands in columns
# function Show-CommandList {
#     param(
#         [Parameter(Mandatory)]
#         [array]$Commands
#     )
#     $maxCmdLen = ($Commands | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
#     foreach ($cmd in $Commands) {
#         $pad = " " * ($maxCmdLen - $cmd.Name.Length + 2)
#         Write-Host ("  " + $cmd.Name) -ForegroundColor Green -NoNewline
#         Write-Host ($pad + $cmd.Desc) -ForegroundColor Gray
#     }
# }
#region Search Scripts Functions.
function Search-Scripts {
    param(
        [Parameter(Mandatory)]
        [string]$SearchTerm
    )
    Get-Content ".\text\Available Commands.txt" | Where-Object { $_ -like "*$SearchTerm*" }
}

function Search-ArtStation {
    param(
        [Parameter(Mandatory)]
        [string]$Subject,
        [int]$MaxResults = 20,
        [switch]$OpenInBrowser,
        [switch]$BrowserOnly
    )
    $params = @{
        Subject    = $Subject
        MaxResults = $MaxResults
    }
    if ($OpenInBrowser) {
        $params['OpenInBrowser'] = $true
    }
    if ($BrowserOnly) {
        $params['BrowserOnly'] = $true
    }
    & "$PSScriptRoot\Scripts\Search\Search-ArtStation.ps1" @params
}


#region End




#region Error Handling

if (-not $global:ProfileCallDepth) { $global:ProfileCallDepth = 0 }
$global:ProfileCallDepth++
Write-Host "Profile call depth: $global:ProfileCallDepth"
if ($global:ProfileCallDepth -gt 10) {
    throw "Profile loaded too many times! Possible recursion."
}

if (-not (Get-Command Write-ProfileLog -ErrorAction SilentlyContinue)) {
    function Write-ProfileLog { param($msg, $Level) Write-Host "${Level}: ${msg}" }
}

try {
    Import-Module Terminal-Icons -ErrorAction Stop
}
catch {
    Write-Warning "Terminal-Icons failed to load: $($_.Exception.Message)"
}

