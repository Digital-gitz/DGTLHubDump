# Backup.ps1
# Created 2025-03-03
# Description: Add your description here

function Get-ScriptInfo {
    [CmdletBinding()]
    param()
    
    Write-Host "Script: Backup.ps1" -ForegroundColor Cyan
    Write-Host "This is a placeholder function. Please add your actual code here."
}

# Add your functions below this line


function Get-CommandSuggestion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage
    )
    
    if ($ErrorMessage -match "The term '(.+)' is not recognized") {
        $command = $matches[1]
        $suggestions = Get-Command -ErrorAction SilentlyContinue | 
        Where-Object Name -like "*$command*" |
        Select-Object -First 3 Name
        
        if ($suggestions) {
            Write-Host "`nDid you mean:" -ForegroundColor Yellow
            $suggestions | ForEach-Object {
                Write-Host "  • $($_.Name)" -ForegroundColor Cyan
            }
        }
    }
}