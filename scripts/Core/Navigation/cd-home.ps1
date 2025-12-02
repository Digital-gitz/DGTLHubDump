<#
.SYNOPSIS
	Sets the working directory to the user's home folder
.DESCRIPTION
	This PowerShell script changes the working directory to the user's home directory.
.EXAMPLE
	PS> ./cd-home.ps1
	📂C:\Users\Markus entered (has 4 files and 7 subfolders)
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

try {
    if (-not(Test-Path "~" -pathType container)) { throw "No home directory at $path" }
    $path = Resolve-Path "~"
    Set-Location "$path"
    $files = Get-ChildItem $path -attributes !Directory
    $folders = Get-ChildItem $path -attributes Directory
    "📂$path entered (has $($files.Count) files and $($folders.Count) subfolders)"
    exit 0 # success
}
catch {
    "⚠️ Error: $($Error[0])"
    exit 1
}