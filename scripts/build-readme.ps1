# PowerShell Build Script for README.md
# Concatenates Available Commands.txt to README.md

param(
    [switch]$Backup,
    [switch]$Force,
    [string]$OutputPath = "README.md"
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Define file paths
$AvailableCommandsPath = "Available Commands.txt"
$ReadmePath = "README.md"
$BackupPath = "README_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if file exists
function Test-FileExists {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-ColorOutput "Error: File '$Path' not found!" "Red"
        return $false
    }
    return $true
}

# Function to create backup
function New-Backup {
    param([string]$SourcePath, [string]$BackupPath)
    try {
        Copy-Item $SourcePath $BackupPath -Force
        Write-ColorOutput "✓ Backup created: $BackupPath" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Error creating backup: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Function to concatenate files
function Merge-Files {
    param(
        [string]$ReadmePath,
        [string]$CommandsPath,
        [string]$OutputPath
    )
    
    try {
        Write-ColorOutput "📖 Reading README.md..." "Cyan"
        $readmeContent = Get-Content $ReadmePath -Raw
        
        Write-ColorOutput "📋 Reading Available Commands.txt..." "Cyan"
        $commandsContent = Get-Content $CommandsPath -Raw
        
        # Create the merged content
        $mergedContent = @"
$readmeContent

---

## Complete Command Reference

``````text
$commandsContent
``````
"@
        
        Write-ColorOutput "💾 Writing merged content to $OutputPath..." "Cyan"
        $mergedContent | Out-File -FilePath $OutputPath -Encoding UTF8 -NoNewline
        
        Write-ColorOutput "✅ Successfully merged files!" "Green"
        Write-ColorOutput "📄 Output file: $OutputPath" "Yellow"
        
        return $true
    }
    catch {
        Write-ColorOutput "Error merging files: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "🚀 PowerShell README Builder" "Magenta"
Write-ColorOutput "=============================" "Magenta"

# Check if required files exist
if (-not (Test-FileExists $AvailableCommandsPath)) {
    exit 1
}

if (-not (Test-FileExists $ReadmePath)) {
    Write-ColorOutput "Warning: README.md not found. Will create a new one." "Yellow"
}

# Create backup if requested or if README exists
if ($Backup -or (Test-Path $ReadmePath)) {
    if (Test-Path $ReadmePath) {
        Write-ColorOutput "📦 Creating backup..." "Yellow"
        if (-not (New-Backup $ReadmePath $BackupPath)) {
            exit 1
        }
    }
}

# Check if output file exists and handle accordingly
if ((Test-Path $OutputPath) -and -not $Force) {
    $response = Read-Host "Output file '$OutputPath' already exists. Overwrite? (y/N)"
    if ($response -notmatch '^[Yy]$') {
        Write-ColorOutput "Operation cancelled." "Yellow"
        exit 0
    }
}

# Perform the merge
Write-ColorOutput "🔄 Merging files..." "Yellow"
if (Merge-Files $ReadmePath $AvailableCommandsPath $OutputPath) {
    Write-ColorOutput "🎉 Build completed successfully!" "Green"
    
    # Show file sizes
    if (Test-Path $OutputPath) {
        $fileSize = (Get-Item $OutputPath).Length
        Write-ColorOutput "📊 Final file size: $([math]::Round($fileSize/1KB, 2)) KB" "Cyan"
    }
}
else {
    Write-ColorOutput "❌ Build failed!" "Red"
    exit 1
}

Write-ColorOutput "`n💡 Usage examples:" "Magenta"
Write-ColorOutput "  .\Scripts\build-readme.ps1                    # Basic build" "White"
Write-ColorOutput "  .\Scripts\build-readme.ps1 -Backup             # Create backup" "White"
Write-ColorOutput "  .\Scripts\build-readme.ps1 -Force              # Force overwrite" "White"
Write-ColorOutput "  .\Scripts\build-readme.ps1 -OutputPath README_NEW.md" "White"

