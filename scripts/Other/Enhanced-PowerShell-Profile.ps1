# Enhanced PowerShell Profile Script

#region Configuration
# Constants
$SCRIPT_VERSION = "1.0.0"
$DEFAULT_EDITOR = "code"
$DEFAULT_THEME = "$env:POSH_THEMES_PATH\paradox.omp.json"

# Environment Setup
$env:COMPUTERNAME = $env:COMPUTERNAME.ToUpper()
$ErrorActionPreference = "Stop"

#region Helper Functions
function Write-HostColored {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$ForegroundColor = "Cyan"
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
#endregion

#region Module Import
function Import-RequiredModules {
    $requiredModules = @(
        'PSReadLine',
        'Terminal-Icons',
        'posh-git',
        'z'
    )

    foreach ($module in $requiredModules) {
        try {
            Import-Module -Name $module -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to import module: $module. Error: $_"
        }
    }
}
#endregion

#region Prompt Configuration
function Set-EnhancedPrompt {
    $adminIndicator = $(if (Test-Administrator) { "[ADMIN] " } else { "" })
    $locationInfo = $(Get-Location)
    $promptChar = $(if ($NestedPromptLevel -ge 1) { ">>" } else { ">" })
    
    return "$adminIndicator$($env:COMPUTERNAME)\$locationInfo$promptChar "
}

function Initialize-PromptConfig {
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    
    try {
        oh-my-posh init pwsh --config $DEFAULT_THEME | Invoke-Expression
    }
    catch {
        Write-Warning "Failed to initialize oh-my-posh theme. Error: $_"
    }
}
#endregion

#region Navigation Functions
function Set-LocationSafely {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (Test-Path $Path) {
        Set-Location $Path
        Get-ChildItem
    } else {
        Write-Warning "Path does not exist: $Path"
    }
}

$locationAliases = @{
    "home" = "C:\Users\$env:USERNAME"
    "documents" = [Environment]::GetFolderPath("MyDocuments")
    "desktop" = [Environment]::GetFolderPath("Desktop")
    "downloads" = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
}

function Set-LocationAlias {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("home", "documents", "desktop", "downloads")]
        [string]$Alias
    )
    
    if ($locationAliases.ContainsKey($Alias)) {
        Set-LocationSafely $locationAliases[$Alias]
    }
}
#endregion

#region GitHub Functions
function New-GitHubRepository {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepoName,
        [switch]$Private
    )
    
    $visibility = if ($Private) { "--private" } else { "--public" }
    
    try {
        $result = gh repo create $RepoName $visibility -y
        Write-HostColored "Repository '$RepoName' created successfully." -ForegroundColor Green
        return $result
    }
    catch {
        Write-Error "Failed to create repository: $_"
    }
}
#endregion

#region Main Initialization
function Initialize-Profile {
    Write-HostColored "Initializing PowerShell Profile v$SCRIPT_VERSION..."
    
    if ($host.Name -eq 'ConsoleHost') {
        Import-RequiredModules
        Initialize-PromptConfig
    }
    
    # Set aliases
    Set-Alias -Name "gh-new" -Value New-GitHubRepository
    Set-Alias -Name "goto" -Value Set-LocationAlias
    
    # Display system info
    Write-HostColored "System Information:"
    Write-Host "  OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
    Write-Host "  PowerShell: $($PSVersionTable.PSVersion)"
    Write-Host "  User: $env:USERNAME"
    Write-Host "  Computer: $env:COMPUTERNAME"
}

# Execute initialization
Initialize-Profile
#endregion

# Export functions if needed
Export-ModuleMember -Function @(
    'Set-LocationAlias',
    'New-GitHubRepository'
) -Alias @(
    'gh-new',
    'goto'
)