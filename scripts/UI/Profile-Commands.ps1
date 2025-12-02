function Get-ScriptsFunctions {
    [CmdletBinding()]
    param()
    
    try {
        # Get the Scripts directory path from the profile's location
        $scriptsDir = Join-Path $PSScriptRoot ".." "Scripts"
        Write-Host "Debug: Looking for scripts in: $scriptsDir" -ForegroundColor Gray
        
        if (-not (Test-Path $scriptsDir)) {
            Write-Warning "Scripts directory not found at: $scriptsDir"
            return
        }
        
        $scripts = Get-ChildItem -Path $scriptsDir -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
        Write-Host "Debug: Found $($scripts.Count) script files" -ForegroundColor Gray
        
        Write-Host "`nAvailable Script Functions:" -ForegroundColor Cyan
        
        foreach ($script in $scripts) {
            try {
                $content = Get-Content $script.FullName -Raw -ErrorAction Stop
                $functions = [regex]::Matches($content, 'function\s+([A-Za-z0-9-]+)\s*{')
                
                if ($functions.Count -gt 0) {
                    Write-Host "`n$($script.Name):" -ForegroundColor Yellow
                    foreach ($function in $functions) {
                        Write-Host "  $($function.Groups[1].Value)" -ForegroundColor Green
                    }
                }
            }
            catch {
                Write-Warning "Error processing script $($script.Name): $_"
            }
        }
    }
    catch {
        Write-Warning "Error getting script functions: $_"
        Write-Host "Debug: Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
}