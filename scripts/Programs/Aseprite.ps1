function global:Start-Aseprite {
    # Check if Aseprite is already running
    try {
        $aspriteProcess = Get-Process | Where-Object { 
            $_.ProcessName -like "*aseprite*" -or 
            $_.MainWindowTitle -like "*Aseprite*" -or
            $_.ProcessName -like "*Aseprite*"
        } -ErrorAction SilentlyContinue
        
        if ($null -eq $aspriteProcess -or $aspriteProcess.Count -eq 0) {
            Write-Host "Aseprite is not running. Starting it up!" -ForegroundColor Green
        }
        else {
            Write-Host "Stopping Aseprite..." -ForegroundColor Yellow
            $aspriteProcess | Stop-Process -Force -ErrorAction SilentlyContinue
            # Give it a moment to fully close
            Start-Sleep -Seconds 2
            Write-Host "Aseprite stopped." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error checking Aseprite process: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Verify the path exists before trying to start
    $aspritePath = "C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe"
    if (Test-Path $aspritePath) {
        try {
            Start-Process -FilePath $aspritePath -ErrorAction Stop
            Write-Host "Aseprite started successfully!" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to start Aseprite: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Could not find Aseprite executable at expected path." -ForegroundColor Red
        Write-Host "Please verify the installation path: $aspritePath" -ForegroundColor Yellow
        Write-Host "You can also try running Aseprite manually or check if it's installed in a different location." -ForegroundColor Yellow
    }
}

function Show-AsepriteCommands {
    <#
    .SYNOPSIS
    Provides quick access to Aseprite-related resources and actions.
    
    .DESCRIPTION
    Displays a menu of options for Aseprite including:
    - Starting/stopping Aseprite
    - Opening directories
    - Accessing official websites and social media
    - Community resources
    
    .EXAMPLE
    Aseprite
    Shows the interactive menu for Aseprite options.
    #>
    
    do {
        Clear-Host
        Write-Host "`n🎨 Aseprite Quick Access Menu" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
        
        $options = @(
            @{ Number = "1"; Action = "Start/Stop Aseprite"; Function = "Start-Aseprite" },
            @{ Number = "2"; Action = "Open Aseprite Directory"; Path = "C:\Program Files (x86)\Steam\steamapps\common\Aseprite" },
            @{ Number = "3"; Action = "Open Aseprite Website"; URL = "https://www.aseprite.org" },
            @{ Number = "4"; Action = "Open Aseprite Wiki"; URL = "https://github.com/aseprite/aseprite/wiki" },
            @{ Number = "5"; Action = "Open Aseprite GitHub"; URL = "https://github.com/aseprite/aseprite" },
            @{ Number = "6"; Action = "Open Aseprite Discord"; URL = "https://discord.gg/aseprite" },
            @{ Number = "7"; Action = "Open Aseprite Reddit"; URL = "https://www.reddit.com/r/aseprite" },
            @{ Number = "8"; Action = "Open Aseprite Twitter"; URL = "https://twitter.com/aseprite" },
            @{ Number = "9"; Action = "Open Aseprite YouTube"; URL = "https://www.youtube.com/c/Aseprite" },
            @{ Number = "10"; Action = "Open Aseprite Steam Page"; URL = "https://store.steampowered.com/app/431730/Aseprite" },
            @{ Number = "11"; Action = "Open Aseprite Itch.io"; URL = "https://aseprite.itch.io/aseprite" },
            @{ Number = "12"; Action = "Open Aseprite Documentation"; URL = "https://www.aseprite.org/docs" },
            @{ Number = "13"; Action = "Open Aseprite Community"; URL = "https://community.aseprite.org" },
            @{ Number = "14"; Action = "Open Aseprite Blog"; URL = "https://www.aseprite.org/blog" },
            @{ Number = "15"; Action = "Open Aseprite Support"; URL = "https://www.aseprite.org/support" },
            @{ Number = "0"; Action = "Exit" }
        )
        
        # Display all options
        foreach ($option in $options) {
            Write-Host ("{0,2}. {1}" -f $option.Number, $option.Action) -ForegroundColor Yellow
        }
        
        Write-Host "`nEnter your choice (0-15): " -NoNewline -ForegroundColor Cyan
        
        try {
            $choice = Read-Host
            
            # Validate input
            if ($choice -notmatch '^[0-9]+$') {
                Write-Host "`nInvalid input. Please enter a number between 0-15." -ForegroundColor Red
                Start-Sleep -Seconds 2
                continue
            }
            
            # Find the selected option
            $selectedOption = $options | Where-Object { $_.Number -eq $choice }
            
            if ($selectedOption) {
                Write-Host "`nExecuting: $($selectedOption.Action)" -ForegroundColor Green
                
                if ($selectedOption.Number -eq "0") {
                    Write-Host "Exiting Aseprite menu." -ForegroundColor Gray
                    return
                }
                elseif ($selectedOption.Function) {
                    # Execute the function
                    try {
                        & $selectedOption.Function
                    }
                    catch {
                        Write-Host "Error executing function: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                elseif ($selectedOption.Path) {
                    # Open directory
                    if (Test-Path $selectedOption.Path) {
                        try {
                            Start-Process "explorer.exe" -ArgumentList $selectedOption.Path -ErrorAction Stop
                            Write-Host "Opened directory: $($selectedOption.Path)" -ForegroundColor Green
                        }
                        catch {
                            Write-Host "Failed to open directory: $($_.Exception.Message)" -ForegroundColor Red
                        }
                    }
                    else {
                        Write-Host "Directory not found: $($selectedOption.Path)" -ForegroundColor Red
                        Write-Host "Please verify the Aseprite installation path." -ForegroundColor Yellow
                    }
                }
                elseif ($selectedOption.URL) {
                    # Open URL
                    try {
                        Start-Process $selectedOption.URL -ErrorAction Stop
                        Write-Host "Opened: $($selectedOption.URL)" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Failed to open URL: $($selectedOption.URL)" -ForegroundColor Red
                        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
            else {
                Write-Host "`nInvalid choice. Please select a number between 0-15." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "`nAn error occurred: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host "`nPress any key to continue..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
    } while ($true)
}

# Set alias for easier access
Set-Alias -Name aseprite -Value Aseprite -Scope Global
