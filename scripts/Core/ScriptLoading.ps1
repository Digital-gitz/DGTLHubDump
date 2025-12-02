# Initialize the start time before any operations
$startTime = Get-Date -AsUTC -Format "yyyy-MM-dd HH:mm:ss.ffffff"

#region Script Loading Functions
$loadedScripts = @{}
$scriptsRoot = Split-Path -Parent $PSScriptRoot

function Import-Script {
    param (
        [Parameter(Mandatory)]
        [string]$ScriptPath,
        [string]$Category = "General",
        [switch]$Force
    )

    $scriptKey = $ScriptPath.ToLower()

    # Check if script is already loaded
    if ($loadedScripts.ContainsKey($scriptKey) -and !$Force) {
        return $true
    }

    try {
        if (-not (Test-Path $ScriptPath)) {
            Write-Host "Script not found: $ScriptPath" -ForegroundColor Yellow
            return $false
        }

        # Check if this is a module
        $moduleManifestPath = $ScriptPath -replace '\.ps1$', '.psd1'
        if (Test-Path $moduleManifestPath) {
            try {
                Import-Module $moduleManifestPath -Force -ErrorAction Stop
                $loadedScripts[$scriptKey] = $true
                return $true
            }
            catch {
                Write-Host "Failed to load module $ScriptPath" -ForegroundColor Red
                return $false
            }
        }

        # Load the script
        . ([scriptblock]::Create(". '$ScriptPath'"))
        $loadedScripts[$scriptKey] = $true
        return $true
    }
    catch {
        Write-Host "Error loading script $ScriptPath" -ForegroundColor Red
        return $false
    }
}

function Import-ScriptCategory {
    param (
        [Parameter(Mandatory)]
        [string]$Category,
        [string[]]$Scripts
    )

    foreach ($script in $Scripts) {
        $scriptPath = Join-Path $scriptsRoot $Category $script
        $result = Import-Script -ScriptPath $scriptPath -Category $Category
        if ($result) {
            Write-Host "$script loaded successfully" -ForegroundColor Green
        }
    }
}

# Define script categories and their files
$scriptCategories = @{
    Core           = @("Aliases.ps1")
    FileManagement = @("bringVsCodeForeground.ps1")
    Navigation     = @("cd-downloads.ps1")
    Development    = @("Notes-Function.ps1")
    UI             = @("winfetch-pro.ps1")
    Networking     = @("URL-Funk.ps1")
}

# Load all scripts
foreach ($category in $scriptCategories.Keys) {
    Import-ScriptCategory -Category $category -Scripts $scriptCategories[$category]
}

# Load Welcome-Message script
$welcomeMessagePath = Join-Path $scriptsRoot "UI\Welcome-Message.ps1"
if (Test-Path $welcomeMessagePath) {
    try {
        . $welcomeMessagePath
        Write-Host "Welcome-Message loaded successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to load Welcome-Message script" -ForegroundColor Red
    }
}
else {
    Write-Host "Welcome-Message script not found" -ForegroundColor Yellow
}

#endregion Script Loading Functions 