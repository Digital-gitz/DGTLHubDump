# Script-Management.ps1

# Initialize configuration path
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath '..\config.psd1'

# Load configuration file
function Import-Configuration {
    if (Test-Path $ConfigPath) {
        try {
            # Import the configuration file directly
            $config = Import-PowerShellDataFile -Path $ConfigPath -ErrorAction Stop
            
            # Verify that $config is a hashtable
            if ($config -isnot [hashtable]) {
                throw "Configuration must be a hashtable"
            }
            
            Write-Host "Configuration loaded successfully" -ForegroundColor Green
            return $config
        }
        catch {
            Write-Warning "Failed to load configuration: $_"
        }
    }
    else {
        Write-Warning "Configuration file not found at: $ConfigPath"
    }

    # Return default configuration if loading fails
    return @{
        CommonPaths     = @{
            PowerShell = $PSScriptRoot
            Scripts    = Join-Path $PSScriptRoot "Scripts"
            Documents  = [Environment]::GetFolderPath('MyDocuments')
        }
        UrlCollections  = @{}
        RequiredModules = @()
        PSReadLine      = @{
            ShowToolTips        = $true
            PredictionSource    = "History"
            PredictionViewStyle = "ListView"
            EditMode            = "Windows"
        }
    }
}

function Update-CustomScripts {
    [CmdletBinding()]
    param (
        [string]$RepoUrl = "https://github.com/Digital-gitz/Powershell/tree/main/Modules",
        [string]$Branch = "main",
        [switch]$Force,
        [switch]$Preview
    )
    
    try {
        # Create temp directory
        $tempDir = Join-Path $env:TEMP "ScriptUpdates_$(Get-Random)"
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        New-Item -Path $tempDir -ItemType Directory | Out-Null
        
        Write-Host "Downloading scripts from $RepoUrl..." -ForegroundColor Cyan
        
        # Download and extract repository
        $zipUrl = "$RepoUrl/archive/$Branch.zip"
        $zipFile = Join-Path $tempDir "scripts.zip"
        
        try {
            Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to download from $zipUrl`: $_"
            return
        }
        
        # Extract the zip file
        Write-Host "Extracting scripts..." -ForegroundColor Cyan
        Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
        
        # Find the extracted directory
        $extractedDir = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
        if (-not $extractedDir) {
            Write-Error "No directories found in the downloaded archive"
            return
        }
        
        # Ensure scripts directory exists
        if (-not (Test-Path $CommonPaths.Scripts)) {
            New-Item -Path $CommonPaths.Scripts -ItemType Directory -Force | Out-Null
            Write-Host "Created scripts directory: $($CommonPaths.Scripts)" -ForegroundColor Yellow
        }
        
        # List files to be copied
        $filesToCopy = Get-ChildItem -Path $extractedDir.FullName -File -Recurse -Include "*.ps1"
        
        if (-not $filesToCopy) {
            Write-Warning "No script files found in the repository"
            return
        }
        
        Write-Host "Found $($filesToCopy.Count) script files to update" -ForegroundColor Cyan
        
        # Preview mode
        if ($Preview) {
            Write-Host "Preview of files to be updated:" -ForegroundColor Cyan
            $filesToCopy | ForEach-Object {
                $relativePath = $_.FullName.Replace($extractedDir.FullName, '').TrimStart('\')
                Write-Host "- $relativePath" -ForegroundColor Yellow
            }
            return
        }
        
        # Confirm the update if not forced
        if (-not $Force) {
            $confirmation = Read-Host "Do you want to update these scripts? (Y/N)"
            if ($confirmation -ne 'Y') {
                Write-Host "Script update cancelled" -ForegroundColor Yellow
                return
            }
        }
        
        # Start tracking changes
        $updatedCount = 0
        $skippedCount = 0
        $errorCount = 0
        
        # Copy files with logging
        foreach ($file in $filesToCopy) {
            try {
                $relativePath = $file.FullName.Replace($extractedDir.FullName, '').TrimStart('\')
                $destinationPath = Join-Path $CommonPaths.Scripts $relativePath
                
                # Create destination directory if it doesn't exist
                $destinationDir = Split-Path $destinationPath -Parent
                if (-not (Test-Path $destinationDir)) {
                    New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
                }
                
                # Compare files to avoid unnecessary overwrites
                $doUpdate = $true
                if (Test-Path $destinationPath) {
                    $existingFile = Get-Item $destinationPath
                    if ((Get-FileHash $file.FullName).Hash -eq (Get-FileHash $existingFile.FullName).Hash) {
                        $doUpdate = $false
                        $skippedCount++
                    }
                }
                
                if ($doUpdate) {
                    Copy-Item -Path $file.FullName -Destination $destinationPath -Force
                    Write-Host "Updated: $relativePath" -ForegroundColor Green
                    $updatedCount++
                }
                else {
                    Write-Host "Skipped (no changes): $relativePath" -ForegroundColor DarkGray
                }
            }
            catch {
                Write-Host "Error updating $relativePath`: $_" -ForegroundColor Red
                $errorCount++
            }
        }
        
        # Summary
        Write-Host "`nScript Update Summary:" -ForegroundColor Cyan
        Write-Host "- Updated:  $updatedCount" -ForegroundColor Green
        Write-Host "- Skipped:  $skippedCount" -ForegroundColor Yellow
        Write-Host "- Errors:   $errorCount" -ForegroundColor Red
        
        # Optional: Create a backup of old scripts
        $backupDir = Join-Path $env:TEMP "PowerShellScripts_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        
        Write-Host "`nBackup created at: $backupDir" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Unexpected error during script update: $_"
    }
    finally {
        # Clean up temporary directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }
}

# Define the function in the global scope
function global:Import-CustomScript {
    param (
        [Parameter(Mandatory)][string]$Name,
        [string]$Purpose
    )
    
    # Ensure Scripts directory exists
    if (-not (Test-Path $CommonPaths.Scripts)) {
        New-Item -Path $CommonPaths.Scripts -ItemType Directory -Force | Out-Null
    }
    
    try {
        $scriptPath = Join-Path $CommonPaths.Scripts $Name
        if (Test-Path $scriptPath) {
            # Avoid re-importing scripts that have already been loaded
            $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($Name)
            if (-not $Global:LoadedScripts.Contains($scriptName)) {
                . $scriptPath
                $Global:LoadedScripts.Add($scriptName) | Out-Null
                Write-Verbose "Imported script: $Name"
            }
        }
        else {
            Write-Warning "Script not found: $scriptPath"
        }
    }
    catch {
        Write-Warning "Failed to load script: $Name - $_"
    }
}

# Initialize the LoadedScripts set if it doesn't exist
if (-not (Test-Path Variable:Global:LoadedScripts)) {
    $Global:LoadedScripts = [System.Collections.Generic.HashSet[string]]::new()
}

# Load configuration
$Global:Config = Import-Configuration

# Initialize paths from config with variable expansion
$Global:CommonPaths = @{}
foreach ($key in $Config.CommonPaths.Keys) {
    $pathValue = $Config.CommonPaths[$key]
    if ($pathValue -is [string]) {
        $pathValue = $ExecutionContext.InvokeCommand.ExpandString($pathValue)
    }
    $Global:CommonPaths[$key] = $pathValue
}

# Ensure essential paths exist
$Global:CommonPaths.PowerShell = $Global:CommonPaths.PowerShell ?? $PSScriptRoot
$Global:CommonPaths.Scripts = $Global:CommonPaths.Scripts ?? (Join-Path $Global:CommonPaths.PowerShell "Scripts")
$Global:CommonPaths.Documents = $Global:CommonPaths.Documents ?? [Environment]::GetFolderPath('MyDocuments')

# Load custom scripts if configured
if ($Config.CustomScripts) {
    foreach ($script in $Config.CustomScripts) {
        Import-CustomScript -Name $script.Name -Purpose $script.Purpose
    }
}

function Get-ScriptsFunctions {
    [CmdletBinding()]
    param()

    Write-Host "`nAvailable Custom Functions:" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan

    $functionExecutionLog.GetEnumerator() | Sort-Object { $_.Value.Category }, { $_.Value.Name } | ForEach-Object {
        $func = $_.Value
        Write-Host "`n[$($func.Category)]" -ForegroundColor Yellow
        Write-Host "  $($func.Name)" -ForegroundColor Green
        Write-Host "  └─ From: $($func.Script)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Remove Export-ModuleMember since this is a script
Write-Host "Script-Management loaded" -ForegroundColor Green
