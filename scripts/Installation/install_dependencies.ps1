# Install Chocolatey if not already installed
function Test-ChocolateyInstallation {
    $chocoPath = "$env:ProgramData\chocolatey\bin\choco.exe"
    if (Test-Path $chocoPath) {
        # Add Chocolatey to PATH if not already there
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$env:ProgramData\chocolatey\bin*") {
            try {
                [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$env:ProgramData\chocolatey\bin", "Machine")
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                Write-Log "Added Chocolatey to PATH" -Level 'Success'
            }
            catch {
                Write-Log "Failed to update PATH: $_" -Level 'Warning'
            }
        }
        return $true
    }
    return $false
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Log "Elevating privileges for Chocolatey installation..." -Level 'Info'
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\install_dependencies.ps1`""
    return $false
}

# Check if Chocolatey is installed
if (Test-ChocolateyInstallation) {
    Write-Log "Chocolatey is already installed. Upgrading to latest version..." -Level 'Info'
    try {
        & "$env:ProgramData\chocolatey\bin\choco.exe" upgrade chocolatey -y
        Write-Log "Chocolatey upgraded successfully" -Level 'Success'
    }
    catch {
        Write-Log "Failed to upgrade Chocolatey: $_" -Level 'Error'
        return $false
    }
}
else {
    Write-Log "Chocolatey not found. Installing..." -Level 'Info'
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $installScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        Invoke-Expression $installScript
        Write-Log "Chocolatey installed successfully" -Level 'Success'

        # Wait a moment for the installation to complete
        Start-Sleep -Seconds 5

        # Verify installation and update PATH
        if (Test-ChocolateyInstallation) {
            Write-Log "Chocolatey installation verified and PATH updated" -Level 'Success'
        }
        else {
            Write-Log "Chocolatey installation completed but PATH update failed" -Level 'Warning'
            Write-Log "Please restart PowerShell to ensure Chocolatey is available" -Level 'Warning'
            return $false
        }
    }
    catch {
        Write-Log "Failed to install Chocolatey: $_" -Level 'Error'
        return $false
    }
}

# Verify Chocolatey installation
if (-not (Test-ChocolateyInstallation)) {
    Write-Log "Chocolatey installation failed or not in PATH" -Level 'Error'
    return $false
}

# List of packages to install
$packages = @(
    "unzip",
    "wget",
    "gzip",
    "rust",
    "composer",
    "php",
    "ruby",
    "jdk8",
    "julia",
    "luarocks",
    "mingw",
    "strawberryperl"
)

# Install each package
foreach ($package in $packages) {
    try {
        Write-Log "Installing package: $package" -Level 'Info'
        & "$env:ProgramData\chocolatey\bin\choco.exe" install $package -y
        Write-Log "Successfully installed $package" -Level 'Success'
    }
    catch {
        Write-Log "Failed to install $package : $_" -Level 'Error'
    }
}

# Ensure Python3 and Neovim module are installed
try {
    python -m pip install neovim
    Write-Log "Successfully installed neovim Python module" -Level 'Success'
}
catch {
    Write-Log "Failed to install neovim Python module: $_" -Level 'Error'
}

return $true
