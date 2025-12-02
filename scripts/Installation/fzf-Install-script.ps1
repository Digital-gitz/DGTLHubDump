# Install-FzfWithModule.ps1

function Install-FzfWithModule {
    # Check if winget is available
    $useWinget = Get-Command winget -ErrorAction SilentlyContinue

    # Install fzf binary
    if ($useWinget) {
        Write-Host "Installing fzf using winget..." -ForegroundColor Yellow
        winget install junegunn.fzf
    }
    else {
        Write-Host "Installing fzf using scoop..." -ForegroundColor Yellow
        # Check if scoop is installed
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Write-Host "Installing scoop package manager..." -ForegroundColor Yellow
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
            Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        }
        scoop install fzf
    }

    # Install PSFzf module
    if (-not (Get-Module -ListAvailable -Name PSFzf)) {
        Write-Host "Installing PSFzf module..." -ForegroundColor Yellow
        Install-Module -Name PSFzf -Scope CurrentUser -Force
    }

    # Verify installation
    $fzfPath = Get-Command fzf -ErrorAction SilentlyContinue
    if ($fzfPath) {
        Write-Host "fzf binary installed successfully at: $($fzfPath.Source)" -ForegroundColor Green
        Write-Host "PSFzf module installation completed" -ForegroundColor Green
        Write-Host "`nPlease restart your PowerShell session to complete the setup" -ForegroundColor Yellow
    }
    else {
        Write-Host "Failed to verify fzf installation. Please ensure it's in your PATH" -ForegroundColor Red
    }
}

# Run the installation
Install-FzfWithModule