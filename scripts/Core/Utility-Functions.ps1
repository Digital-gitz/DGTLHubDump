#region Utility Functions
<#
.SYNOPSIS
Consolidated utility functions for PowerShell profile

.DESCRIPTION
This file contains all utility functions used throughout the PowerShell profile,
organized by category for better maintainability.
#>

# Ensure Config is available with comprehensive fallback defaults
# if (-not $Config) {
#     $Config = @{
#         Paths         = @{
#             DGTLHubDump = "C:\Users\Digital_Russkiy\Documents\DGTLHubDump"
#             GitHub      = Join-Path $env:USERPROFILE "Documents\GitHub"
#         }
#         URLs          = @{
#             IPInfo          = "https://ipinfo.io"
#             GitHub          = "https://github.com"
#             DGTLHubDumpRepo = "https://github.com/Digital-gitz/DGTLHubDump"
#             PowerShellRepo  = "https://github.com/Digital-gitz/PowerShell"
#             QRCode          = "https://qrenco.de"
#             GoPackages      = "https://pkg.go.dev/search"
#         }
#         Applications  = @{
#             TwitchOverlay = @{
#                 Update = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\Update.exe"
#                 App    = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\TransparentTwitchChatWPF.exe"
#             }
#         }
#         ErrorHandling = @{
#             CommandSuggestionTimeout = 3
#             MaxCommandSuggestions    = 5
#             LevenshteinThreshold     = 3
#             MaxCommandsToSearch      = 100
#         }
#         Logging       = @{
#             Enabled          = $true
#             IncludeTimestamp = $true
#             IncludeSource    = $true
#         }
#     }
# }
#region System Functions
function Startup {
    Start-Process "explorer.exe" "shell:startup"
    Start-Process "ms-settings:startupapps"
}

function sleep {
    Write-Host "`n💤 Putting computer to sleep..." -ForegroundColor Cyan
    try {
        rundll32.exe powrprof.dll, SetSuspendState 0, 1, 0
    }
    catch {
        Write-Host "Failed to put computer to sleep: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function restart {
    Write-Host "`n🔄 Restarting PowerShell session..." -ForegroundColor Cyan
    Clear-Host
    . $PROFILE
    Write-Host "✓ PowerShell session restarted successfully!" -ForegroundColor Green
}

function programs {
    Write-Host "`nWMIC Installed Programs:" -ForegroundColor Cyan
    wmic product get name | Sort-Object

    Write-Host "`nWinget Installed Programs:" -ForegroundColor Cyan
    winget list | Sort-Object -Property Name

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "`nChocolatey Installed Programs:" -ForegroundColor Cyan
        choco list --local-only | Sort-Object
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "`nScoop Installed Programs:" -ForegroundColor Cyan
        scoop list | Sort-Object
    }
}

function Get-MyIP {
    try {
        Write-Host "Fetching your IP information..." -ForegroundColor Cyan
        $response = Invoke-RestMethod -Uri $Config.URLs.IPInfo -Method Get
        Write-Host "IP Information:" -ForegroundColor Green
        Write-Host "IP: $($response.ip)" -ForegroundColor Gray
        Write-Host "City: $($response.city)" -ForegroundColor Gray
        Write-Host "Region: $($response.region)" -ForegroundColor Gray
        Write-Host "Country: $($response.country)" -ForegroundColor Gray
        Write-Host "Location: $($response.loc)" -ForegroundColor Gray
        Write-Host "Organization: $($response.org)" -ForegroundColor Gray
        Write-Host "Timezone: $($response.timezone)" -ForegroundColor Gray
    }
    catch {
        Write-Host "Error fetching IP information: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-BIOSInfo {
    try {
        $scriptPath = Join-Path $PSScriptRoot "Scripts\Core\System\check-bios.ps1"
        
        if (Test-Path $scriptPath) {
            Write-Host "Checking BIOS information..." -ForegroundColor Cyan
            & $scriptPath
        }
        else {
            Write-Host "Error: BIOS check script not found at: $scriptPath" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error running BIOS check: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-NyanCat {
    try {
        Write-Host "Fetching Nyan Cat animation..." -ForegroundColor Cyan
        
        if (-not (Get-Command curl -ErrorAction SilentlyContinue)) {
            Write-Host "Error: curl is not available. Please install curl first." -ForegroundColor Red
            return
        }
        
        if (-not (Get-Command lolcat -ErrorAction SilentlyContinue)) {
            Write-Host "Error: lolcat is not available. Please install lolcat first." -ForegroundColor Red
            Write-Host "You can install it via: gem install lolcat" -ForegroundColor Yellow
            return
        }
        
        curl -s ascii.live/nyan | lolcat
        
        Write-Host "Nyan Cat animation completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error showing Nyan Cat: $($_.Exception.Message)" -ForegroundColor Red
    }
}
#endregion System Functions

#region Navigation Functions

function Get-DirectoryFiles {
    param([string]$Path = ".")
    
    if (-not (Test-Path $Path -PathType Container)) {
        Write-Error "Directory '$Path' does not exist or is not a directory."
        return
    }
    
    Get-ChildItem -Path $Path -File | ForEach-Object {
        Write-Host $_.Name
    }
}
#endregion Navigation Functions

#region Development Functions
function global:edit_powershell {
    Write-Host "Opening PowerShell Profile..." -ForegroundColor Cyan
    
    $profilePath = $PROFILE
    $profileDir = Split-Path $profilePath -Parent
    
    try {
        $null = Invoke-WebRequest -Uri $Config.URLs.GitHub -UseBasicParsing -TimeoutSec 5
        Start-Process $Config.URLs.PowerShellRepo
    }
    catch {
        Write-Warning "Could not connect to GitHub. Please check your internet connection."
    }

    if (Test-Path $profileDir) {
        Set-Location $profileDir
    }

    if (Test-Path (Join-Path $profileDir ".git")) {
        Write-Host "`nChecking Git Status..." -ForegroundColor Cyan
        Set-Location $profileDir
        git status

        $changes = git status --porcelain
        if ($changes) {
            Write-Host "`nFound uncommitted changes:" -ForegroundColor Yellow
            $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            Write-Host "`nChanges:" -ForegroundColor Cyan
            git diff
        }
        else {
            Write-Host "No uncommitted changes found." -ForegroundColor Green
        }

        Write-Host "`nRecent Commits:" -ForegroundColor Cyan
        git log --oneline -n 5
    }
}

function global:commit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Message = "Update",
        
        [Parameter(Mandatory = $false)]
        [switch]$Push,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowStatus
    )

    Write-ProfileLog "Starting git commit process..." -Level 'Info' -Source 'Git'

    if ($ShowStatus) {
        git status
    }

    git add .
    git commit -m $Message

    if ($Push) {
        git push
    }

    Write-ProfileLog "Commit process completed" -Level 'Success' -Source 'Git'
}

function Search-GoPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,
        
        [switch]$OpenInBrowser
    )
    
    try {
        Write-Host "Searching Go packages for: $SearchTerm" -ForegroundColor Cyan
        
        $searchUrl = "$($Config.URLs.GoPackages)?q=$([System.Web.HttpUtility]::UrlEncode($SearchTerm))"
        
        if ($OpenInBrowser) {
            Write-Host "Opening search results in browser..." -ForegroundColor Green
            Start-Process $searchUrl
        }
        else {
            Write-Host "Search URL: $searchUrl" -ForegroundColor Yellow
            Write-Host "Use -OpenInBrowser switch to open results directly in your browser" -ForegroundColor Gray
        }
        
        Write-Host "Search completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error searching Go packages: $($_.Exception.Message)" -ForegroundColor Red
    }
}
#endregion Development Functions

#region Web and URL Functions
function New-QRCode {
    param([Parameter(Mandatory = $true)][string]$Url)
    
    try {
        if ($Url -notmatch '^https?://') {
            Write-Host "Error: Please provide a valid URL starting with http:// or https://" -ForegroundColor Red
            return
        }
        
        $qrCodeUrl = "$($Config.URLs.QRCode)/$Url"
        
        Write-Host "Generating QR code for: $Url" -ForegroundColor Cyan
        Write-Host "QR Code URL: $qrCodeUrl" -ForegroundColor Green
        
        Start-Process $qrCodeUrl
        
        Write-Host "QR code opened in browser successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error generating QR code: $($_.Exception.Message)" -ForegroundColor Red
    }
}
#endregion Web and URL Functions

#region Application Functions
function TwitchOverlay {
    $updatePath = $Config.Applications.TwitchOverlay.Update
    $appPath = $Config.Applications.TwitchOverlay.App

    Write-Host "Starting Twitch Chat Overlay update..." -ForegroundColor Cyan
    Start-Process -FilePath $updatePath -Wait

    Write-Host "Launching Twitch Chat Overlay..." -ForegroundColor Green
    Start-Process -FilePath $appPath
}
#endregion Application Functions

#region Function Discovery and Listing
function global:Get-AllFunctions {
    <#
    .SYNOPSIS
    Displays all available functions from all loaded scripts

    .DESCRIPTION
    Scans all loaded functions and organizes them by category based on their names
    and common patterns. Provides a comprehensive overview of available functionality.

    .PARAMETER Category
    Filter to show only functions from a specific category

    .PARAMETER Search
    Search for functions containing the specified text

    .EXAMPLE
    Get-AllFunctions
    Shows all available functions organized by category

    .EXAMPLE
    Get-AllFunctions -Category "Social"
    Shows only social media related functions

    .EXAMPLE
    Get-AllFunctions -Search "git"
    Shows functions containing "git" in their name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('System', 'Navigation', 'Development', 'Social', 'Web', 'Application', 'Utility', 'All')]
        [string]$Category = 'All',
        
        [Parameter(Mandatory = $false)]
        [string]$Search
    )

    # Get all functions from the current session
    $allFunctions = Get-Command -CommandType Function | Where-Object { 
        $_.Name -notlike "Microsoft.PowerShell*" -and 
        $_.Name -notlike "*Internal*" -and
        $_.Name -notlike "*Private*"
    }

    # Define function categories and their patterns
    $functionCategories = @{
        'System'      = @{
            Patterns    = @('Get-*', 'Set-*', 'Start-*', 'Stop-*', 'Restart-*', 'sleep', 'programs', 'Startup')
            Description = 'System management and control functions'
        }
        'Navigation'  = @{
            Patterns    = @('*Location*', '*Path*', '*Directory*', 'ghub', 'ddump', 'goto')
            Description = 'Directory navigation and path management'
        }
        'Development' = @{
            Patterns    = @('*Git*', '*Commit*', '*Repo*', 'edit_*', 'Search-*Packages')
            Description = 'Development and coding related functions'
        }
        'Social'      = @{
            Patterns    = @('*Social*', 'facebook', 'twitter', 'youtube', 'twitch', 'instagram', 'reddit', 'linkedin', 'tiktok', 'discord', 'pinterest', 'tumblr', 'rumble', 'kick', 'bsky', 'threads', 'deviantart', 'artstation', 'spotify')
            Description = 'Social media and communication platforms'
        }
        'Web'         = @{
            Patterns    = @('*Url*', '*Web*', '*Http*', '*IP*', '*QR*')
            Description = 'Web and internet related functions'
        }
        'Application' = @{
            Patterns    = @('*App*', '*Program*', '*Game*', '*Overlay*', '*Aseprite*', '*Doom*', '*Godot*')
            Description = 'Application and program launchers'
        }
        'Utility'     = @{
            Patterns    = @('*Help*', '*List*', '*Show*', '*Display*', '*Search*', '*Find*', '*Get-*Functions*')
            Description = 'Utility and helper functions'
        }
    }

    # Categorize functions
    $categorizedFunctions = @{}
    foreach ($category in $functionCategories.Keys) {
        $categorizedFunctions[$category] = @()
    }

    foreach ($function in $allFunctions) {
        $assigned = $false
        foreach ($category in $functionCategories.Keys) {
            foreach ($pattern in $functionCategories[$category].Patterns) {
                if ($function.Name -like $pattern) {
                    $categorizedFunctions[$category] += $function
                    $assigned = $true
                    break
                }
            }
            if ($assigned) { break }
        }
        
        # If no category matched, put in Utility
        if (-not $assigned) {
            $categorizedFunctions['Utility'] += $function
        }
    }

    # Filter by search term if specified
    if ($Search) {
        foreach ($cat in $categorizedFunctions.Keys) {
            $categorizedFunctions[$cat] = $categorizedFunctions[$cat] | Where-Object { 
                $_.Name -like "*$Search*" 
            }
        }
    }

    # Display results
    Write-Host "`n🔍 Available Functions" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor DarkGray
    
    if ($Search) {
        Write-Host "Search term: '$Search'" -ForegroundColor Yellow
    }

    $totalFunctions = 0
    foreach ($cat in $categorizedFunctions.Keys) {
        if ($Category -eq 'All' -or $Category -eq $cat) {
            if ($categorizedFunctions[$cat].Count -gt 0) {
                $emoji = switch ($cat) {
                    'System' { '⚙️' }
                    'Navigation' { '🗂️' }
                    'Development' { '💻' }
                    'Social' { '📱' }
                    'Web' { '🌐' }
                    'Application' { '🎮' }
                    'Utility' { '🛠️' }
                    default { '📋' }
                }
                
                Write-Host "`n$emoji $cat Functions ($($categorizedFunctions[$cat].Count)):" -ForegroundColor Yellow
                Write-Host $functionCategories[$cat].Description -ForegroundColor DarkGray
                Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                
                $categorizedFunctions[$cat] | Sort-Object Name | ForEach-Object {
                    Write-Host "• $($_.Name)" -ForegroundColor Gray
                }
                
                $totalFunctions += $categorizedFunctions[$cat].Count
            }
        }
    }

    Write-Host "`n📊 Summary:" -ForegroundColor Cyan
    Write-Host "Total functions found: $totalFunctions" -ForegroundColor Green
    
    if ($Category -eq 'All') {
        Write-Host "`n💡 Usage Examples:" -ForegroundColor Cyan
        Write-Host "• Get-AllFunctions -Category Social" -ForegroundColor Gray
        Write-Host "• Get-AllFunctions -Search 'git'" -ForegroundColor Gray
        Write-Host "• Get-AllFunctions -Category Development -Search 'commit'" -ForegroundColor Gray
    }
}

function global:Get-FunctionHelp {
    <#
    .SYNOPSIS
    Shows detailed help for a specific function

    .DESCRIPTION
    Displays comprehensive help information for a function including
    synopsis, description, parameters, and examples.

    .PARAMETER FunctionName
    The name of the function to get help for

    .EXAMPLE
    Get-FunctionHelp -FunctionName "Open-SocialChat"
    Shows detailed help for the Open-SocialChat function
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FunctionName
    )

    try {
        $function = Get-Command -Name $FunctionName -CommandType Function -ErrorAction Stop
        
        Write-Host "`n📖 Function Help: $FunctionName" -ForegroundColor Cyan
        Write-Host "=====================================" -ForegroundColor DarkGray
        
        # Get help content
        $help = Get-Help -Name $FunctionName -Full -ErrorAction SilentlyContinue
        
        if ($help) {
            if ($help.Synopsis) {
                Write-Host "`n📝 Synopsis:" -ForegroundColor Yellow
                Write-Host $help.Synopsis -ForegroundColor Gray
            }
            
            if ($help.Description) {
                Write-Host "`n📄 Description:" -ForegroundColor Yellow
                Write-Host $help.Description.Text -ForegroundColor Gray
            }
            
            if ($help.Parameters) {
                Write-Host "`n⚙️ Parameters:" -ForegroundColor Yellow
                $help.Parameters.Parameter | ForEach-Object {
                    Write-Host "• $($_.Name)" -ForegroundColor Cyan
                    if ($_.Description) {
                        Write-Host "  $($_.Description.Text)" -ForegroundColor Gray
                    }
                    if ($_.Type) {
                        Write-Host "  Type: $($_.Type.Name)" -ForegroundColor DarkGray
                    }
                }
            }
            
            if ($help.Examples) {
                Write-Host "`n💡 Examples:" -ForegroundColor Yellow
                $help.Examples.Example | ForEach-Object {
                    Write-Host "• $($_.Title)" -ForegroundColor Cyan
                    if ($_.Code) {
                        Write-Host "  $($_.Code)" -ForegroundColor Gray
                    }
                    if ($_.Remarks) {
                        Write-Host "  $($_.Remarks.Text)" -ForegroundColor DarkGray
                    }
                }
            }
        }
        else {
            Write-Host "No detailed help available for this function." -ForegroundColor Yellow
            Write-Host "Function exists but may not have help documentation." -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Function '$FunctionName' not found." -ForegroundColor Red
        Write-Host "Use 'Get-AllFunctions' to see available functions." -ForegroundColor Yellow
    }
}
#endregion Function Discovery and Listing

#region Error Handling and Logging
function Write-ProfileLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info',
        
        [Parameter(Mandatory = $false)]
        [string]$Source = 'Profile'
    )
    
    if (-not $Config.Logging.Enabled) { return }
    
    $timestamp = if ($Config.Logging.IncludeTimestamp) { 
        Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    }
    else { "" }
    
    $sourceInfo = if ($Config.Logging.IncludeSource) { "[$Source]" } else { "" }
    
    $color = switch ($Level) {
        'Info' { 'Cyan' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        'Success' { 'Green' }
    }
    
    $logMessage = if ($timestamp) { "[$timestamp] $sourceInfo [$Level] $Message" } else { "$sourceInfo [$Level] $Message" }
    Write-Host $logMessage -ForegroundColor $color
}

function Get-CommandSuggestion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowHelp
    )

    $commandName = if ($ErrorMessage -match "The term '([^']+)'") {
        $matches[1]
    }
    else {
        return
    }

    $allCommands = Get-Command -All -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -notlike "Microsoft.PowerShell*" } |
    Select-Object -First $Config.ErrorHandling.MaxCommandsToSearch

    $suggestions = $allCommands | ForEach-Object {
        $distance = Get-LevenshteinDistance -String1 $commandName -String2 $_.Name
        [PSCustomObject]@{
            Name     = $_.Name
            Distance = $distance
            Type     = $_.CommandType
        }
    } | Where-Object { $_.Distance -le $Config.ErrorHandling.LevenshteinThreshold } | 
    Sort-Object Distance | 
    Select-Object -First $Config.ErrorHandling.MaxCommandSuggestions

    if ($suggestions) {
        Write-Host "`nDid you mean one of these commands?" -ForegroundColor Yellow
        $suggestions | ForEach-Object {
            Write-Host "  $($_.Name) ($($_.Type))" -ForegroundColor Cyan
            
            if ($ShowHelp) {
                try {
                    $helpInfo = Get-Help $_.Name -ErrorAction SilentlyContinue -Timeout 1
                    if ($helpInfo.Synopsis) {
                        Write-Host "    $($helpInfo.Synopsis)" -ForegroundColor DarkGray
                    }
                }
                catch { }
            }
        }
        Write-Host ""
    }
}

$script:levenshteinCache = @{}
function Get-LevenshteinDistance {
    param(
        [Parameter(Mandatory = $true)]
        [string]$String1,
        
        [Parameter(Mandatory = $true)]
        [string]$String2
    )

    $cacheKey = "$String1|$String2"
    if ($script:levenshteinCache.ContainsKey($cacheKey)) {
        return $script:levenshteinCache[$cacheKey]
    }

    $n = $String1.Length
    $m = $String2.Length
    $d = New-Object 'int[,]' ($n + 1), ($m + 1)

    for ($i = 0; $i -le $n; $i++) {
        $d[$i, 0] = $i
    }
    for ($j = 0; $j -le $m; $j++) {
        $d[0, $j] = $j
    }

    for ($i = 1; $i -le $n; $i++) {
        for ($j = 1; $j -le $m; $j++) {
            if ($String1[$i - 1] -eq $String2[$j - 1]) {
                $d[$i, $j] = $d[($i - 1), ($j - 1)]
            }
            else {
                $d[$i, $j] = [Math]::Min(
                    [Math]::Min(
                        $d[($i - 1), $j] + 1,
                        $d[$i, ($j - 1)] + 1
                    ),
                    $d[($i - 1), ($j - 1)] + 1
                )
            }
        }
    }

    $result = $d[$n, $m]
    $script:levenshteinCache[$cacheKey] = $result
    return $result
}

function Search-CommandHistory {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Pattern,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 10
    )
    
    $history = Get-Content (Get-PSReadLineOption).HistorySavePath -ErrorAction SilentlyContinue
    if ($Pattern) {
        $history = $history | Where-Object { $_ -like "*$Pattern*" }
    }
    $history | Select-Object -Last $Count | ForEach-Object {
        Write-Host $_ -ForegroundColor Cyan
    }
}

$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param($CommandName, $CommandLookupEventArgs)
    $job = Start-Job -ScriptBlock {
        param($cmdName)
        Get-CommandSuggestion -ErrorMessage "The term '$cmdName' is not recognized" -ShowHelp
    } -ArgumentList $CommandName
    
    $job | Wait-Job -Timeout $Config.ErrorHandling.CommandSuggestionTimeout | Out-Null
    if ($job.State -eq 'Running') {
        Stop-Job $job
        Write-Host "`nCommand suggestion timed out. Try using 'h' to search command history." -ForegroundColor Yellow
    }
    Remove-Job $job -Force
}

Set-Alias -Name h -Value Search-CommandHistory -Scope Global
#endregion Error Handling and Logging

function New-QRCode {
    param([Parameter(Mandatory = $true)][string]$Url)
    
    try {
        if ($Url -notmatch '^https?://') {
            Write-Host "Error: Please provide a valid URL starting with http:// or https://" -ForegroundColor Red
            return
        }
        
        $qrCodeUrl = "https://qrenco.de/$Url"
        
        Write-Host "Generating QR code for: $Url" -ForegroundColor Cyan
        Write-Host "QR Code URL: $qrCodeUrl" -ForegroundColor Green
        
        Start-Process $qrCodeUrl
        
        Write-Host "QR code opened in browser successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error generating QR code: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-Example {
    <#
    .SYNOPSIS
        Example function template.
    .DESCRIPTION
        This function demonstrates best practices for PowerShell functions.
    .PARAMETER Name
        The name to display.
    .EXAMPLE
        Get-Example -Name "World"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    try {
        Write-Host "Hello, $Name!" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed: $($_.Exception.Message)"
    }
}

Write-Host "Utility functions loaded successfully" -ForegroundColor Green


function Get-AlphabeticalFileList {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )

    if (-Not (Test-Path -Path $FolderPath -PathType Container)) {
        Write-Error "The path '$FolderPath' does not exist or is not a folder."
        return
    }

    try {
        Get-ChildItem -Path $FolderPath -File |
        Sort-Object -Property Name |
        Select-Object -ExpandProperty Name
    }
    catch {
        Write-Error "Failed to list files: $_"
    }
}
