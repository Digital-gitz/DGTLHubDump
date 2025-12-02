# Load required assemblies
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WindowPosition {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
}
"@

# Launch your application
Start-Process "notepad.exe"

# Give it time to start
Start-Sleep -Seconds 1

# Find the window (replace "Notepad" with your application's window title)
$windowHandle = [WindowPosition]::FindWindow($null, "Notepad")

# Set window position (x=200, y=200, width=800, height=600)
# 0x0004 = SWP_NOZORDER, 0x0002 = SWP_NOMOVE, 0x0001 = SWP_NOSIZE
[WindowPosition]::SetWindowPos($windowHandle, [IntPtr]::Zero, 200, 200, 800, 600, 0x0004)