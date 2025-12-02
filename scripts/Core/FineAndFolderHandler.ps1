function Remove-ItemWithElevation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [switch]$Force,
        
        [switch]$Recurse
    )
    
    # Check if the path exists
    if (-not (Test-Path $Path)) {
        Write-Host "Path does not exist: $Path" -ForegroundColor Red
        return
    }
    
    # Get item info
    $item = Get-Item $Path
    $itemType = if ($item.PSIsContainer) { "folder" } else { "file" }
    
    Write-Host "Attempting to remove $($itemType): $Path" -ForegroundColor Yellow
    Write-Host "This operation requires elevated permissions." -ForegroundColor Cyan
    
    # Build the remove command
    $removeCmd = "Remove-Item -Path '$Path'"
    if ($Force) { $removeCmd += " -Force" }
    if ($Recurse) { $removeCmd += " -Recurse" }
    
    # Execute with elevation
    try {
        Start-Process powershell.exe -ArgumentList "-Command", $removeCmd -Verb RunAs -Wait
        Write-Host "✓ Successfully removed $($itemType): $Path" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to remove $($itemType): $Path" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Remove-FileWithElevation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [switch]$Force
    )
    
    Remove-ItemWithElevation -Path $Path -Force:$Force
}

function Remove-FolderWithElevation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [switch]$Force,
        
        [switch]$Recurse
    )
    
    Remove-ItemWithElevation -Path $Path -Force:$Force -Recurse:$Recurse
}

function Show-RemoveCommands {
    Write-Host "`n🗑️  Remove Commands (Elevated):" -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    $commands = @(
        @{ Name = "Remove-ItemWithElevation"; Desc = "Remove file or folder with elevated permissions" }
        @{ Name = "Remove-FileWithElevation"; Desc = "Remove file with elevated permissions" }
        @{ Name = "Remove-FolderWithElevation"; Desc = "Remove folder with elevated permissions" }
    )
    $maxCmdLen = ($commands | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
    foreach ($cmd in $commands) {
        $pad = " " * ($maxCmdLen - $cmd.Name.Length + 2)
        Write-Host ("  " + $cmd.Name) -ForegroundColor Green -NoNewline
        Write-Host ($pad + $cmd.Desc) -ForegroundColor Gray
    }
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    Write-Host "Usage Examples:" -ForegroundColor Yellow
    Write-Host "  Remove-ItemWithElevation -Path 'C:\Protected\file.txt' -Force" -ForegroundColor Gray
    Write-Host "  Remove-FolderWithElevation -Path 'C:\Protected\folder' -Recurse -Force" -ForegroundColor Gray
}
