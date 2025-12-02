
# Function to check if winget is available
function Test-WingetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        Write-Host "Winget is not installed. Please install it from the Microsoft Store." -ForegroundColor Red
        return $false
    }
}

# Function to check if a package is installed
function Test-PackageInstalled {
    param (
        [string]$PackageId
    )
    
    try {
        $result = winget list --id $PackageId --exact
        return $LASTEXITCODE -eq 0
    }
    catch {
        Write-Host "Error checking package $PackageId : $_" -ForegroundColor Red
        return $false
    }
}

# Function to install a package using winget
function Install-WingetPackage {
    param (
        [string]$PackageId,
        [string]$Scope = "user", # Default scope is user
        [switch]$Silent,
        [switch]$AcceptAgreements,
        [int]$MaxRetries = 3
    )

    $arguments = @(
        "install",
        "--id", $PackageId,
        "--scope", $Scope
    )

    if ($Silent) {
        $arguments += "--silent"
    }

    if ($AcceptAgreements) {
        $arguments += "--accept-package-agreements", "--accept-source-agreements"
    }

    # Execute the winget command with retries
    $attempt = 0
    $success = $false
    
    while (-not $success -and $attempt -lt $MaxRetries) {
        $attempt++
        Write-Host "Installing $PackageId... (Attempt $attempt of $MaxRetries)" -ForegroundColor Cyan
        
        try {
            $result = winget @arguments
            if ($LASTEXITCODE -eq 0) {
                $success = $true
                Write-Host "Successfully installed $PackageId" -ForegroundColor Green
            }
            else {
                Write-Host "Failed to install $PackageId. Exit code: $LASTEXITCODE" -ForegroundColor Yellow
                if ($attempt -lt $MaxRetries) {
                    Start-Sleep -Seconds 5
                }
            }
        }
        catch {
            Write-Host "Error installing $PackageId : $_" -ForegroundColor Red
            if ($attempt -lt $MaxRetries) {
                Start-Sleep -Seconds 5
            }
        }
    }
    
    return $success
}

# Function to update a package using winget
function Update-WingetPackage {
    param (
        [string]$PackageId,
        [switch]$Silent,
        [switch]$AcceptAgreements,
        [int]$MaxRetries = 3
    )

    $arguments = @(
        "upgrade",
        "--id", $PackageId
    )

    if ($Silent) {
        $arguments += "--silent"
    }

    if ($AcceptAgreements) {
        $arguments += "--accept-package-agreements", "--accept-source-agreements"
    }

    # Execute the winget command with retries
    $attempt = 0
    $success = $false
    
    while (-not $success -and $attempt -lt $MaxRetries) {
        $attempt++
        Write-Host "Updating $PackageId... (Attempt $attempt of $MaxRetries)" -ForegroundColor Yellow
        
        try {
            $result = winget @arguments
            if ($LASTEXITCODE -eq 0) {
                $success = $true
                Write-Host "Successfully updated $PackageId" -ForegroundColor Green
            }
            else {
                Write-Host "Failed to update $PackageId. Exit code: $LASTEXITCODE" -ForegroundColor Yellow
                if ($attempt -lt $MaxRetries) {
                    Start-Sleep -Seconds 5
                }
            }
        }
        catch {
            Write-Host "Error updating $PackageId : $_" -ForegroundColor Red
            if ($attempt -lt $MaxRetries) {
                Start-Sleep -Seconds 5
            }
        }
    }
    
    return $success
}

# Function to install or update a package
function Install-OrUpdatePackage {
    param (
        [string]$PackageId,
        [string]$Scope = "user"
    )
    
    if (Test-PackageInstalled -PackageId $PackageId) {
        return Update-WingetPackage -PackageId $PackageId
    }
    else {
        return Install-WingetPackage -PackageId $PackageId -Scope $Scope
    }
}

# Main script execution
$ErrorActionPreference = "Stop"
$startTime = Get-Date
$successCount = 0
$failureCount = 0

# Check if winget is available
if (-not (Test-WingetAvailable)) {
    Write-Host "Script cannot continue without winget installed." -ForegroundColor Red
    exit 1
}

function Open-WingetReferences {
    Start-Process "https://winget.run/"
    Start-Process "https://github.com/microsoft/winget-pkgs/tree/master"
}

# List of packages to install or update (removing duplicates)
$packages = @(
    @{ Id = "IronmanSoftware.PowerShellUniversal" },
    @{ Id = "JanDeDobbeleer.OhMyPosh" },
    @{ Id = "9PCKT2B7DZMW" }, # TranslucentTB (using Microsoft Store ID)
    @{ Id = "Microsoft.PowerShell" },
    @{ Id = "Microsoft.WindowsTerminal" },
    @{ Id = "Microsoft.DirectX" },
    @{ Id = "Python.Python.3.12"; Scope = "machine" },
    @{ Id = "Rufus.Rufus" },
    @{ Id = "RevoUninstaller.RevoUninstaller" },
    @{ Id = "Anysphere.Cursor" },
    @{ Id = "voidtools.Everything" },
    @{ Id = "KeePassXCTeam.KeePassXC" },
    @{ Id = "Apple.iCloud" },
    @{ Id = "Inkscape.Inkscape" },
    @{ Id = "Microsoft.PowerToys" },
    @{ Id = "mpvnet.mpvnet" },
    @{ Id = "Elgato.StreamDeck" },
    @{ Id = "Reddit.Reddit" },
    @{ Id = "BlenderFoundation.Blender" },
    @{ Id = "Valve.Steam" },
    @{ Id = "Valve.SteamCMD" },
    @{ Id = "Zeit.Hyper" },
    @{ Id = "GoLang.Go" },
    @{ Id = "OpenJS.NodeJS.LTS"; Scope = "machine" },
    @{ Id = "Rustlang.Rustup" },
    @{ Id = "Odamex.Odamex" },
    @{ Id = "GodotEngine.GodotEngine" },
    @{ Id = "GNU.Wget2" },
    @{ Id = "Neovim.Neovim" },
    @{ Id = "SumatraPDF.SumatraPDF" },
    @{ Id = "SteelSeries.GG" },
    @{ Id = "Anaconda.Miniconda3" },
    @{ Id = "Nushell.Nushell" },
    @{ Id = "GitHub.cli" },
    @{ Id = "Microsoft.Git" },
    @{ Id = "vim.vim" },
    @{ Id = "hpjansson.Chafa" },
    @{ Id = "achannarasappa.ticker" },
    @{ Id = "Figma.Figma" },
    @{ Id = "Figma.FigmaAgent" },
    @{ Id = "Insomnia.Insomnia" },
    @{ Id = "NirSoft.NirCmd" }
)

Write-Host "Starting package installation/update process..." -ForegroundColor Cyan
Write-Host "Total packages to process: $($packages.Count)" -ForegroundColor Cyan
# Function to install NirCmd utility
function Install-NirCmd {
    try {
        Write-Host "Installing NirCmd utility..." -ForegroundColor Cyan
        winget install -e --id NirSoft.NirCmd --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ NirCmd installed successfully" -ForegroundColor Green 
            return $true
        }
        else {
            Write-Host "× Failed to install NirCmd" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error installing NirCmd: $_" -ForegroundColor Red
        return $false
    }
}

# Install or update all packages
foreach ($package in $packages) {
    $id = $package.Id
    $scope = if ($package.ContainsKey('Scope')) { $package.Scope } else { "user" }
    
    try {
        if (Install-OrUpdatePackage -PackageId $id -Scope $scope) {
            $successCount++
        }
        else {
            $failureCount++
        }
    }
    catch {
        Write-Host "Failed to process $id. Error: $_" -ForegroundColor Red
        $failureCount++
    }
}

# Calculate duration
$duration = (Get-Date) - $startTime

# Print summary
Write-Host "`nInstallation/Update Summary:" -ForegroundColor Cyan
Write-Host "Total packages processed: $($packages.Count)" -ForegroundColor White
Write-Host "Successful operations: $successCount" -ForegroundColor Green
Write-Host "Failed operations: $failureCount" -ForegroundColor Red
Write-Host "Total time taken: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor White

if ($failureCount -gt 0) {
    Write-Host "`nSome operations failed. Please check the logs above for details." -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "`nAll packages processed successfully!" -ForegroundColor Green
    exit 0
}

Import-Script -ScriptPath "Scripts/Installation/fzf-Install-script.ps1"

# Close any PS sessions using Terminal-Icons first
Remove-Module Terminal-Icons -ErrorAction SilentlyContinue

# Uninstall all versions
Get-InstalledModule Terminal-Icons -AllVersions -ErrorAction SilentlyContinue |
Uninstall-Module -Force -AllVersions -ErrorAction SilentlyContinue

# Delete any leftover folders
Remove-Item -Recurse -Force "$HOME\Documents\PowerShell\Modules\Terminal-Icons" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "C:\Program Files\PowerShell\Modules\Terminal-Icons" -ErrorAction SilentlyContinue

# Reinstall a known-good version (or latest)
Install-Module Terminal-Icons -Scope CurrentUser -Force -AllowClobber
# or pin a version:
# Install-Module Terminal-Icons -RequiredVersion 0.9.0 -Scope CurrentUser -Force

# Reload
Import-Module Terminal-Icons -Force