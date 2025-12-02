# Utility functions
function marketSum {
    Write-Host "`n📈 Getting market summary..." -ForegroundColor Cyan
    try {
        curl terminal-stocks.dev/market-summary
    }
    catch {
        Write-Host "Failed to retrieve market summary: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host
}