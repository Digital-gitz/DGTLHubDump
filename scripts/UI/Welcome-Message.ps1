# Initialize the start time before any operations
$startTime = Get-Date
$curUser    = (Get-ChildItem Env:\USERNAME).Value
$curComp    = (Get-ChildItem Env:\COMPUTERNAME).Value
$pvmaj      = $Host.Version.Major
$pvmin      = $Host.Version.Minor
$psversion  = "$pvmaj.$pvmin"
$identity   = "$curUser@$curComp"

# Load Profile Commands script
$profileCommandsPath = Join-Path $PSScriptRoot "Profile-Commands.ps1"
if (Test-Path $profileCommandsPath) {
    . $profileCommandsPath
}
else {
    Write-Warning "Profile Commands script not found at: $profileCommandsPath"
}

# Cache configuration
$script:CachePath = Join-Path $env:TEMP "PowerShellWelcome"
$script:TipsCachePath = Join-Path $script:CachePath "tips.json"
$script:WeatherCachePath = Join-Path $script:CachePath "weather.json"
$script:QuotesCachePath = Join-Path $script:CachePath "quotes.json"
$script:CacheExpiryHours = 4

# Make sure to dot source this script in your profile
# Functions are explicitly marked as global to ensure availability

function global:Initialize-WelcomeCache {
    if (-not (Test-Path $script:CachePath)) {
        try {
            New-Item -ItemType Directory -Path $script:CachePath -Force -ErrorAction Stop | Out-Null
            Write-Verbose "Cache directory created at: $script:CachePath"
        }
        catch {
            Write-Warning "Failed to create cache directory: $_"
        }
    }
}

function Global:Get-CachedData {
    param (
        [string]$Path,
        [scriptblock]$FetchData,
        [int]$LocalExpiryHours = $script:CacheExpiryHours
    )
    
    try {
        if (Test-Path $Path) {
            $cacheData = Get-Content $Path -Raw | ConvertFrom-Json
            $startTime = [DateTime]::ParseExact($cacheData.timestamp, "yyyy-MM-dd HH:mm:ss.fff", [System.Globalization.CultureInfo]::InvariantCulture)
            $cacheAge = (Get-Date) - $startTime
            
            if ($cacheAge.TotalHours -lt $LocalExpiryHours) {
                Write-Verbose "Using cached data from: $Path (Age: $($cacheAge.TotalHours) hours)"
                return $cacheData.data
            }
            Write-Verbose "Cache expired for: $Path (Age: $($cacheAge.TotalHours) hours)"
        }
    }
    catch {
        Write-Warning "Error reading cache from $Path`: $_"
    }
    
    try {
        $data = & $FetchData
        $cacheObject = @{
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
            data      = $data
        }
        $cacheObject | ConvertTo-Json -Depth 10 | Set-Content $Path -Force
        return $data
    }
    catch {
        Write-Warning "Error fetching or caching data: $_"
        return $null
    }
}

function Get-WeatherInfo {
    try {
        $weatherRequest = @{
            Uri        = "https://wttr.in/?format=%l:+%C+%t"
            TimeoutSec = 3  # Reduced timeout for better performance
            UserAgent  = "PowerShell/$($PSVersionTable.PSVersion) WelcomeScript/1.1"
        }
        $result = Invoke-RestMethod @weatherRequest
        return $result.Trim()  # Trim any whitespace
    }
    catch {
        Write-Verbose "Weather fetch failed: $_"
        return $null
    }
}

function Get-RandomPowerShellTip {
    try {
        $tips = Get-CachedData -Path $script:TipsCachePath -FetchData {
            $redditRequest = @{
                Uri        = "https://www.reddit.com/r/PowerShell/search.json?q=flair%3ATip%20OR%20flair%3ATutorial&restrict_sr=1&sort=top&limit=50"
                TimeoutSec = 3  # Reduced timeout
                UserAgent  = "PowerShell/$($PSVersionTable.PSVersion) TipFetcher/1.1"
            }
            
            $response = Invoke-RestMethod @redditRequest
            return $response.data.children.data.title
        }
        
        if ($tips -and $tips.Count -gt 0) {
            return "Reddit Tip: $($tips | Get-Random)"
        }
    }
    catch {
        Write-Verbose "Tip fetch failed: $_"
    }
    
    # Expanded fallback tips
    $localTips = @(
        "Use 'Get-Command -Module ModuleName' to explore module commands",
        "PSReadLine's PredictionSource helps with command completion",
        "Press F7 to see command history in a popup window",
        "Use Tab completion with parameters: -Para<tab>",
        "Pipe any command to Get-Member to explore its properties",
        "Use Select-Object -First to limit output: Get-Process | Select-Object -First 5",
        "Try Out-GridView to view command output in a filterable GUI",
        "Use ConvertTo-Json | Set-Content file.json to save objects as JSON",
        "Quickly check types with 'obj.GetType()' or 'obj | Get-Member'",
        "Use Format-List (*) to see all object properties: Get-Process explorer | Format-List *"
    )
    return "PowerShell Tip: $($localTips | Get-Random)"
}

function Get-RandomQuote {
    try {
        $quotes = Get-CachedData -Path $script:QuotesCachePath -FetchData {
            $quoteRequest = @{
                Uri        = "https://api.quotable.io/quotes/random?limit=5"
                TimeoutSec = 3
                UserAgent  = "PowerShell/$($PSVersionTable.PSVersion) QuoteFetcher/1.0"
            }
            
            $response = Invoke-RestMethod @quoteRequest
            return $response | ForEach-Object { 
                @{
                    content = $_.content
                    author  = $_.author
                }
            }
        }
        
        if ($quotes -and $quotes.Count -gt 0) {
            $quote = $quotes | Get-Random
            return """$($quote.content)"" — $($quote.author)"
        }
    }
    catch {
        Write-Verbose "Quote fetch failed: $_"
    }
    
    # Fallback quotes
    $localQuotes = @(
        @{ content = "The best way to predict the future is to invent it."; author = "Alan Kay" },
        @{ content = "Talk is cheap. Show me the code."; author = "Linus Torvalds" },
        @{ content = "Simplicity is the ultimate sophistication."; author = "Leonardo da Vinci" },
        @{ content = "Any sufficiently advanced technology is indistinguishable from magic."; author = "Arthur C. Clarke" },
        @{ content = "The most powerful tool we have as developers is automation."; author = "Scott Hanselman" }
    )
    $quote = $localQuotes | Get-Random
    return """$($quote.content)"" — $($quote.author)"
}

function Get-SystemMetrics {
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop
        $computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $process = Get-Process -Id $PID -ErrorAction Stop
        $startTime = $process.StartTime
        
        # Try to get more precise CPU load
        try {
            $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples.CookedValue
        }
        catch {
            $cpuLoad = $null
            Write-Verbose "Failed to get CPU counter: $_"
        }
        
        # Current user and domain
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $userInfo = "$($currentUser.Name)"
        
        return @{
            ComputerName    = $computerSystem.Name
            OS              = "$($os.Caption) $($os.Version)"
            CPU             = @{
                Name              = $cpu.Name
                Load              = if ($null -ne $cpuLoad) { [math]::Round($cpuLoad, 1) } else { "N/A" }
                Cores             = $cpu.NumberOfCores
                LogicalProcessors = $cpu.NumberOfLogicalProcessors
            }
            Memory          = @{
                Total = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
                Usage = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 1)
                Free  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
            }
            Disk            = @{
                FreeSpace  = [math]::Round($disk.FreeSpace / 1GB, 2)
                TotalSpace = [math]::Round($disk.Size / 1GB, 2)
                Usage      = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size * 100), 1)
            }
            PowerShell      = $PSVersionTable.PSVersion.ToString()
            User            = $userInfo
            SessionDuration = if ($startTime) { 
                [math]::Round(((Get-Date) - $startTime).TotalMinutes, 1) 
            }
            else { 
                "N/A" 
            }
        }
    }
    catch {
        Write-Warning "Failed to gather system metrics: $_"
        return $null
    }
}

function Show-ProgressBar {
    param (
        [int]$Percent,
        [int]$Length = 20,
        [string]$CompleteChar = "█",
        [string]$IncompleteChar = "░",
        [string]$Label = "Progress"
    )
    
    $completed = [math]::Round($Length * ($Percent / 100))
    $incomplete = $Length - $completed
    
    # Fixed the colon issue by using double quotes around the entire string
    # and using the backtick to escape the colon
    $bar = "$Label`: ["
    $bar += $CompleteChar * $completed
    $bar += $IncompleteChar * $incomplete
    $bar += "] $Percent%"
    
    return $bar
}

function global:Show-Welcome {
    [CmdletBinding()]
    param(
        [switch]$ShowSystemInfo,
        [switch]$ShowCommands
    )

    # Get console dimensions
    $consoleWidth = $Host.UI.RawUI.WindowSize.Width
    $bannerWidth = 68 # Width of the banner including borders
    $padding = [math]::Max(0, [math]::Floor(($consoleWidth - $bannerWidth) / 2))
    $indent = " " * $padding

    # Welcome banner text
    $welcomeText = @"

$indent╔══════════════════════════════════════════════════════════════════╗
$indent║                  Welcome to PowerShell Profile                   ║
$indent║                                                                  ║
$indent║  Type 'Get-ScriptsFunctions' to see available custom functions   ║
$indent║  Type 'Show-FunctionExecutionStats' to see performance metrics   ║
$indent║                       Windows PowerShell                         ║
$indent                        Version $psversion                         
$indent              $identity
$indent║                          Happy coding!                           ║
$indent╚══════════════════════════════════════════════════════════════════╝
"@

    # Display welcome text
    Write-Host $welcomeText -ForegroundColor Cyan

    # Display available functions in columns
    Write-Host "Available Custom Functions:" -ForegroundColor Green
    Write-Host "-------------------------" -ForegroundColor Green

    # $functions = Get-ChildItem function: | Where-Object { $_.Source -eq "" } | Sort-Object Name
    # $columnWidth = 30
    # $columnsPerRow = [math]::Floor($consoleWidth / $columnWidth)

    # for ($i = 0; $i -lt $functions.Count; $i++) {
    #     $functionName = $functions[$i].Name
    #     $functionPadding = " " * ($columnWidth - $functionName.Length)
    #     Write-Host -NoNewline "  $functionName$functionPadding" -ForegroundColor Green
        
    #     if (($i + 1) % $columnsPerRow -eq 0 -or $i -eq $functions.Count - 1) {
    #         Write-Host ""
    #     }
    # }

    # Display system info if requested
    if ($ShowSystemInfo) {
        Write-Host "`nSystem Information:" -ForegroundColor Yellow
        $sysInfo = @{
            "PowerShell Version" = $PSVersionTable.PSVersion
            "OS"                 = [System.Environment]::OSVersion.VersionString
            "User"               = [System.Environment]::UserName
            "Computer"           = [System.Environment]::MachineName
        }
        
        foreach ($item in $sysInfo.GetEnumerator()) {
            Write-Host "  $($item.Key): $($item.Value)"
        }
    }

    # Display quick commands if requested
    if ($ShowCommands) {
        Write-Host "`nQuick Commands:" -ForegroundColor Yellow
        $quickCommands = @{
            "clr"     = "Clear screen"
            "which"   = "Find command location"
            "restart" = "Restart PowerShell session"
        }
        
        foreach ($cmd in $quickCommands.GetEnumerator()) {
            Write-Host "  $($cmd.Key.PadRight(8)) - $($cmd.Value)"
        }
    }

    Write-Host ""
}

# Initialize cache when the script loads
Initialize-WelcomeCache

# Show welcome message when the script loads
# Show-Welcome  -ShowCommands -ShowSystemInfo

Write-Host "Welcome-Message loaded successfully" -ForegroundColor green