# # Get CPU usage every 2 seconds
# while ($true) {
#     $cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time'
#     $timestamp = Get-Date
#     $cpu = $cpuUsage.CounterSamples.CookedValue
#     Write-Host "$timestamp - CPU Usage: $cpu%"
#     Start-Sleep -Seconds 2
# }


while ($true) {
    # Timestamp
    $timestamp = Get-Date

    # CPU Usage
    $cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time'
    $cpu = $cpuUsage.CounterSamples.CookedValue

    # Memory Usage
    $totalMemory = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty TotalVisibleMemorySize
    $freeMemory = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty FreePhysicalMemory
    $usedMemory = $totalMemory - $freeMemory

    # Disk Usage
    $diskUsage = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        $usedSpace = $_.Used / 1GB
        $freeSpace = $_.Free / 1GB
        $totalSpace = $_.Used / 1GB + $_.Free / 1GB
        [PSCustomObject]@{
            Drive = $_.Name
            TotalSpace = [math]::round($totalSpace, 2)
            UsedSpace = [math]::round($usedSpace, 2)
            FreeSpace = [math]::round($freeSpace, 2)
        }
    }

    # Network Activity
    $networkStats = Get-NetAdapterStatistics | ForEach-Object {
        [PSCustomObject]@{
            Adapter = $_.Name
            ReceivedBytes = $_.ReceivedBytes
            SentBytes = $_.SentBytes
        }
    }

    # Running Processes
    $processes = Get-Process | Select-Object Name, CPU, Id, WorkingSet, StartTime | Sort-Object CPU -Descending | Select-Object -First 10

    # Display Results
    Write-Host "$timestamp - System Monitoring"
    Write-Host "CPU Usage: $cpu%"
    Write-Host "Memory - Total: $($totalMemory / 1MB) MB, Used: $($usedMemory / 1MB) MB, Free: $($freeMemory / 1MB) MB"
    $diskUsage | ForEach-Object { Write-Host "Drive $_.Drive - Total: $_.TotalSpace GB, Used: $_.UsedSpace GB, Free: $_.FreeSpace GB" }
    $networkStats | ForEach-Object { Write-Host "Adapter: $_.Adapter - Received: $_.ReceivedBytes, Sent: $_.SentBytes" }
    Write-Host "Top 10 Processes by CPU Usage:"
    $processes | ForEach-Object { Write-Host "$($_.Name) - CPU: $($_.CPU)%, ID: $($_.Id), Working Set: $($_.WorkingSet), Started: $($_.StartTime)" }

    Start-Sleep -Seconds 10
}