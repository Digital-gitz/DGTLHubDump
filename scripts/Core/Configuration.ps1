#region Configuration
<#
.SYNOPSIS
Centralized configuration for PowerShell profile

.DESCRIPTION
This file contains all configuration settings for the PowerShell profile,
including paths, module settings, and script categories.
#>

# Core configuration object
$script:Config = @{
    Version          = "5.0"
    Author           = "Svyatoslav Oleg Russkiy"
    
    # Paths
    Paths            = @{
        Scripts     = Join-Path $PSScriptRoot "Scripts"
        Core        = Join-Path $PSScriptRoot "Scripts\Core"
        Documents   = [Environment]::GetFolderPath('MyDocuments')
        PowerShell  = $PSScriptRoot
        GitHub      = Join-Path $env:USERPROFILE "Documents\GitHub"
        DGTLHubDump = "C:\Users\Digital_Russkiy\Documents\DGTLHubDump"
    }
    
    # Environment paths to add
    EnvironmentPaths = @(
        "C:\Users\Digital_Russkiy\AppData\Local\Microsoft\PowerToys\PowerToys Run",
        "$HOME\.local\bin",
        "$HOME\AppData\Local\Programs\Microsoft VS Code\bin",
        "C:\Users\Digital_Russkiy\AppData\Local\Programs\lua5.1"
    )
    
    # Module configuration
    Modules          = @{
        Essential = @(
            @{Name = 'PSReadLine'; Purpose = 'Enhanced console experience' }
            @{Name = 'posh-git'; Purpose = 'Git integration' }
        )
        Optional  = @(
            'Terminal-Icons'
        )
    }
    
    # PSReadLine configuration
    PSReadLine       = @{
        ShowToolTips        = $true
        PredictionSource    = "History"
        PredictionViewStyle = "ListView"
        EditMode            = "Windows"
        HistorySaveStyle    = "SaveIncrementally"
        HistorySavePath     = Join-Path $env:USERPROFILE "Documents\PowerShell\PSReadLine\ConsoleHost_history.txt"
        Colors              = @{
            Command          = 'Cyan'
            Parameter        = 'DarkCyan'
            InlinePrediction = 'DarkGray'
            Operator         = 'DarkYellow'
            String           = 'Green'
            Number           = 'DarkGreen'
            Member           = 'DarkYellow'
            Type             = 'DarkBlue'
            Variable         = 'DarkMagenta'
            Comment          = 'DarkGray'
        }
    }
    
    # Script categories and loading order
    ScriptCategories = @{
        Core           = @("Aliases.ps1")
        FileManagement = @("bringVsCodeForeground.ps1")
        Development    = @("Notes-Function.ps1")
        UI             = @("winfetch-pro.ps1", "Stock-Market-UI.ps1")
        Networking     = @("NetworkTools.ps1")
        URL            = @("LLM-Funk.ps1", "Shopping-Funk.ps1", "Social-Funk.ps1")
        Applications   = @("App-Functions.ps1")
        Programs       = @("Aseprite.ps1", "edge.ps1", "windows.ps1", "Games/*.ps1")
    }
    
    LoadOrder        = @("Core", "UI", "Networking", "URL", "Development", "FileManagement", "Applications", "Programs")
    
    # Application paths
    Applications     = @{
        Aseprite      = "C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe"
        Edge          = "C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe"
        TwitchOverlay = @{
            Update = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\Update.exe"
            App    = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\TransparentTwitchChatWPF.exe"
        }
    }
    
    # URLs
    URLs             = @{
        GitHub          = "https://github.com"
        PowerShellRepo  = "https://github.com/Digital-gitz/PowerShell"
        DGTLHubDumpRepo = "https://github.com/Digital-gitz/DGTLHubDump"
        IPInfo          = "https://ipinfo.io"
        QRCode          = "https://qrenco.de"
        GoPackages      = "https://pkg.go.dev/search"
    }
    
    # Error handling
    ErrorHandling    = @{
        CommandSuggestionTimeout = 3
        MaxCommandSuggestions    = 5
        LevenshteinThreshold     = 3
        MaxCommandsToSearch      = 100
    }
    
    # Logging
    Logging          = @{
        Enabled          = $true
        Level            = "Info" # Info, Warning, Error, Success
        IncludeTimestamp = $true
        IncludeSource    = $true
    }
}

# Helper functions
function Get-CommonPaths {
    return $Config.Paths
}

function Get-Config {
    return $Config
}

function Set-Config {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $true)]
        $Value
    )
    
    $pathParts = $Path -split '\.'
    $current = $Config
    
    for ($i = 0; $i -lt $pathParts.Count - 1; $i++) {
        $current = $current[$pathParts[$i]]
    }
    
    $current[$pathParts[-1]] = $Value
}

function Get-ConfigValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    $pathParts = $Path -split '\.'
    $current = $Config
    
    foreach ($part in $pathParts) {
        if ($current.ContainsKey($part)) {
            $current = $current[$part]
        }
        else {
            return $null
        }
    }
    
    return $current
}

# Export configuration
$Global:Config = $Config
$Global:CommonPaths = $Config.Paths

Write-Host "Configuration loaded successfully" -ForegroundColor Green
#endregion Configuration 