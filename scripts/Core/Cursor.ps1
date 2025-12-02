Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WindowHelper {
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@

$processName = "Cursor"  # Replace with your actual process name
$processes = Get-Process $processName -ErrorAction SilentlyContinue

if (-not $processes) {
    Start-Process "C:\Users\Digital_Russkiy\AppData\Local\Programs\cursor\Cursor.exe"  # Replace with actual path
    Start-Sleep -Milliseconds 500
    $processes = Get-Process $processName
}

# Get the first process if multiple are found
$process = $processes | Select-Object -First 1

# Bring window to front
if ($process.MainWindowHandle) {
    [WindowHelper]::ShowWindow($process.MainWindowHandle, 9)  # 9 = SW_RESTORE
    [WindowHelper]::SetForegroundWindow($process.MainWindowHandle)
}