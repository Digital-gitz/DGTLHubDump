
function global:overlay {
    Start-Process "D:\Windows\Exe\overlay-app.1.0.0.exe"
}

# function global:Blender {
#     Start-Process ""
# }

# Github function for Going over Repos and opening Various repo directories
function global:ghub {
    try {
        $path = "C:\Users\Digital_Russkiy\Documents\GitHub"
        if (Test-Path $path) {
            Set-Location -Path $path -ErrorAction Stop
            Write-Host "Successfully changed directory to: $path" -ForegroundColor Green
            
            if (Get-Command gh -ErrorAction SilentlyContinue) {
                Write-Host "`nGitHub Repositories:" -ForegroundColor Cyan
                Write-Host "─────────────────────────────" -ForegroundColor DarkGray

                gh repo list --limit 100 | ForEach-Object {
                    $repo = $_ -split '\s+'
                    Write-Host ("{0,-40} {1}" -f $repo[0], $repo[1]) -ForegroundColor Gray
                }
            }
            else {
                Write-Host "GitHub CLI (gh) is not installed. Please install it to list repositories." -ForegroundColor Yellow
                Write-Host "Installation command: winget install GitHub.cli" -ForegroundColor Yellow
            }
            
            Write-Host "`nContents of GitHub directory:" -ForegroundColor Cyan
            Get-ChildItem -Path $path | Format-Table Name, LastWriteTime, Length -AutoSize
        }
        else {
            Write-Host "Error: Directory does not exist at path: $path" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error changing directory: $_" -ForegroundColor Red
    }

    Start-Process "https://github.com/"
}
# Ddump folder and functions
function global:ddump {
    try {
        $path = "C:\Users\Digital_Russkiy\Documents\DGTLHubDump"
        if (Test-Path $path) {
            Set-Location -Path $path -ErrorAction Stop
            Write-Host "Successfully changed directory to: $path" -ForegroundColor Green
        }
        else {
            Write-Host "Error: Directory does not exist at path: $path" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error changing directory: $_" -ForegroundColor Red
    }

    try {
        $null = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 5
        Start-Process "https://github.com/Digital-gitz/DGTLHubDump"
        Write-Host "Successfully Opened https://github.com/Digital-gitz/DGTLHubDump"
    }
    catch {
        Write-Warning "Could not connect to GitHub. Please check your internet connection."
    }
}


function Get-DirectoryFiles {
    param([string]$Path = ".")
    
    if (-not (Test-Path $Path -PathType Container)) {
        Write-Error "Directory '$Path' does not exist or is not a directory."
        return
    }
    
    Get-ChildItem -Path $Path -File | ForEach-Object {
        Write-Host $_.Name
    }
}

function TwitchOverlay {
    $updatePath = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\Update.exe"
    $appPath = "C:\Users\Digital_Russkiy\AppData\Local\TransparentTwitchChatOverlay\TransparentTwitchChatWPF.exe"

    Write-Host "Starting Twitch Chat Overlay update..." -ForegroundColor Cyan
    Start-Process -FilePath $updatePath -Wait

    Write-Host "Launching Twitch Chat Overlay..." -ForegroundColor Green
    Start-Process -FilePath $appPath
}

function Open-Gmail {
    try {
        Start-Process "https://mail.google.com/"
        Write-Host "Gmail has been opened in your default browser." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to open Gmail: $_" -ForegroundColor Red
    }
}
