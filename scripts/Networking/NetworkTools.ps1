# NetworkTools.ps1
# Created 2025-03-03
# Description: Add your description here

function Get-ScriptInfo {
    [CmdletBinding()]
    param()

    $scriptName = Split-Path -Leaf $MyInvocation.MyCommand.Path
    $scriptPath = $MyInvocation.MyCommand.Path
    $lastModified = (Get-Item $scriptPath).LastWriteTime
    $versionLine = Select-String -Path $scriptPath -Pattern '^#\s*Created' | Select-Object -First 1
    $created = $null
    if ($versionLine) {
        $created = $versionLine.Line -replace '^#\s*Created\s*', ''
    }

    Write-Host "Script Name   : $scriptName" -ForegroundColor Cyan
    Write-Host "Script Path   : $scriptPath" -ForegroundColor Gray
    if ($created) {
        Write-Host "Created On    : $created" -ForegroundColor Gray
    }
    Write-Host "Last Modified : $lastModified" -ForegroundColor Gray

    # Optionally output a short description from the header
    $descLine = Select-String -Path $scriptPath -Pattern '^#\s*Description\s*:' | Select-Object -First 1
    if ($descLine) {
        $desc = $descLine.Line -replace '^#\s*Description\s*:\s*', ''
        Write-Host "Description   : $desc" -ForegroundColor Gray
    }
}



function Get-My_IP {
    curl ipinfo.io
}

# Add your functions below this line
