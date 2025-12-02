function Import-ProfileScripts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ScriptPaths,
        
        [Parameter(Mandatory = $false)]
        [switch]$ContinueOnError,
        
        [Parameter(Mandatory = $false)]
        [switch]$Verbose
    )
    
    $loadedScripts = @()
    $failedScripts = @()
    
    foreach ($script in $ScriptPaths) {
        $scriptName = Split-Path -Path $script -Leaf
        
        if (Test-Path $script) {
            try {
                $startTime = Get-Date
                if ($Verbose) { Write-Host "Loading $scriptName..." -ForegroundColor Cyan -NoNewline }
                
                # Dot source the script
                . $script
                
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalMilliseconds
                
                if ($Verbose) { Write-Host " Done! ($($duration.ToString("0.00"))ms)" -ForegroundColor Green }
                $loadedScripts += $scriptName
            }
            catch {
                Write-Warning "Error loading ${scriptName}: $($_.Exception.Message)"
                $failedScripts += @{
                    Name  = $scriptName
                    Path  = $script
                    Error = $_.Exception.Message
                }
                
                if (-not $ContinueOnError) {
                    throw "Failed to load script: $script. Error: $($_.Exception.Message)"
                }
            }
        }
        else {
            Write-Warning "Script not found: $script"
            $failedScripts += @{
                Name  = $scriptName
                Path  = $script
                Error = "File not found"
            }
            
            if (-not $ContinueOnError) {
                throw "Script not found: $script"
            }
        }
    }
    
    return @{
        Loaded      = $loadedScripts
        Failed      = $failedScripts
        TotalLoaded = $loadedScripts.Count
        TotalFailed = $failedScripts.Count
    }
}