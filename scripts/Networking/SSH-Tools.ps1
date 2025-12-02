function Get-SshStatus {
    <#
    .SYNOPSIS
    Displays the installation status of OpenSSH components on Windows.

    .DESCRIPTION
    Uses Get-WindowsCapability to list all OpenSSH-related capabilities and their current state.
    If not running as administrator, falls back to showing SSH-related services.
    Also displays the location of ssh.exe (via where.exe) and the installed ssh version.

    .EXAMPLE
    Get-SshStatus
    #>

    # Show ssh.exe location(s)
    Write-Host "`n[where.exe ssh:]" -ForegroundColor Cyan
    try {
        $sshPaths = & where.exe ssh 2>$null
        if ($sshPaths) {
            $sshPaths | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
        }
        else {
            Write-Host "ssh.exe not found in PATH." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error running where.exe ssh: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Show ssh version
    Write-Host "`n[ssh -V connecting to test if SSH client works:]" -ForegroundColor Cyan
    try {
        $sshVersion = & ssh -V 2>&1
        if ($sshVersion) {
            Write-Host $sshVersion -ForegroundColor Gray
        }
        else {
            Write-Host "Unable to determine ssh version." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error running ssh -V: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Check if SSH daemon is running and listening on port 22
    Write-Host "`n[Checking if SSH daemon is running and listening on port TCP/22:]" -ForegroundColor Cyan
    try {
        $netstatOutput = & netstat -nao | find /i '":22"'
        if ($netstatOutput) {
            Write-Host "SSH daemon is running and listening on port TCP/22:" -ForegroundColor Green
            $netstatOutput | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
        }
        else {
            Write-Host "SSH daemon is not listening on port TCP/22." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error checking SSH daemon status: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Check for elevated (admin) permissions
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        try {
            $capabilities = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH*' }
            if ($capabilities) {
                Write-Host "`nOpenSSH Capabilities:" -ForegroundColor Cyan
                $capabilities | ForEach-Object {
                    Write-Host ("{0,-30} : {1}" -f $_.Name, $_.State) -ForegroundColor Gray
                }
            }
            else {
                Write-Host "No OpenSSH capabilities found on this system." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "Error retrieving OpenSSH status: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "`nNot running as administrator. Showing SSH-related services instead:" -ForegroundColor Yellow
        try {
            $sshServices = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*ssh*" }
            if ($sshServices) {
                Write-Host "SSH-related Services:" -ForegroundColor Cyan
                $sshServices | ForEach-Object {
                    try {
                        Write-Host ("{0,-30} : {1}" -f $_.Name, $_.Status) -ForegroundColor Gray
                    }
                    catch {
                        Write-Host ("{0,-30} : <Permission Denied>" -f $_.Name) -ForegroundColor DarkYellow
                    }
                }
            }
            else {
                Write-Host "No SSH-related services found on this system." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "Error retrieving SSH-related services: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Get-MyIP {
    try {
        Write-Host "Fetching your IP information..." -ForegroundColor Cyan
        $response = Invoke-RestMethod -Uri "https://ipinfo.io" -Method Get
        Write-Host "IP Information:" -ForegroundColor Green
        Write-Host "IP: $($response.ip)" -ForegroundColor Gray
        Write-Host "City: $($response.city)" -ForegroundColor Gray
        Write-Host "Region: $($response.region)" -ForegroundColor Gray
        Write-Host "Country: $($response.country)" -ForegroundColor Gray
        Write-Host "Location: $($response.loc)" -ForegroundColor Gray
        Write-Host "Organization: $($response.org)" -ForegroundColor Gray
        Write-Host "Timezone: $($response.timezone)" -ForegroundColor Gray
    }
    catch {
        Write-Host "Error fetching IP information: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-BIOSInfo {
    try {
        $scriptPath = Join-Path $PSScriptRoot "Scripts\Core\System\check-bios.ps1"
        
        if (Test-Path $scriptPath) {
            Write-Host "Checking BIOS information..." -ForegroundColor Cyan
            & $scriptPath
        }
        else {
            Write-Host "Error: BIOS check script not found at: $scriptPath" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error running BIOS check: $($_.Exception.Message)" -ForegroundColor Red
    }
}