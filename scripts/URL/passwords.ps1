function password_manager {
    write-host "Your keypassword files are stored in Documents"
    Write-Host ""
    Write-Host "🛠️ Password Fuctions" -ForegroundColor Cyan
    Show-CommandList @(
        @{ Name = "keypass_directory"; Desc = "Open Keypass password manager directory" }
        @{ Name = "Open-EdgePasswords"; Desc = "Open Edge Passwords" }
        @{ Name = "Open-Keypass"; Desc = "Open Keypass password manager" }
    )
}

$passwords = @{
    Edge = "edge://wallet/passwords?source=assetsSettingsPasswords"
}

function keypass_directory {
    $dirs = @(
        "C:\Program Files\KeePassXC",
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\KeePassXC"
    )

    foreach ($dir in $dirs) {
        if (Test-Path $dir) {
            Write-Host "Opening directory: $dir" -ForegroundColor Cyan
            Start-Process explorer.exe $dir
        }
        else {
            Write-Host "Directory not found: $dir" -ForegroundColor Yellow
        }
    }
}

function Open-EdgePasswords {
    Start-Process $passwords.Edge
    Write-Host "Opened Edge Passwords: $($passwords.Edge)" -ForegroundColor Green
}

function Open-Keypass {
    Start-Process "C:\Program Files\KeePassXC\KeePassXC.exe"
    Write-Host "Opened Keypass password manager" -ForegroundColor Green
}
