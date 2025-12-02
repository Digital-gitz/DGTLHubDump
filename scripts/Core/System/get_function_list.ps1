# get_function_list.ps1
function Get-ScriptsFunctions {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ScriptsPath = $PSScriptRoot
    )

    # Get all PowerShell scripts
    $scripts = Get-ChildItem -Path $ScriptsPath -Filter "*.ps1" -Recurse

    foreach ($script in $scripts) {
        Write-Host "`n=== Functions in $($script.Name) ===" -ForegroundColor Cyan
        
        # Read the script content
        $content = Get-Content $script.FullName -Raw
        
        # Find all function blocks
        $pattern = 'function\s+([A-Za-z0-9-]+)\s*{'
        $functionMatches = [regex]::Matches($content, $pattern)
        
        foreach ($match in $functionMatches) {
            $functionName = $match.Groups[1].Value
            Write-Host "Function: $functionName" -ForegroundColor Green
        }
    }
}

# Add alias for singular version
Set-Alias -Name Get-ScriptsFunction -Value Get-ScriptsFunctions

Write-Host "get_function_disk loaded" -ForegroundColor Cyan