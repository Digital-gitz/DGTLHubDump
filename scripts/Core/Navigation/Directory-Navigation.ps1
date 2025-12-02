

function cd_obsidianRoot {
    <#
    .SYNOPSIS
    Navigates to the root Obsidian folder in iCloudDrive.

    .DESCRIPTION
    Changes the current directory to:
    C:\Users\Digital_Russkiy\iCloudDrive\iCloud~md~obsidian

    .EXAMPLE
    cd_obsidianRoot
    #>
    $obsidianRoot = "C:\Users\Digital_Russkiy\iCloudDrive\iCloud~md~obsidian"
    if (Test-Path $obsidianRoot) {
        Set-Location $obsidianRoot
        Write-Host "Navigated to Obsidian root directory:" -ForegroundColor Blue
        Write-Host $obsidianRoot -ForegroundColor Cyan
    }
    else {
        Write-Host "Obsidian root directory not found: $obsidianRoot" -ForegroundColor Red
    }
}

function pixel_apps {
    <#
    .SYNOPSIS
    Navigates to the Pixel Apps directory.
    #>
    $pixelApps = "C:\Users\Digital_Russkiy\iCloudDrive\iCloud~md~obsidian\Pixel_Apps"
    if (Test-Path $pixelApps) {
        Set-Location $pixelApps
        Write-Host "Navigated to Pixel Apps directory:" -ForegroundColor Blue
        Write-Host $pixelApps -ForegroundColor Cyan
    }
    else {
        Write-Host "Pixel Apps directory not found: $pixelApps" -ForegroundColor Red
    }
}


function Go_AsepriteDirectory {
    $dir = "D:\Aseprite"
    if (Test-Path $dir) {
        Write-Host "Opening directory: $dir" -ForegroundColor Cyan
        Start-Process explorer.exe $dir
    }
    else {
        Write-Host "Directory not found: $dir" -ForegroundColor Yellow
    }
}


function GoPokemonSketchesDirectory {
    $dir = "D:\Aseprite\pokemon_Sketchs"
    if (Test-Path $dir) {
        Write-Host "Opening directory: $dir" -ForegroundColor Cyan
        Start-Process explorer.exe $dir
    }
    else {
        Write-Host "Directory not found: $dir" -ForegroundColor Yellow
    }
}

function pyscripts {
    $dir = "C:\Users\Digital_Russkiy\Documents\python_scripts"
    if (Test-Path $dir) {
        Set-Location $dir
        Write-Host "Changed directory to: $dir" -ForegroundColor Cyan
    }
    else {
        Write-Host "Directory not found: $dir" -ForegroundColor Yellow
    }
}