<#
.SYNOPSIS
    Searches ArtStation for artwork based on a subject/keyword.

.DESCRIPTION
    This script searches ArtStation for a given subject and displays the results
    including title, artist, and URL. It can optionally open results in a browser.

.PARAMETER Subject
    The subject or keyword to search for on ArtStation.

.PARAMETER MaxResults
    Maximum number of results to display (default: 20).

.PARAMETER OpenInBrowser
    If specified, opens the search results page in your default browser.
    
.PARAMETER BrowserOnly
    If specified, skips automated scraping and opens the search results directly in the browser.

.EXAMPLE
    .\Search-ArtStation.ps1 -Subject "cyberpunk"
    
.EXAMPLE
    .\Search-ArtStation.ps1 -Subject "fantasy landscape" -MaxResults 10 -OpenInBrowser
    
.EXAMPLE
    .\Search-ArtStation.ps1 -Subject "batman" -BrowserOnly
    Skips automated scraping and opens the search results directly in the browser.
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Subject,
    
    [Parameter(Mandatory = $false)]
    [int]$MaxResults = 20,
    
    [Parameter(Mandatory = $false)]
    [switch]$OpenInBrowser,
    
    [Parameter(Mandatory = $false)]
    [switch]$BrowserOnly
)

# Encode the search term for URL
$encodedSubject = [System.Web.HttpUtility]::UrlEncode($Subject)
$searchUrl = "https://www.artstation.com/search?q=$encodedSubject&sort_by=relevance"

Write-Host "Searching ArtStation for: '$Subject'" -ForegroundColor Cyan
Write-Host "Search URL: $searchUrl" -ForegroundColor Gray
Write-Host ""

# If BrowserOnly is specified, skip automated scraping
if ($BrowserOnly) {
    Write-Host "Opening search results in browser (BrowserOnly mode)..." -ForegroundColor Cyan
    Start-Process $searchUrl
    Write-Host ""
    Write-Host "Search complete!" -ForegroundColor Green
    return
}

try {
    # Set up headers to mimic a modern browser request (prevents 403 Forbidden errors)
    $headers = @{
        'User-Agent'                = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
        'Accept'                    = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
        'Accept-Language'           = 'en-US,en;q=0.9'
        'Accept-Encoding'           = 'gzip, deflate, br, zstd'
        'Referer'                   = 'https://www.artstation.com/'
        'DNT'                       = '1'
        'Connection'                = 'keep-alive'
        'Upgrade-Insecure-Requests' = '1'
        'Sec-Fetch-Dest'            = 'document'
        'Sec-Fetch-Mode'            = 'navigate'
        'Sec-Fetch-Site'            = 'same-origin'
        'Sec-Fetch-User'            = '?1'
        'Cache-Control'             = 'max-age=0'
    }
    
    # Create a session to maintain cookies
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
    # Attempt to fetch search results with browser-like headers and session
    $response = Invoke-WebRequest -Uri $searchUrl -Headers $headers -WebSession $session -UseBasicParsing -ErrorAction Stop
    
    # ArtStation uses dynamic loading, so we'll extract what we can from the initial HTML
    # This will get us some basic information
    $content = $response.Content
    
    # Try to find project links and titles
    $projectPattern = 'href="(/projects/[^"]+)"'
    $projectMatches = [regex]::Matches($content, $projectPattern)
    
    if ($projectMatches.Count -gt 0) {
        Write-Host "Found projects (showing up to $MaxResults results):" -ForegroundColor Green
        Write-Host ("=" * 80) -ForegroundColor Gray
        
        $uniqueProjects = @{}
        $count = 0
        
        foreach ($match in $projectMatches) {
            if ($count -ge $MaxResults) { break }
            
            $projectPath = $match.Groups[1].Value
            $projectUrl = "https://www.artstation.com$projectPath"
            
            # Skip duplicates
            if ($uniqueProjects.ContainsKey($projectUrl)) { continue }
            $uniqueProjects[$projectUrl] = $true
            
            $count++
            Write-Host "$count. $projectUrl" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "Total unique projects found: $count" -ForegroundColor Green
    }
    else {
        Write-Host "No projects found. The page structure may have changed or there are no results." -ForegroundColor Yellow
    }
    
    # Open browser if requested
    if ($OpenInBrowser) {
        Write-Host ""
        Write-Host "Opening search results in browser..." -ForegroundColor Cyan
        Start-Process $searchUrl
    }
    else {
        Write-Host ""
        Write-Host "Tip: Use -OpenInBrowser to open the search results page directly" -ForegroundColor Gray
    }
    
}
catch {
    $statusCode = $null
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
    }
    
    Write-Host "Error accessing ArtStation: $($_.Exception.Message)" -ForegroundColor Red
    if ($statusCode -eq 403) {
        Write-Host ""
        Write-Host "⚠️  ArtStation is blocking automated requests (403 Forbidden)." -ForegroundColor Yellow
        Write-Host "   This site uses bot protection that cannot be bypassed with headers." -ForegroundColor Gray
        Write-Host ""
        Write-Host "   Opening search results in browser instead..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "💡 Tip: Use -BrowserOnly to skip the automated attempt next time:" -ForegroundColor Cyan
        Write-Host "   Search-ArtStation '$Subject' -BrowserOnly" -ForegroundColor White
    }
    elseif ($statusCode) {
        Write-Host "Received HTTP $statusCode error. Opening search URL in browser instead..." -ForegroundColor Yellow
    } else {
        Write-Host "Network error occurred. Opening search URL in browser instead..." -ForegroundColor Yellow
    }
    Write-Host ""
    Start-Process $searchUrl
}

Write-Host ""
Write-Host "Search complete!" -ForegroundColor Green