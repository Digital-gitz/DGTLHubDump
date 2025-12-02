# Performance tracking functionality Global Variables
$global:ProfileStartTime = Get-Date
$global:MetricsEnabled = $true
$global:ProfileMetrics = @{}

# Configuration
$script:Config = @{
    DetailedLogging = $false
    ProgressBar = $true
    TimeFormat = "mm:ss.fff"
    ExportPath = Join-Path $env:USERPROFILE "ProfileMetrics"
}

function Register-ProfileMetric {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][datetime]$StartTime,
        [switch]$IsError,
        [string]$Details,
        [ValidateRange(0, 100)]
        [int]$Progress
    )
    
    if (-not $global:MetricsEnabled) { return }

    $duration = (Get-Date) - $StartTime
    $global:ProfileMetrics[$Name] = @{
        Duration = $duration
        IsError = $IsError
        Details = $Details
        Timestamp = Get-Date
        Progress = $Progress
    }

    if ($script:Config.ProgressBar -and $Progress -gt 0) {
        Write-Progress -Activity "Profile Metrics" -Status $Name -PercentComplete $Progress
    }
}

function Measure-ProfilePerformance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [datetime]$StartTime = $script:startTime,
        
        [Parameter(Mandatory=$false)]
        [switch]$AsObject
    )
    
    $endTime = Get-Date
    $duration = ($endTime - $StartTime).TotalMilliseconds
    
    $memoryUsage = [System.GC]::GetTotalMemory($true) / 1MB
    $processes = Get-Process -Id $PID
    
    $performanceData = @{
        LoadTime = $duration
        StartTime = $StartTime
        EndTime = $endTime
        MemoryUsageMB = [math]::Round($memoryUsage, 2)
        CPU = $processes.CPU
        WorkingSetMB = [math]::Round($processes.WorkingSet / 1MB, 2)
    }
    
    if ($AsObject) {
        return [PSCustomObject]$performanceData
    }
    else {
        Write-Host "`nProfile Load Statistics:" -ForegroundColor Cyan
        Write-Host "  Load Time: $($duration.ToString("0.00")) ms"
        Write-Host "  Memory Usage: $($performanceData.MemoryUsageMB) MB"
        Write-Host "  Working Set: $($performanceData.WorkingSetMB) MB"
    }
}

# Record start time at beginning of profile
$script:startTime = Get-Date
function Show-ProfileMetrics {
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [switch]$SortByDuration,
        [switch]$Export,
        [ValidateSet('Console', 'CSV', 'JSON')]
        [string]$OutputFormat = 'Console'
    )
    
    if (-not $global:MetricsEnabled) {
        Write-Warning "Metrics are not enabled"
        return
    }

    $metrics = $global:ProfileMetrics.GetEnumerator()
    
    if ($SortByDuration) {
        $metrics = $metrics | Sort-Object { $_.Value.Duration.TotalMilliseconds } -Descending
    } else {
        $metrics = $metrics | Sort-Object Name
    }
    
    $totalTime = ($metrics | Measure-Object -Property { $_.Value.Duration.TotalMilliseconds } -Sum).Sum
    
    switch ($OutputFormat) {
        'Console' {
            Write-MetricsToConsole $metrics $totalTime $Detailed
        }
        'CSV' {
            Export-MetricsToCSV $metrics
        }
        'JSON' {
            Export-MetricsToJSON $metrics
        }
    }
}

function Write-MetricsToConsole {
    param(
        [Parameter(Mandatory)]$metrics,
        [Parameter(Mandatory)]$totalTime,
        [Parameter(Mandatory)]$detailed
    )
    
    # Header with fancy border
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║                    Profile Metrics Summary                    ║" -ForegroundColor Blue
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    
    # Total time summary
    Write-Host "`n⏱️ Total Execution Time:" -ForegroundColor Cyan -NoNewline
    Write-Host (" {0:N2} ms`n" -f $totalTime) -ForegroundColor Yellow
    
    # Column headers
    Write-Host "  Operation".PadRight(32) -NoNewline -ForegroundColor DarkCyan
    Write-Host "Duration".PadRight(15) -NoNewline -ForegroundColor DarkCyan
    Write-Host "% Total".PadRight(12) -NoNewline -ForegroundColor DarkCyan
    Write-Host "Progress" -ForegroundColor DarkCyan
    Write-Host "  " + "─" * 70 -ForegroundColor DarkGray
    
    # Metrics
    foreach ($metric in $metrics) {
        Write-MetricLine -metric $metric -totalTime $totalTime
    }
    
    # Detailed section if requested
    if ($detailed) {
        Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
        Write-Host "║                 Detailed System Information                  ║" -ForegroundColor Magenta
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
        
        $perfData = Measure-ProfilePerformance -AsObject
        
        Write-Host "`n  🧮 Memory Statistics:" -ForegroundColor Cyan
        Write-Host "     ├─ Total Usage:".PadRight(20) -NoNewline -ForegroundColor Gray
        Write-Host ("{0,8:N2} MB" -f $perfData.MemoryUsageMB) -ForegroundColor Green
        Write-Host "     └─ Working Set:".PadRight(20) -NoNewline -ForegroundColor Gray
        Write-Host ("{0,8:N2} MB" -f $perfData.WorkingSetMB) -ForegroundColor Green
        
        Write-Host "`n  ⚡ Performance:" -ForegroundColor Cyan
        Write-Host "     └─ CPU Time:".PadRight(20) -NoNewline -ForegroundColor Gray
        Write-Host ("{0,8:N2} sec" -f $perfData.CPU) -ForegroundColor Green
    }
    
    # Footer
    Write-Host "`n  📊 Statistics generated at" -NoNewline -ForegroundColor DarkGray
    Write-Host (" {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Gray
    Write-Host
}

function Write-MetricLine {
    param(
        [Parameter(Mandatory)]$metric,
        [Parameter(Mandatory)]$totalTime
    )
    
    $durationMs = [math]::Round($metric.Value.Duration.TotalMilliseconds, 2)
    $percentage = [math]::Round(($metric.Value.Duration.TotalMilliseconds / $totalTime) * 100, 1)
    $timestamp = $metric.Value.Timestamp.ToString($script:Config.TimeFormat)
    
    # Determine color based on duration percentage
    $color = switch ($percentage) {
        {$_ -lt 5}  { "Green" }
        {$_ -lt 15} { "Yellow" }
        {$_ -lt 30} { "DarkYellow" }
        default     { "Red" }
    }
    
    # Override color if there's an error
    if ($metric.Value.IsError) { $color = "Red" }
    
    # Create progress bar visualization with gradient
    $barLength = 20
    $filled = [math]::Round(($percentage / 100) * $barLength)
    $bar = ""
    
    # Generate gradient progress bar
    for ($i = 0; $i -lt $barLength; $i++) {
        if ($i -lt $filled) {
            $char = "■"
            if ($metric.Value.IsError) {
                $bar += "!$char"
            } else {
                $bar += $char
            }
        } else {
            $bar += "□"
        }
    }
    
    # Output the metric line
    Write-Host "  " -NoNewline
    Write-Host ($metric.Name).PadRight(30) -NoNewline -ForegroundColor White
    Write-Host ("{0,8:N2} ms" -f $durationMs).PadRight(15) -NoNewline -ForegroundColor $color
    Write-Host ("{0,5:N1}%" -f $percentage).PadRight(12) -NoNewline -ForegroundColor DarkGray
    Write-Host ("[{0}]" -f $bar) -ForegroundColor $color
    
    # Show details if present
    if ($metric.Value.Details) {
        Write-Host "     ├─ Details: " -NoNewline -ForegroundColor DarkGray
        Write-Host $metric.Value.Details -ForegroundColor Gray
        Write-Host "     └─ Time: " -NoNewline -ForegroundColor DarkGray
        Write-Host $timestamp -ForegroundColor Gray
    }
}

function Export-MetricsToCSV {
    param($metrics)
    
    if (-not (Test-Path $script:Config.ExportPath)) {
        New-Item -ItemType Directory -Path $script:Config.ExportPath -Force | Out-Null
    }
    
    $exportPath = Join-Path $script:Config.ExportPath "ProfileMetrics_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $metrics | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name
            Duration = $_.Value.Duration.TotalMilliseconds
            IsError = $_.Value.IsError
            Details = $_.Value.Details
            Timestamp = $_.Value.Timestamp
        }
    } | Export-Csv -Path $exportPath -NoTypeInformation
    
    Write-Host "Metrics exported to: $exportPath" -ForegroundColor Green
}

function Export-MetricsToJSON {
    param($metrics)
    
    if (-not (Test-Path $script:Config.ExportPath)) {
        New-Item -ItemType Directory -Path $script:Config.ExportPath -Force | Out-Null
    }
    
    $exportPath = Join-Path $script:Config.ExportPath "ProfileMetrics_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $metrics | ConvertTo-Json -Depth 10 | Out-File $exportPath
    
    Write-Host "Metrics exported to: $exportPath" -ForegroundColor Green
}

Write-Host "Metrics initialized"

# Measuring alias creation
$startTime = Get-Date
Set-Alias -Name g -Value git
# ... more aliases ...
Register-ProfileMetric -Name "Alias-Setup" -StartTime $startTime

# Measuring environment setup
$startTime = Get-Date
$env:PATH += ";C:\MyTools"
Register-ProfileMetric -Name "Env-Setup" -StartTime $startTime

# Example 1: Basic usage
$startTime = Get-Date
Start-Sleep -Milliseconds 500  # Simulating some work
Register-ProfileMetric -Name "Basic-Operation" -StartTime $startTime

# Example 2: With error handling
$startTime = Get-Date
try {
    # Simulating some work that might fail
    Start-Sleep -Milliseconds 300
    throw "Simulated error"
} catch {
    Register-ProfileMetric -Name "Failed-Operation" -StartTime $startTime -IsError -Details $_.Exception.Message
}

# Example 3: Measuring module import time
$startTime = Get-Date
Import-Module PSReadLine -Force
Register-ProfileMetric -Name "Import-PSReadLine" -StartTime $startTime

# Example 4: Measuring configuration loading
$startTime = Get-Date
# Your configuration loading code here
Start-Sleep -Milliseconds 200  # Simulating config load
Register-ProfileMetric -Name "Config-Load" -StartTime $startTime -Details "Loaded user preferences"

# View the results at the end of your profile
Show-ProfileMetrics -Detailed
