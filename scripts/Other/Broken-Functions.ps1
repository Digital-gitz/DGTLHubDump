function Install-ConfiguredPackages {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Category,
        [switch]$Force,
        [switch]$SkipConfirmation
    )
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Winget is not installed or not available in PATH"
    }
    
    $packages = if ($Category) {
        if ($Config.WingetPackages.ContainsKey($Category)) {
            $Config.WingetPackages[$Category] | Where-Object { $_.Id }
        }
        else {
            throw "Category '$Category' not found. Available categories: $($Config.WingetPackages.Keys -join ', ')"
        }
    }
    else {
        $Config.WingetPackages.Values | ForEach-Object { $_ } | Where-Object { $_.Id }
    }
    
    if (-not $packages) {
        Write-Warning "No valid packages found to install"
        return
    }
    
    $packageCount = $packages.Count
    if (-not $SkipConfirmation) {
        $message = if ($Category) {
            "This will install/update $packageCount packages from category '$Category'"
        }
        else {
            "This will install/update $packageCount packages from all categories"
        }
        if ((Read-Host "$message. Continue? (Y/N)") -ne 'Y') {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
            return
        }
    }
    $results = @{
        Successful = 0
        Failed     = 0
    }
    
    foreach ($package in $packages) {
        try {
            Write-Host "Processing package: $($package.Id)" -ForegroundColor Cyan
            Install-Package -PackageId $package.Id -Scope ($package.Scope ?? "user") -Force:$Force
            $results.Successful++
        }
        catch {
            Write-Host "Failed to install/update $($package.Id)`: $_" -ForegroundColor Red
            $results.Failed++
        }
    }
    
    Write-Host "Package installation complete. Successful: $($results.Successful), Failed: $($results.Failed)" -ForegroundColor Green
}
