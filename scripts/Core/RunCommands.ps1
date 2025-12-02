function Show-RunCommandsMenu {
    param (
        [string]$Command,
        [switch]$AutoConfirm
    )

    # Define a hashtable of run commands and their descriptions
    $runCommands = @{
        "ms-settings:bluetooth"                           = "Bluetooth Settings"
        "xpsrchvw"                                        = "XPS Viewer"
        "wusa"                                            = "Windows Update Standalone Installer"
        "wordpad"                                         = "WordPad"
        "wmplayer"                                        = "Windows Media Player"
        "winword"                                         = "Microsoft Word"
        "winver"                                          = "Windows Version"
        "wbemtest"                                        = "Windows Management Instrumentation Tester"
        "useraccountcontrolsettings"                      = "User Account Control"
        "tpm.msc"                                         = "Trusted Platform Module Management"
        "taskschd.msc"                                    = "Task Scheduler"
        "taskmgr"                                         = "Task Manager"
        "sysdm.cpl"                                       = "System Properties"
        "snippingtool"                                    = "Snipping Tool (Scissors)"
        "sndvol"                                          = "Volume Mixer"
        "slui"                                            = "Windows Activation"
        "shutdown"                                        = "Windows Shutdown"
        "services.msc"                                    = "Background Services"
        "sdctl"                                           = "Backup and Restore"
        "sdclt"                                           = "Windows Backup"
        "resmon"                                          = "Resource Monitor"
        "regedit"                                         = "Registry Editor"
        "powershell"                                      = "Windows PowerShell Console"
        "powercfg.cpl"                                    = "Power Options"
        "osk"                                             = "On-Screen Keyboard"
        "optionalfeatures"                                = "Windows Advanced Features"
        "netstat"                                         = "View Active Connections (Command Prompt)"
        "netplwiz"                                        = "User Accounts"
        "ncpa.cpl"                                        = "Network Connections"
        "mstsc"                                           = "Remote Desktop Service"
        "msra"                                            = "Windows Remote Assistance"
        "msinfo32"                                        = "System Information"
        "msconfig"                                        = "System Configuration Utility"
        "mrt"                                             = "Malware Removal Tool"
        "mdsched"                                         = "Windows Memory Checker"
        "main.cpl"                                        = "Mouse Settings"
        "magnify"                                         = "Magnifier"
        "gpedit.msc"                                      = "Local Group Policy Editor"
        "firewall.cpl"                                    = "Windows Defender Firewall"
        "explorer"                                        = "Windows Explorer"
        "eventvwr.msc"                                    = "Event Viewer"
        "dxdiag"                                          = "DirectX Options"
        "diskmgmt.msc"                                    = "Disk Manager"
        "devmgmt.msc"                                     = "Device Manager"
        "control.exe /name Microsoft.TaskbarandStartMenu" = "Taskbar Settings"
        "control"                                         = "Control Panel"
        "control folders"                                 = "Folder Options"
        "cmd"                                             = "Command Prompt"
        "cleanmgr"                                        = "Clean Disk Manager"
        "chkdsk"                                          = "Check Disk Utility"
        "charmap"                                         = "Windows Character Table"
        "appwiz.cpl"                                      = "Programs and Components"
        "XPS Viewer"                                      = "xpsrchvw"
        "WordPad (Alternative Command)"                   = "write"
        "Windows Version"                                 = "winver"
        "Windows Update Standalone Installer"             = "wusa"
        "Windows System Restore"                          = "rstrui"
        "Windows Store Reset"                             = "wsreset"
        "Windows Shutdown"                                = "shutdown"
        "Windows Script Host Settings"                    = "wscript"
        "Windows Remote Assistance"                       = "msra"
        "Windows PowerShell Console"                      = "powershell"
        "Windows Mobility Center"                         = "mblctr"
        "Windows Memory Checker"                          = "mdsched"
        "Windows Media Player"                            = "wmplayer"
        "Windows Management Instrumentation"              = "wmimgmt.msc"
        "Windows Management Instrumentation Tester"       = "wbemtest"
        "Windows Help (Not supported in Windows 10)"      = "winhlp32"
        "Windows Font Viewer"                             = "fontview"
        "Windows Firewall with Advanced Security"         = "wf.msc"
        "Windows Features"                                = "control appwiz.cpl,,2"
        "Windows Fax and Scan"                            = "wfs"
        "Windows Explorer"                                = "explorer"
        "Windows Easy Transfer"                           = "migwiz"
        "Windows Disk Image Burner"                       = "isoburn"
        "Windows Directory"                               = "%WinDir%"
        "Windows Defender Firewall"                       = "firewall.cpl"
        "Windows Character Table"                         = "charmap"
        "Windows Backup"                                  = "sdclt"
        "Windows Advanced Features"                       = "optionalfeatures"
        "Windows Activation"                              = "slui"
        "Volume Mixer"                                    = "sndvol"
        "View Active Connections (Command Prompt)"        = "netstat"
        "User Profile Folder"                             = "%UserProfile%"
        "User Accounts"                                   = "netplwiz"
        "User Account Control"                            = "useraccountcontrolsettings"
        "Trusted Platform Module Management"              = "tpm.msc"
        "Troubleshoot Settings"                           = "control.exe /name Microsoft.Troubleshooting"
        "Temporary Folder"                                = "%Temp%"
        "Taskbar Settings"                                = "control.exe /name Microsoft.TaskbarandStartMenu"
        "Task Scheduler (taskschd.msc)"                   = "taskschd.msc"
        "Task Scheduler (control schedtasks)"             = "control schedtasks"
        "Task Manager"                                    = "taskmgr"
        "System Properties"                               = "sysdm.cpl"
        "System Information"                              = "msinfo32"
        "System Configuration Utility"                    = "msconfig"
        "Snipping Tool (Scissors)"                        = "snippingtool"
        "Resource Monitor"                                = "resmon"
        "Remote Desktop Service"                          = "mstsc"
        "Registry Editor"                                 = "regedit"
        "Programs and Components"                         = "appwiz.cpl"
        "Power Options"                                   = "powercfg.cpl"
        "Open Current User Folder"                        = "."
        "On-Screen Keyboard"                              = "osk"
        "Network Connections"                             = "ncpa.cpl"
        "NSLOOKUP Command"                                = "nslookup"
        "Mouse Settings"                                  = "main.cpl"
        "Microsoft Word"                                  = "winword"
        "Microsoft Windows Repair Disc"                   = "recdisc"
        "Microsoft Registry Server"                       = "regsvr32"
        "Microsoft PowerPoint"                            = "powerpnt"
        "Microsoft Paint"                                 = "mspaint"
        "Microsoft Excel"                                 = "excel"
        "Malware Removal Tool"                            = "mrt"
        "Magnifier"                                       = "magnify"
        "Log out of computer"                             = "logoff"
        "Local Users and Groups"                          = "lusrmgr.msc"
        "Local Security Policy Editor"                    = "secpol.msc"
        "Local Group Policy Editor"                       = "gpedit.msc"
        "Keyboard Properties"                             = "control keyboard"
        "Java Web Start"                                  = "javaws"
        "Fonts Folder"                                    = "fonts"
        "Folder Options"                                  = "control folders"
        "File History"                                    = "filehistory"
        "File Explorer"                                   = "explorer"
        "File Explorer Options"                           = "control folders"
        "Event Viewer"                                    = "eventvwr.msc"
        "Ease of Access Center"                           = "control access.cpl"
        "Diskpart Command"                                = "diskpart"
        "Disk Manager"                                    = "diskmgmt.msc"
        "DirectX Options"                                 = "dxdiag"
        "DirectX Diagnostic Tool"                         = "dxdiag"
        "Devices and Printers"                            = "control printers"
        "Device Manager"                                  = "devmgmt.msc"
        "Defrag Command"                                  = "defrag"
        "Date and Time"                                   = "timedate.cpl"
        "Control Panel"                                   = "control"
        "Console Root"                                    = "mmc"
        "Computer Management"                             = "compmgmt.msc"
        "Command Prompt"                                  = "cmd"
        "Clean Disk Manager"                              = "cleanmgr"
        "Check Disk"                                      = "chkdsk"
        "Check Disk Utility"                              = "chkdsk"
        "Character Map"                                   = "charmap"
        "Change Computer Settings"                        = "sysdm.cpl"
        "Change Computer Name"                            = "systempropertiescomputername"
        "Certificate Manager"                             = "certmgr.msc"
        "Calculator"                                      = "calc"
        "Bluetooth File Transfer"                         = "fsquirt"
        "Backup and Restore"                              = "sdctl"
        "Background Services"                             = "services.msc"
        "Authorization Manager"                           = "azman.msc"
        "App Data"                                        = "%AppData%"
        "Advanced User Control Panel"                     = "control userpasswords2"
        "Advanced User Accounts Control Panel"            = "Netplwiz"
        "Advanced System Settings"                        = "systempropertiesadvanced"
        "Administrative Tools"                            = "control admintools"
        "Add a Device"                                    = "devicepairingwizard"
        "Add Hardware Wizard"                             = "hdwwiz"
        "About Windows"                                   = "winver"
        "."                                               = "Open Current User Folder"
        "%UserProfile%"                                   = "User Profile Folder"
        "%Temp%"                                          = "Temporary Folder"
        "Default Audio Device"                            = "mmsys.cpl"
    
    }

    # Check if the user passed a command as a parameter
    if ($Command) {
        # Validate if the command exists in the list
        if ($runCommands.ContainsKey($Command)) {
            Write-Host "You selected: $Command - $($runCommands[$Command])"
            
            # Check if the -y flag was provided
            if ($AutoConfirm) {
                Write-Host "Auto-confirm mode: Running $Command ..."
                Start-Process $Command
            }
            else {
                # Ask for confirmation
                $confirm = Read-Host "Are you sure you want to run this command? (Y/N)"
                if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                    Write-Host "Running $Command ..."
                    Start-Process $Command
                }
                else {
                    Write-Host "Operation canceled."
                }
            }
        }
        else {
            Write-Host "Invalid command: $Command. Please select a valid command."
        }
    }
    else {
        # Display the menu of available commands
        Write-Host "Available commands:"
        foreach ($cmd in $runCommands.Keys) {
            Write-Host "$cmd - $($runCommands[$cmd])"
        }

        # Get user input
        $choice = Read-Host "What command do you want to run?"

        # Validate input
        if ($runCommands.ContainsKey($choice)) {
            Write-Host "You selected: $choice - $($runCommands[$choice])"
            
            # Confirm the action
            $confirm = Read-Host "Are you sure you want to run this command? (Y/N)"
            if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                Write-Host "Running $choice ..."
                Start-Process $choice
            }
            else {
                Write-Host "Operation canceled."
            }
        }
        else {
            Write-Host "Invalid command. Please try again."
        }
    }
}

# Example usage:
# To run interactively:
# Show-RunCommandsMenu

# To run a specific command with auto-confirmation:
# Show-RunCommandsMenu -Command winver -AutoConfirm



