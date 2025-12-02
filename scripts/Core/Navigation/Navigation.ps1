
# Open current directory in Explorer
function Open-ExplorerHere {
    Start-Process explorer.exe .
}

$script:CommonPaths = @{
    Scripts = Join-Path (Split-Path $PROFILE) "Scripts"
}

# Navigate to a predefined location
function goto {
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("home", "root", "dirps", "downloads", "documents", "pictures", "desktop", "github")]
        [string]$location
    )

    if (-not $PSBoundParameters.ContainsKey('location')) {
        Write-Host "Please specify a location. Valid locations are:" -ForegroundColor Yellow
        $CommonPaths.Keys | ForEach-Object { Write-Host " - $_" }
        return
    }

    if ($CommonPaths.ContainsKey($location)) {
        if (Test-Path $CommonPaths.$location) {
            Set-Location $CommonPaths.$location
            Get-ChildItem
        } else {
            Write-Host "Path not found: $($CommonPaths.$location)" -ForegroundColor Red
        }
    } else {
        Write-Host "Location '$location' is not defined in `$CommonPaths." -ForegroundColor Red
    }
}

# Add tab completion for the goto function
Register-ArgumentCompleter -CommandName goto -ParameterName location -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $CommonPaths.Keys | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_) }
}

# Add a custom path to $CommonPaths
function Add-CommonPath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    if (Test-Path $Path) {
        $CommonPaths[$Name] = $Path
        Write-Host "Path '$Path' added as '$Name'" -ForegroundColor Green
    } else {
        Write-Host "Path '$Path' does not exist. Please provide a valid path." -ForegroundColor Red
    }
}

Write-Output("Navigation UserScript Uploaded...")
#endregion