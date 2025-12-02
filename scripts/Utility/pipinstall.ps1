function Install-PipPackages {
    param(
        [string[]]$DefaultPackages = @('instagrapi', 'tweepy', 'requests', 'pandas', 'numpy', 'matplotlib')
    )

    Write-Host "Available pip packages for installation:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $DefaultPackages.Count; $i++) {
        Write-Host ("[{0}] {1}" -f $i, $DefaultPackages[$i]) -ForegroundColor Green
    }
    Write-Host "`nEnter the numbers of the packages you want to install separated by commas (e.g. 0,2,4):" -ForegroundColor Yellow
    $selection = Read-Host "Selection"
    if (-not $selection) {
        Write-Host "No selection made. Aborting." -ForegroundColor Red
        return
    }
    $indices = $selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
    $chosen = @()
    foreach ($idx in $indices) {
        if ($idx -ge 0 -and $idx -lt $DefaultPackages.Count) {
            $chosen += $DefaultPackages[$idx]
        }
    }
    if ($chosen.Count -eq 0) {
        Write-Host "No valid packages selected to install." -ForegroundColor Red
        return
    }
    $pkgList = $chosen -join ' '
    Write-Host "`nInstalling: $pkgList" -ForegroundColor Cyan
    pip install $pkgList
}