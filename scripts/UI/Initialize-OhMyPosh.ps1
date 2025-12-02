function Initialize-OhMyPosh {
    [CmdletBinding()]
    param(
        [string]$ThemeName = "clean-detailed",
        [switch]$AutoInstall
    )
    try {
        # Check if Oh My Posh is installed
        if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
            Write-Warning "Oh My Posh is not installed"
            
            if ($AutoInstall) {
                Write-Host "Attempting to install Oh My Posh..." -ForegroundColor Cyan
                try {
                    # Check if winget is available
                    if (Get-Command winget -ErrorAction SilentlyContinue) {
                        winget install JanDeDobbeleer.OhMyPosh --accept-source-agreements --accept-package-agreements
                        
                        # Refresh environment path
                        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                        
                        Write-Host "Oh My Posh installed successfully!" -ForegroundColor Green
                    } else {
                        Write-Warning "Winget is not available. Please install Oh My Posh manually:"
                        Write-Host "Visit: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor Yellow
                        return
                    }
                } catch {
                    Write-Error "Failed to install Oh My Posh: $_"
                    return
                }
            } else {
                Write-Host "To install Oh My Posh, you can:" -ForegroundColor Yellow
                Write-Host "1. Run: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Cyan
                Write-Host "2. Visit: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor Cyan
                Write-Host "3. Rerun this profile with -AutoInstall to install automatically" -ForegroundColor Cyan
                return
            }
        }

        # Check if theme exists
        $themePath = Join-Path $env:POSH_THEMES_PATH "$ThemeName.omp.json"
        if (-not (Test-Path $themePath)) {
            Write-Warning "Theme '$ThemeName' not found at: $themePath"
            Write-Host "Available themes:" -ForegroundColor Yellow
            Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json | 
                Select-Object -ExpandProperty BaseName |
                ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
            return
        }

        # Initialize Oh My Posh with the theme
        oh-my-posh init pwsh --config $themePath | Invoke-Expression

        Write-Host "Oh My Posh initialized with theme: $ThemeName" -ForegroundColor Green

    } catch {
        Write-Error "Error initializing Oh My Posh: $_"
        Write-Host "For troubleshooting, visit: https://ohmyposh.dev/docs/installation/troubleshooting" -ForegroundColor Yellow
    }
}

# Call the function with auto-install option
# Initialize-OhMyPosh -AutoInstall