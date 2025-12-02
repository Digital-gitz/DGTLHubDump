function Update-PowerShell {
    [CmdletBinding()]
    param (
        [switch]$Preview
    )

    # Determine the OS platform
    if ($IsWindows) {
        Write-Host "Updating PowerShell on Windows..."
        if ($Preview) {
            iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Preview"
        } else {
            iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
        }
    }
    elseif ($IsLinux) {
        Write-Host "Updating PowerShell on Linux..."
        if ($Preview) {
            sudo apt-get update
            sudo apt-get install -y powershell-preview
        } else {
            sudo apt-get update
            sudo apt-get install -y powershell
        }
    }
    elseif ($IsMacOS) {
        Write-Host "Updating PowerShell on macOS..."
        if ($Preview) {
            brew update
            brew install --cask powershell-preview
        } else {
            brew update
            brew install --cask powershell
        }
    }
    else {
        Write-Error "Unsupported operating system."
    }
}

function Update-PowerShellProfile {
    [CmdletBinding()]
    [Alias('reload')]
    param(
        [switch]$SkipConfirmation
    )
    
    # Save original console color
    $originalColor = $Host.UI.RawUI.ForegroundColor
    
    try {
        if (-not $SkipConfirmation) {
            Write-Host "Reloading PowerShell profile..."
        }
        
        # Temporarily set console color to default to avoid color binding issues
        $Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor
        
        # Reload the profile
        . $PROFILE
        
        if (-not $SkipConfirmation) {
            Write-Host "Profile reloaded successfully."
        }
        return $true
    }
    catch {
        Write-Error "Failed to reload profile: $_"
        return $false
    }
    finally {
        # Restore original console color
        try {
            $Host.UI.RawUI.ForegroundColor = $originalColor
        }
        catch {
            # Ignore any errors when restoring the color
        }
    }
}

# To update to the preview version, call the function with the -Preview switch:
# Update-PowerShell -Preview

# To update to the stable version, call the function without the -Preview switch:
# Update-PowerShell

function Get-SystemInfo {
    [CmdletBinding()]
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )
    # Get computer information
    # $computerInfo = Get-WmiObject -Class Win32_ComputerSystem
    # $osInfo = Get-WmiObject -Class Win32_OperatingSystem
    # $biosInfo = Get-WmiObject -Class Win32_BIOS
    # $processorInfo = Get-WmiObject -Class Win32_Processor
    # $memoryInfo = Get-WmiObject -Class Win32_PhysicalMemory
    # $networkInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
}

# ? Display computer information remember to hash shit out.
#     [PSCustomObject]@{
#         ComputerName = $ComputerName
#         Manufacturer = $Manufacturer
#     }
    
#         function UpDit  {
#             $UpD
#         }

# $UpD = Update-PowerShell



#npm install -g npm@latest
#choco install update   note: this is not the command I need to figure out how to update choco

