#region Utility Functions

# Function to execute Bash scripts properly
function Invoke-BashScript {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        [string]$GitBashPath = "C:\Program Files\Git\bin\bash.exe",
        [string[]]$Arguments
    )
    
    if (-not (Test-Path $GitBashPath)) {
        throw "Git Bash not found at $GitBashPath"
    }

    $UnixPath = $ScriptPath.Replace('\', '/').Replace('C:', '/c')
    
    if ($Arguments) {
        & "$GitBashPath" -c "$UnixPath $($Arguments -join ' ')"
    } else {
        & "$GitBashPath" -c "$UnixPath"
    }
}

# Enhanced module installation with validation
function Find-AndInstallModule {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [switch]$Force,
        [switch]$AllowPrerelease
    )

    try {
        $module = Find-Module -Name $ModuleName -ErrorAction Stop
        Write-Host "Found module: $($module.Name) v$($module.Version) - $($module.Description)" -ForegroundColor Cyan
        
        $installed = Get-Module -Name $ModuleName -ListAvailable
        if ($installed) {
            Write-Host "Currently installed version: $($installed.Version)" -ForegroundColor Yellow
        }

        if (!$Force) {
            $install = Read-Host "Do you want to install this module? (Y/N)"
            if ($install -ne 'Y') { return }
        }

        $params = @{
            Name = $ModuleName
            Force = $true
        }
        if ($AllowPrerelease) { $params.AllowPrerelease = $true }
        
        Install-Module @params
        Write-Host "Module $ModuleName installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Error installing module: $_"
    }
}

# Improved script creation with templates
function New-Script {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [ValidateSet('Basic', 'Advanced', 'Function', 'Module')]
        [string]$Template = 'Basic',
        [string]$Description = ''
    )

    $scriptPath = Join-Path $CommonPaths.Scripts "$Name.ps1"
    if (Test-Path $scriptPath) {
        Write-Warning "Script already exists. Opening existing file."
    }
    else {
        $template = switch ($Template) {
            'Basic' {
@"
<#
.SYNOPSIS
    $Name
.DESCRIPTION
    $Description
.NOTES
    Created by: $env:USERNAME
    Created on: $(Get-Date -Format 'yyyy-MM-dd')
#>

#Requires -Version 5.1

"@
            }
            'Advanced' {
@"
<#
.SYNOPSIS
    $Name
.DESCRIPTION
    $Description
.NOTES
    Created by: $env:USERNAME
    Created on: $(Get-Date -Format 'yyyy-MM-dd')
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=`$true)]
    [string]`$Parameter1
)

begin {
    # Initialize resources
}

process {
    # Main processing
}

end {
    # Cleanup
}
"@
            }
            Default { '' }
        }

        New-Item -Path $scriptPath -ItemType File -Value $template -Force
    }
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code $scriptPath
    }
    else {
        notepad $scriptPath
    }
}

# Improved system information function
function Get-EnhancedSystemInfo {
    [CmdletBinding()]
    param()
    
    $computerInfo = Get-ComputerInfo
    $processor = Get-WmiObject Win32_Processor
    $memory = Get-WmiObject Win32_OperatingSystem
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
    $network = Get-NetAdapter | Where-Object Status -eq 'Up'
    
    [PSCustomObject]@{
        OS = @{
            Name = $computerInfo.OsName
            Version = $computerInfo.OsVersion
            Architecture = $computerInfo.OsArchitecture
            LastBoot = $computerInfo.OsLastBootUpTime
            Uptime = (Get-Date) - $computerInfo.OsLastBootUpTime
        }
        Hardware = @{
            Processor = $processor.Name
            TotalMemoryGB = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
            FreeMemoryGB = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
            MemoryUsage = [math]::Round((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100, 2)
        }
        Storage = $disk | ForEach-Object {
            @{
                Drive = $_.DeviceID
                SizeGB = [math]::Round($_.Size / 1GB, 2)
                FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
                UsedPercent = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 2)
            }
        }
        Network = $network | ForEach-Object {
            @{
                Name = $_.Name
                Speed = "$([math]::Round($_.LinkSpeed / 1000, 2)) Gbps"
                MacAddress = $_.MacAddress
            }
        }
    }
}

# New function to monitor system resources
function Start-ResourceMonitor {
    [CmdletBinding()]
    param(
        [int]$Interval = 5,
        [int]$Samples = 12
    )
    
    for ($i = 1; $i -le $Samples; $i++) {
        $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
        $memory = Get-WmiObject Win32_OperatingSystem
        $memoryUsage = 100 - ($memory.FreePhysicalMemory / $memory.TotalVisibleMemorySize * 100)
        
        [PSCustomObject]@{
            Time = Get-Date -Format "HH:mm:ss"
            CPU = [math]::Round($cpu, 2)
            MemoryUsage = [math]::Round($memoryUsage, 2)
            Sample = $i
        }
        
        Start-Sleep -Seconds $Interval
    }
}

# Function to convert string encoding
function Convert-StringEncoding {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$InputString,
        [Parameter(Mandatory=$true)]
        [ValidateSet('UTF8', 'ASCII', 'Unicode', 'UTF32', 'BigEndianUnicode')]
        [string]$FromEncoding,
        [Parameter(Mandatory=$true)]
        [ValidateSet('UTF8', 'ASCII', 'Unicode', 'UTF32', 'BigEndianUnicode')]
        [string]$ToEncoding
    )
    
    process {
        $fromBytes = [System.Text.Encoding]::$FromEncoding.GetBytes($InputString)
        $toBytes = [System.Text.Encoding]::Convert(
            [System.Text.Encoding]::$FromEncoding,
            [System.Text.Encoding]::$ToEncoding,
            $fromBytes
        )
        [System.Text.Encoding]::$ToEncoding.GetString($toBytes)
    }
}

# Function to test network connectivity with detailed results
function Test-NetworkConnectivity {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Targets,
        [int]$Count = 4,
        [int]$Timeout = 1000
    )
    
    foreach ($target in $Targets) {
        $results = 1..$Count | ForEach-Object {
            $ping = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
            
            [PSCustomObject]@{
                Target = $target
                Attempt = $_
                Success = $null -ne $ping
                ResponseTime = if ($ping) { $ping.ResponseTime } else { 0 }
                Timestamp = Get-Date
            }
        }
        
        $succeeded = ($results | Where-Object Success).Count
        
        [PSCustomObject]@{
            Target = $target
            SuccessRate = "$([math]::Round($succeeded / $Count * 100, 2))%"
            AverageResponse = [math]::Round(($results | Where-Object Success | Measure-Object -Property ResponseTime -Average).Average, 2)
            MinResponse = ($results | Where-Object Success | Measure-Object -Property ResponseTime -Minimum).Minimum
            MaxResponse = ($results | Where-Object Success | Measure-Object -Property ResponseTime -Maximum).Maximum
            Details = $results
        }
    }
}

#endregion
write-host "UtilityFunctions.aiUpdate loaded" -ForegroundColor Green