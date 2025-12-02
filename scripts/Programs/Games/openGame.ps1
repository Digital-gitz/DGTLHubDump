function global:Start-DoomEternal {
    if ((Get-Process "Doom Eternal" -ea SilentlyContinue) -eq $null) {
        Write-Host "Doom Eternal is not running. Starting it up!"
    }
    # If it is running, close it and reopen it
    else {
        Write-Host "Stopping Doom Eternal."
        Stop-Process -Name "Doom Eternal"
    }

    Start-Process -FilePath "C:\Program Files (x86)\Steam\steamapps\common\DOOMEternal\DOOMEternalx64vk.exe"
}



# function Start-DoomEternal {
#     # Check for the actual process name which is likely different from "Doom Eternal"
#     $doomProcess = Get-Process | Where-Object { $_.MainWindowTitle -like "*DOOM Eternal*" -or $_.ProcessName -like "*DOOMEternal*" }
    
#     if ($null -eq $doomProcess) {
#         Write-Host "DOOM Eternal is not running. Starting it up!"
#     }
#     else {
#         Write-Host "Stopping DOOM Eternal."
#         $doomProcess | Stop-Process -Force
#         # Give it a moment to fully close
#         Start-Sleep -Seconds 2
#     }

#     # Verify the path exists before trying to start
#     $doomPath = "C:\Program Files (x86)\Steam\steamapps\common\DOOMEternal\DOOMEternalx64vk.exe"
#     if (Test-Path $doomPath) {
#         Start-Process -FilePath $doomPath
#     }
#     else {
#         Write-Host "Could not find DOOM Eternal executable at expected path." -ForegroundColor Red
#         Write-Host "Please verify the installation path: $doomPath" -ForegroundColor Yellow
#     }
# }