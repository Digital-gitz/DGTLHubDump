#region Logging Configuration
$logDir = Join-Path $PSScriptRoot "..\..\logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "profile_$(Get-Date -Format 'yyyyMMdd').log"
$maxLogSize = 10MB

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'Info',
        [switch]$NoConsole
    )
    
    if ((Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxLogSize)) {
        Move-Item -Path $logFile -Destination (Join-Path $logDir "profile_$(Get-Date -Format 'yyyyMMdd_HHmmss')_archive.log") -Force
    }
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logMessage
    
    if (-not $NoConsole) {
        switch ($Level) {
            'Error' { Write-Host $logMessage -ForegroundColor Red }
            'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
            'Success' { Write-Host $logMessage -ForegroundColor Green }
            'Debug' { Write-Host $logMessage -ForegroundColor Gray }
            default { Write-Host $logMessage }
        }
    }
}

# Add performance monitoring
$script:performanceMetrics = @{
    ScriptLoadTimes = @{}
    ModuleLoadTimes = @{}
    TotalLoadTime   = 0
}

function Measure-ExecutionTime {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        [string]$Name
    )
    
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        & $ScriptBlock
    }
    finally {
        $sw.Stop()
        $script:performanceMetrics.ScriptLoadTimes[$Name] = $sw.ElapsedMilliseconds
    }
}

function Get-PerformanceMetrics {
    return $script:performanceMetrics
}
#endregion Logging Configuration 