function Test-WebsiteConnection {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    $web = New-Object System.Net.WebClient
    $flag = $false

    while ($flag -eq $false) {
        try {
            $web.DownloadString($Url)
            $flag = $true
            Write-Host -ForegroundColor Green "Access successful!"
        }
        catch {
            Write-Host -ForegroundColor Red "Access failed. Retrying in 5 seconds..."
            Start-Sleep -Seconds 5
        }
    }
}

function Get-WebsiteInfo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    try {
        $web = New-Object System.Net.WebClient
        $content = $web.DownloadString($Url)
        $size = $content.Length
        
        Write-Host "`nWebsite Information:"
        Write-Host "-------------------"
        Write-Host "URL: $Url"
        Write-Host "Size: {0} bytes" -f $size.ToString("###,###,##0")
        
        return $content
    }
    catch {
        Write-Host -ForegroundColor Red "Error accessing website: $_"
        return $null
    }
}

function Invoke-WebsiteQuery {
    Write-Host "Website Query Tool"
    Write-Host "================="

    $url = Read-Host "Enter the URL to query (e.g., https://example.com)"

    # Get website information
    $content = Get-WebsiteInfo -Url $url

    if ($content) {
        $monitor = Read-Host "Would you like to monitor this website for availability? (Y/N)"
        if ($monitor -eq 'Y') {
            Test-WebsiteConnection -Url $url
        }
    }

    Write-Host "`nScript completed."
}

function Test-WebsiteAvailability {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    $web = New-Object System.Net.WebClient
    $isAvailable = $false

    Write-Host "Monitoring website availability..."
    
    while (-not $isAvailable) {
        try {
            $web.DownloadString($Url)
            $isAvailable = $true
            Write-Host -ForegroundColor Green "Website is now accessible!"
        }
        catch {
            Write-Host -ForegroundColor Red -NoNewline "Website is down... "
            Start-Sleep -Seconds 5
        }
    }
}

# Example usage:
# Test-WebsiteAvailability -Url "https://example.com"
# Invoke-WebsiteQuery