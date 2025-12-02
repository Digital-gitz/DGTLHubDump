function nmcal {
    <#
    .SYNOPSIS
        Opens a curated list of interesting websites in your default browser.

    .DESCRIPTION
        This function opens a set of websites that you might find interesting, such as news, tech, art, and learning resources.

    .EXAMPLE
        nmcal
    #>
    $interestSites = @(
        # "https://www.reddit.com/r/interestingasfuck/",
        # "https://www.thisiscolossal.com/",
        # "https://www.atlasobscura.com/",
        # "https://www.producthunt.com/",
        # "https://www.hackaday.com/",
        # "https://www.instructables.com/",
        # "https://www.ted.com/talks",
        # "https://www.boredpanda.com/",
        "https://www.artstation.com/",
        "https://www.deviantart.com/"
        'https://www.pinterest.com/'
    )

    Write-Host "`n🌐 Opening your interest sites..." -ForegroundColor Cyan
    foreach ($site in $interestSites) {
        try {
            Start-Process $site
            Write-Host "✓ $site" -ForegroundColor Green
        }
        catch {
            Write-Host "✗ Failed to open $site" -ForegroundColor Red
        }
    }
    Write-Host "`nDone!" -ForegroundColor Cyan
}
function Show-ArtCommands {
    Write-Host "`n🎨 Art Commands:" -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    $commands = @(
        @{ Name = "nmcal"; Desc = "Open a curated list of interesting websites" }
        @{ Name = "Go-AsepriteDirectory"; Desc = "Open the Aseprite art directory" }
        @{ Name = "Go-PokemonSketchesDirectory"; Desc = "Open the Pokemon Sketches directory" }
        @{ Name = "Search-Sketchfab"; Desc = "Search Sketchfab" }
    )
    $maxCmdLen = ($commands | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
    foreach ($cmd in $commands) {
        $pad = " " * ($maxCmdLen - $cmd.Name.Length + 2)
        Write-Host ("  " + $cmd.Name) -ForegroundColor Green -NoNewline
        Write-Host ($pad + $cmd.Desc) -ForegroundColor Gray
    }
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
}


function Search-Sketchfab {
    param(
        [string]$Search
    )
    if (-not $Search) {
        $Search = Read-Host "Enter your Sketchfab search query"
    }
    if ([string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "No search query provided. Aborting." -ForegroundColor Yellow
        return
    }
    $encodedSearch = [uri]::EscapeDataString($Search)
    $url = "https://sketchfab.com/search?q=$encodedSearch&type=models"
    Write-Host "Opening Sketchfab search for: $Search" -ForegroundColor Cyan
    Start-Process $url
}

function Search-X {
    param(
        [string]$Search
    )
    if (-not $Search) {
        $Search = Read-Host "Enter your X (Twitter) search query"
    }
    if ([string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "No search query provided. Aborting." -ForegroundColor Yellow
        return
    }
    $encodedSearch = [uri]::EscapeDataString($Search)
    $url = "https://twitter.com/search?q=$encodedSearch&src=typed_query"
    Write-Host "Opening X (Twitter) search for: $Search" -ForegroundColor Cyan
    Start-Process $url
}

function Search-Pinterest {
    param(
        [string]$Search
    )
    if (-not $Search) {
        $Search = Read-Host "Enter your Pinterest search query"
    }
    if ([string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "No search query provided. Aborting." -ForegroundColor Yellow
        return
    }
    $encodedSearch = [uri]::EscapeDataString($Search)
    $url = "https://www.pinterest.com/search/pins/?q=$encodedSearch"
    Write-Host "Opening Pinterest search for: $Search" -ForegroundColor Cyan
    Start-Process $url
}

function Search-Facebook {
    param(
        [string]$Search
    )
    if (-not $Search) {
        $Search = Read-Host "Enter your Facebook search query"
    }
    if ([string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "No search query provided. Aborting." -ForegroundColor Yellow
        return
    }
    $encodedSearch = [uri]::EscapeDataString($Search)
    $url = "https://www.facebook.com/search/top/?q=$encodedSearch"
    Write-Host "Opening Facebook search for: $Search" -ForegroundColor Cyan
    Start-Process $url
}

function Search-Google {
    param(
        [string]$Search
    )
    if (-not $Search) {
        $Search = Read-Host "Enter your Google search query"
    }
    if ([string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "No search query provided. Aborting." -ForegroundColor Yellow
        return
    }
    $encodedSearch = [uri]::EscapeDataString($Search)
    $url = "https://www.google.com/search?q=$encodedSearch"
    Write-Host "Opening Google search for: $Search" -ForegroundColor Cyan
    Start-Process $url
}

function Search-Reddit {
    param(
        [string]$Search
    )
    if (-not $Search) {
        $Search = Read-Host "Enter your Reddit search query"
    }
    if ([string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "No search query provided. Aborting." -ForegroundColor Yellow
        return
    }
    $encodedSearch = [uri]::EscapeDataString($Search)
    $url = "https://www.reddit.com/search/?q=$encodedSearch"
    Write-Host "Opening Reddit search for: $Search" -ForegroundColor Cyan
    Start-Process $url
}

function Search-HuggingFace {
    param(
        [string]$Search
    )
    if (-not $Search) {
        $Search = Read-Host "Enter your Hugging Face search query"
    }
    if ([string]::IsNullOrWhiteSpace($Search)) {
        Write-Host "No search query provided. Aborting." -ForegroundColor Yellow
        return
    }
    $encodedSearch = [uri]::EscapeDataString($Search)
    # Hugging Face's main search does not work with ?q=, it uses /search/full-text?q= for full search
    $url = "https://huggingface.co/search/full-text?q=$encodedSearch"
    Write-Host "Opening Hugging Face search for: $Search" -ForegroundColor Cyan
    Start-Process $url
}


function Get-AlphabeticalFileList {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )

    if (-Not (Test-Path -Path $FolderPath -PathType Container)) {
        Write-Error "The path '$FolderPath' does not exist or is not a folder."
        return
    }

    try {
        Get-ChildItem -Path $FolderPath -File |
        Sort-Object -Property Name |
        Select-Object -ExpandProperty Name
    }
    catch {
        Write-Error "Failed to list files: $_"
    }
}
