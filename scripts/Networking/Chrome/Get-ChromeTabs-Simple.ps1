# Chrome Tabs Extractor - Simple Version
# This script extracts all open Chrome tabs

Write-Host "Chrome Tabs Extractor v2.0" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor DarkGray

# Get Chrome session files location
$chromeSessionPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
$currentTabsFile = Join-Path $chromeSessionPath "Current Tabs"
$currentSessionFile = Join-Path $chromeSessionPath "Current Session"

# Array to store URLs
$urls = @()

Write-Host "Searching for open Chrome tabs..." -ForegroundColor Cyan
Write-Host ""

# Function to extract URLs from session files
function Get-ChromeTabsFromSessionFile {
    param($filePath)
    
    if (Test-Path $filePath) {
        try {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $text = [System.Text.Encoding]::ASCII.GetString($content)
            
            # Regex pattern to find URLs
            $pattern = 'https?://[^\s\x00-\x1f\x7f"<>]+[^\s\x00-\x1f\x7f"<>.,;:!?)]'
            $matches = [regex]::Matches($text, $pattern)
            
            $foundUrls = @()
            foreach ($match in $matches) {
                $url = $match.Value
                # Clean up the URL
                $url = $url -replace '[\x00-\x1f\x7f]', ''
                if ($url -match '^https?://' -and $url.Length -lt 2000) {
                    $foundUrls += $url
                }
            }
            return $foundUrls | Select-Object -Unique
        }
        catch {
            Write-Host "Error reading file: $_" -ForegroundColor Red
            return @()
        }
    }
    return @()
}

# Try DevTools Protocol first
try {
    Write-Host "Trying DevTools Protocol..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "http://localhost:9222/json" -Method Get -TimeoutSec 3
    $tabs = @()
    
    foreach ($tab in $response) {
        if ($tab.type -eq "page" -and $tab.url -and $tab.url -notlike "chrome://*" -and $tab.url -notlike "chrome-extension://*") {
            $tabs += $tab.url
        }
    }
    
    if ($tabs.Count -gt 0) {
        Write-Host "Found $($tabs.Count) tabs via DevTools Protocol" -ForegroundColor Green
        $urls += $tabs
    }
}
catch {
    Write-Host "DevTools Protocol not available" -ForegroundColor Yellow
}

# Extract URLs from Current Tabs
$urls += Get-ChromeTabsFromSessionFile $currentTabsFile

# Extract URLs from Current Session
$urls += Get-ChromeTabsFromSessionFile $currentSessionFile

# Remove duplicates and sort
$urls = $urls | Select-Object -Unique | Sort-Object

# Display results
if ($urls.Count -eq 0) {
    Write-Host "No Chrome tabs found. Make sure Chrome is running with open tabs." -ForegroundColor Yellow
    Write-Host "Note: Chrome must be running for this script to work properly." -ForegroundColor Yellow
    Write-Host "Try running Chrome with: chrome.exe --remote-debugging-port=9222" -ForegroundColor Cyan
}
else {
    Write-Host "Found $($urls.Count) unique URLs:" -ForegroundColor Green
    Write-Host ""
    
    $counter = 1
    foreach ($url in $urls) {
        Write-Host "[$counter] $url"
        $counter++
    }
    
    # Save to file
    $outputFile = "chrome_tabs_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $outputPath = Join-Path (Get-Location) $outputFile
    
    # Create file content
    $fileContent = @"
Chrome Tabs Export
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Total URLs: $($urls.Count)

$("-" * 80)

"@
    
    $fileContent += ($urls | ForEach-Object { $_ }) -join "`r`n"
    
    # Save to file
    $fileContent | Out-File -FilePath $outputPath -Encoding UTF8
    
    Write-Host ""
    Write-Host "URLs saved to: $outputPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "Script completed." -ForegroundColor Cyan

