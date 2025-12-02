``` powershell 
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# I like this function I want to incorperate it some how
function global:Open-URls {
    [CmdletBinding()]
    param(
        [switch]$ShowProgress
    )
    
    Write-Host "`n🌐 Opening URLs..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray

    $total = $script:OpenUrls.Count
    $current = 0
    $failedUrls = @()

    foreach ($url in $script:OpenUrls) {
        $current++
        $cleanUrl = $url -replace '^https?://(www\.)?', '' -replace '\.(com|org|net|io|ai|dev|cloud|app|co|me|us|uk|ru|de|fr|jp|cn|in|br|au|ca|nz|za|kr|nl|pl|it|es|se|dk|no|fi|ie|at|ch|be|pt|gr|cz|hu|ro|sk|ua|il|tr|ae|sa|sg|my|th|vn|id|ph|mx|ar|cl|pe|co|za|eg|ma|ng|ke|za).*$', ''
        
        if ($ShowProgress) {
            $percentComplete = ($current / $total) * 100
            Write-Progress -Activity "Opening " -Status "$cleanUrl" -PercentComplete $percentComplete
        }

        try {
            Start-Process $url
            Write-Host "✓ $cleanUrl" -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        }
        catch {
            Write-Host "✗ Failed to open $cleanUrl" -ForegroundColor Red
            $failedUrls += $url
        }
    }

    if ($ShowProgress) {
        Write-Progress -Activity "Opening URls" -Completed
    }

    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    if ($failedUrls.Count -eq 0) {
        Write-Host "✨ All URls opened successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ Some URLs failed to open:" -ForegroundColor Yellow
        $failedUrls | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Red
        }
    }
    Write-Host
}

```