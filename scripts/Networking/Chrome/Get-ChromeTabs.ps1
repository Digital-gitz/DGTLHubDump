# Chrome Tabs Extractor - Enhanced Version
# This script extracts all open Chrome tabs using multiple methods
# Author: Digital_Russkiy
# Version: 2.1

[CmdletBinding()]
param(
    [switch]$SaveToFile,
    [string]$OutputPath = "",
    [switch]$ShowProgress,
    [switch]$IncludeTitle,
    [switch]$DebugMode
)

Write-Host "Chrome Tabs Extractor v2.1" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor DarkGray

# Check if Chrome is running
$chromeProcesses = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
if ($chromeProcesses) {
    Write-Host "Chrome is running with $($chromeProcesses.Count) process(es)" -ForegroundColor Green
} else {
    Write-Host "Chrome is not running" -ForegroundColor Yellow
}

# Array to store URLs
$urls = @()

Write-Host "Searching for open Chrome tabs..." -ForegroundColor Cyan
Write-Host ""

# Method 1: Try DevTools Protocol (most reliable)
Write-Host "Method 1: Trying DevTools Protocol..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:9222/json" -Method Get -TimeoutSec 3
    $tabs = @()
    
    foreach ($tab in $response) {
        if ($tab.type -eq "page" -and $tab.url -and $tab.url -notlike "chrome://*" -and $tab.url -notlike "chrome-extension://*") {
            $tabs += $tab.url
        }
    }
    
    if ($tabs.Count -gt 0) {
        Write-Host "SUCCESS: Found $($tabs.Count) tabs via DevTools Protocol" -ForegroundColor Green
        $urls += $tabs
    } else {
        Write-Host "FAILED: No tabs found via DevTools Protocol" -ForegroundColor Red
    }
}
catch {
    Write-Host "FAILED: DevTools Protocol not available" -ForegroundColor Red
    if ($DebugMode) {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

# Method 2: Try reading Chrome's session files
Write-Host "`nMethod 2: Reading Chrome session files..." -ForegroundColor Yellow

# Function to extract URLs from session files
function Get-ChromeTabsFromSessionFile {
    param($filePath)
    
    if (Test-Path $filePath) {
        try {
            # Try to read as text first
            $content = Get-Content -Path $filePath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                # Extract URLs using regex
                $pattern = 'https?://[^\s\x00-\x1f\x7f"<>]+[^\s\x00-\x1f\x7f"<>.,;:!?)]'
                $matches = [regex]::Matches($content, $pattern)
                
                $foundUrls = @()
                foreach ($match in $matches) {
                    $url = $match.Value.Trim()
                    if ($url -match '^https?://' -and $url.Length -lt 2000 -and $url -notlike "chrome://*" -and $url -notlike "chrome-extension://*") {
                        $foundUrls += $url
                    }
                }
                return $foundUrls | Select-Object -Unique
            }
        }
        catch {
            if ($DebugMode) {
                Write-Host "  Error reading $filePath : $($_.Exception.Message)" -ForegroundColor Gray
            }
        }
    }
    return @()
}

# Check multiple Chrome profiles
$chromeProfiles = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Profile 1",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Profile 2"
)

$sessionFiles = @("Current Tabs", "Current Session", "Last Tabs", "Last Session")
$sessionUrls = @()

foreach ($profile in $chromeProfiles) {
    if (Test-Path $profile) {
        if ($DebugMode) {
            Write-Host "  Checking profile: $profile" -ForegroundColor Gray
        }
        
        foreach ($sessionFile in $sessionFiles) {
            $filePath = Join-Path $profile $sessionFile
            $foundUrls = Get-ChromeTabsFromSessionFile $filePath
            if ($foundUrls.Count -gt 0) {
                $sessionUrls += $foundUrls
                if ($DebugMode) {
                    Write-Host "    Found $($foundUrls.Count) URLs in $sessionFile" -ForegroundColor Gray
                }
            }
        }
    }
}

if ($sessionUrls.Count -gt 0) {
    Write-Host "SUCCESS: Found $($sessionUrls.Count) URLs from session files" -ForegroundColor Green
    $urls += $sessionUrls
} else {
    Write-Host "FAILED: No URLs found in session files" -ForegroundColor Red
}

# Method 3: Try Chrome's command line approach
Write-Host "`nMethod 3: Trying Chrome command line approach..." -ForegroundColor Yellow

try {
    # Check if Chrome is running and try to get tabs
    if ($chromeProcesses) {
        Write-Host "SUCCESS: Chrome is running" -ForegroundColor Green
        
        # Try to start Chrome with debugging if not already running with it
        $chromeWithDebugging = $chromeProcesses | Where-Object { $_.CommandLine -like "*--remote-debugging-port*" }
        if (-not $chromeWithDebugging) {
            Write-Host "  Chrome is running but not with debugging enabled" -ForegroundColor Yellow
            Write-Host "  To enable debugging, close Chrome and run:" -ForegroundColor Cyan
            Write-Host "  chrome.exe --remote-debugging-port=9222" -ForegroundColor White
        }
    }
}
catch {
    Write-Host "FAILED: Command line method failed" -ForegroundColor Red
    if ($DebugMode) {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

# Remove duplicates and sort
$urls = $urls | Select-Object -Unique | Sort-Object

# Display results
Write-Host "`n" + "="*50 -ForegroundColor DarkGray
if ($urls.Count -eq 0) {
    Write-Host "NO CHROME TABS FOUND!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "1. Make sure Chrome is running with open tabs" -ForegroundColor White
    Write-Host "2. Close Chrome and restart it with debugging enabled:" -ForegroundColor White
    Write-Host "   chrome.exe --remote-debugging-port=9222" -ForegroundColor Cyan
    Write-Host "3. Try running this script again after enabling debugging" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternative: Use Chrome's bookmark export feature:" -ForegroundColor Yellow
    Write-Host "   Chrome Menu -> Bookmarks -> Bookmark Manager -> ... -> Export bookmarks" -ForegroundColor White
}
else {
    Write-Host "SUCCESS: Found $($urls.Count) unique Chrome tabs:" -ForegroundColor Green
    Write-Host ""
    
    $counter = 1
    foreach ($url in $urls) {
        Write-Host "[$counter] $url" -ForegroundColor White
        $counter++
    }
    
    # Save to file if requested
    if ($SaveToFile -or $OutputPath) {
        if (-not $OutputPath) {
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $OutputPath = "chrome_tabs_$timestamp.txt"
        }
        
        # Create file content
        $fileContent = @"
Chrome Tabs Export
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Total URLs: $($urls.Count)

$("-" * 80)

"@
        
        $fileContent += ($urls | ForEach-Object { $_ }) -join "`r`n"
        
        # Save to file
        $fileContent | Out-File -FilePath $OutputPath -Encoding UTF8
        
        Write-Host ""
        Write-Host "URLs saved to: $OutputPath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Script completed." -ForegroundColor Cyan