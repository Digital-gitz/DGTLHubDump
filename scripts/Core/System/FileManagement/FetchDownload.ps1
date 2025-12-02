<#
.SYNOPSIS
    Downloads a file from a URL to the Desktop.
.DESCRIPTION
    Downloads a file from the specified URL to the user's Desktop. Optionally, can execute the file after download.
.EXAMPLE
    Download-File -Url "https://example.com/file.zip"
.EXAMPLE
    Download-AndRunFile -Url "https://example.com/setup.exe"
#>

function Download_File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,
        [Parameter(Mandatory = $false)]
        [string]$DestinationPath
    )
    
    try {
        if ($Url -notmatch '^(https?|ftp)://') {
            Write-Error "Invalid URL: $Url. Please provide a valid http, https, or ftp URL."
            return
        }

        $desktopPath = [Environment]::GetFolderPath('Desktop')
        $fileName = [System.IO.Path]::GetFileName($Url)
        $outputPath = if ($DestinationPath) { $DestinationPath } else { [System.IO.Path]::Combine($desktopPath, $fileName) }

        if (Test-Path $outputPath) {
            Write-Warning "File already exists at $outputPath. Overwriting."
        }

        Write-Host "Downloading $Url to $outputPath ..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $Url -OutFile $outputPath -ErrorAction Stop
        Write-Host "File downloaded successfully to $outputPath" -ForegroundColor Green
        return $outputPath
    }
    catch {
        Write-Error "Failed to download file: $($_.Exception.Message)"
    }
}

function Download_AndRunFile {
    <#
    .SYNOPSIS
        Downloads a file from a URL to the Desktop and executes it.
    .DESCRIPTION
        Downloads a file from the specified URL to the user's Desktop, then executes it if the download is successful.
    .PARAMETER Url
        The URL of the file to download and execute.
    .EXAMPLE
        Download-AndRunFile -Url "https://example.com/setup.exe"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Url
    )
    try {
        $outputPath = Download-File -Url $Url
        if ($outputPath -and (Test-Path $outputPath)) {
            Write-Host "Executing $outputPath ..." -ForegroundColor Yellow
            Start-Process -FilePath $outputPath
            Write-Host "File executed successfully" -ForegroundColor Green
        }
        else {
            Write-Error "File download failed or file does not exist."
        }
        return $outputPath
    }
    catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
    }
}


