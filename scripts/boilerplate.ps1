function dot_vscode_boilerplate {
    param(
        [string]$Path = $(Read-Host 
        "Enter the path to create the boilerplate (e.g. C:\projects\myawesomeapp)"),
        [string]$Name = $(Read-Host
        "Enter the name of the boilerplate (for display/logging, optional)")
    )

    if (-not (Test-Path $Path)) {
        Write-Host "Creating directory: $Path" -ForegroundColor Yellow
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }

    $vscodePath = Join-Path $Path ".vscode"
    if (-not (Test-Path $vscodePath)) {
        Write-Host "Creating .vscode directory at: $vscodePath" -ForegroundColor Yellow
        New-Item -Path $vscodePath -ItemType Directory -Force | Out-Null
    }

    Write-Host "Launching VSCode Boilerplate..." -ForegroundColor Green
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "VSCode Boilerplate Info: https://github.com/microsoft/vscode-boilerplate" -ForegroundColor Cyan

    $settingsPath = Join-Path $vscodePath "settings.json"
    $extensionsPath = Join-Path $vscodePath "extensions.json"

    $settingsContent = @"
{
    // Example VSCode settings
    "editor.tabSize": 4,
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true
    }
}
"@

    $extensionsContent = @"
{
    // Example recommended extensions
    "recommendations": [
        "ms-vscode.PowerShell",
        "esbenp.prettier-vscode"
    ]
}
"@

    Set-Content -Path $settingsPath -Value $settingsContent -Encoding utf8
    Set-Content -Path $extensionsPath -Value $extensionsContent -Encoding utf8

    Write-Host "Created: $settingsPath" -ForegroundColor Green
    Write-Host "Created: $extensionsPath" -ForegroundColor Green
    Write-Host "Done! You can now open $Path in VSCode." -ForegroundColor Cyan
}
