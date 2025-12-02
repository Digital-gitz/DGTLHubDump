# Bring Visual Studio Code to the foreground
$windowTitle = "*Visual Studio Code*"  # Partial title of the VSCode window
$processName = "Code"                 # Process name for VSCode

# Get the process by name
$process = Get-Process | Where-Object { $_.ProcessName -eq $processName }

if ($process) {
    # Get the main window handle
    $hwnd = $process.MainWindowHandle

    if ($hwnd -ne 0) {
        # Bring the window to the foreground
        [void][System.Runtime.InteropServices.Marshal]::PtrToStructure(
            [System.Runtime.InteropServices.Marshal]::GetType("System.IntPtr"),
            $hwnd
        )
        [void][System.Windows.Forms.SendKeys]::SendWait("%{TAB}")
        [void][System.Windows.Forms.SendKeys]::SendWait("%{TAB}")
    } else {
        Write-Host "Window handle not found."
    }
} else {
    Write-Host "Process not found."
}