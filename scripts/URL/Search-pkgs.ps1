function Search-GoPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,
        
        [switch]$OpenInBrowser
    )
    
    try {
        Write-Host "Searching Go packages for: $SearchTerm" -ForegroundColor Cyan
        
        $searchUrl = "https://pkg.go.dev/search?q=$([System.Web.HttpUtility]::UrlEncode($SearchTerm))"
        
        if ($OpenInBrowser) {
            Write-Host "Opening search results in browser..." -ForegroundColor Green
            Start-Process $searchUrl
        }
        else {
            Write-Host "Search URL: $searchUrl" -ForegroundColor Yellow
            Write-Host "Use -OpenInBrowser switch to open results directly in your browser" -ForegroundColor Gray
        }
        
        Write-Host "Search completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error searching Go packages: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-PyPiPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,

        [switch]$OpenInBrowser
    )

    try {
        Write-Host "Searching PyPI packages for: $SearchTerm" -ForegroundColor Cyan

        $searchUrl = "https://pypi.org/search/?q=$([System.Web.HttpUtility]::UrlEncode($SearchTerm))"

        if ($OpenInBrowser) {
            Write-Host "Opening search results in browser..." -ForegroundColor Green
            Start-Process $searchUrl
        }
        else {
            Write-Host "Search URL: $searchUrl" -ForegroundColor Yellow
            Write-Host "Use -OpenInBrowser switch to open results directly in your browser" -ForegroundColor Gray
        }

        Write-Host "Search completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error searching PyPI packages: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-NpmPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,

        [switch]$OpenInBrowser
    )

    try {
        Write-Host "Searching npm packages for: $SearchTerm" -ForegroundColor Cyan

        $searchUrl = "https://www.npmjs.com/search?q=$([System.Web.HttpUtility]::UrlEncode($SearchTerm))"

        if ($OpenInBrowser) {
            Write-Host "Opening search results in browser..." -ForegroundColor Green
            Start-Process $searchUrl
        }
        else {
            Write-Host "Search URL: $searchUrl" -ForegroundColor Yellow
            Write-Host "Use -OpenInBrowser switch to open results directly in your browser" -ForegroundColor Gray
        }

        Write-Host "Search completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error searching npm packages: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-CargoPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,

        [switch]$OpenInBrowser
    )

    try {
        Write-Host "Searching Cargo (Rust) packages for: $SearchTerm" -ForegroundColor Cyan

        $searchUrl = "https://crates.io/search?q=$([System.Web.HttpUtility]::UrlEncode($SearchTerm))"

        if ($OpenInBrowser) {
            Write-Host "Opening search results in browser..." -ForegroundColor Green
            Start-Process $searchUrl
        }
        else {
            Write-Host "Search URL: $searchUrl" -ForegroundColor Yellow
            Write-Host "Use -OpenInBrowser switch to open results directly in your browser" -ForegroundColor Gray
        }

        Write-Host "Search completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error searching Cargo packages: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Search-GitHubRepositories {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,

        [switch]$OpenInBrowser
    )

    try {
        Write-Host "Searching GitHub repositories for: $SearchTerm" -ForegroundColor Cyan

        $searchUrl = "https://github.com/search?q=$([System.Web.HttpUtility]::UrlEncode($SearchTerm))&type=repositories"

        if ($OpenInBrowser) {
            Write-Host "Opening search results in browser..." -ForegroundColor Green
            Start-Process $searchUrl
        }
        else {
            Write-Host "Search URL: $searchUrl" -ForegroundColor Yellow
            Write-Host "Use -OpenInBrowser switch to open results directly in your browser" -ForegroundColor Gray
        }

        Write-Host "Search completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error searching GitHub repositories: $($_.Exception.Message)" -ForegroundColor Red
    }
}
