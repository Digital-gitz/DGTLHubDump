function Install-OrUpdateModule {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        
        [Parameter(Mandatory = $false)]
        [string]$MinimumVersion,
        
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    try {
        # Check if module is installed
        $existingModule = Get-Module -Name $ModuleName -ListAvailable

        # Check if module exists in PowerShell Gallery
        $galleryModule = Find-Module -Name $ModuleName -ErrorAction Stop

        if (-not $existingModule) {
            Write-Host "Module '$ModuleName' is not installed. Installing now..." -ForegroundColor Yellow
            Install-Module -Name $ModuleName -Force:$Force -AllowClobber -Scope CurrentUser
            Write-Host "Module '$ModuleName' has been successfully installed." -ForegroundColor Green
        }
        else {
            $currentVersion = $existingModule.Version
            $latestVersion = $galleryModule.Version

            # If MinimumVersion is specified, check if current version meets requirement
            if ($MinimumVersion) {
                if ([version]$currentVersion -lt [version]$MinimumVersion) {
                    Write-Host "Current version ($currentVersion) is below minimum required version ($MinimumVersion). Updating module..." -ForegroundColor Yellow
                    Update-Module -Name $ModuleName -Force:$Force
                    Write-Host "Module '$ModuleName' has been updated to meet minimum version requirement." -ForegroundColor Green
                }
                else {
                    Write-Host "Module '$ModuleName' meets minimum version requirement ($MinimumVersion)." -ForegroundColor Green
                }
                return
            }

            # Check if update is available
            if ([version]$currentVersion -lt [version]$latestVersion) {
                Write-Host "Update available for '$ModuleName'. Current: $currentVersion, Latest: $latestVersion" -ForegroundColor Yellow
                Update-Module -Name $ModuleName -Force:$Force
                Write-Host "Module '$ModuleName' has been updated to version $latestVersion." -ForegroundColor Green
            }
            else {
                Write-Host "Module '$ModuleName' is up to date (Version: $currentVersion)." -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Error "Error occurred while managing module '$ModuleName': $_"
    }
}
Write-Output("Install-OrUpdateModule UserScript Uploaded...")