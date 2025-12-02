

function global:ddump {
    try {
        $path = $Config.Paths.DGTLHubDump
        if (Test-Path $path) {
            Set-Location -Path $path -ErrorAction Stop
            Write-Host "Successfully changed directory to: $path" -ForegroundColor Green
        }
        else {
            Write-Host "Error: Directory does not exist at path: $path" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error changing directory: $_" -ForegroundColor Red
    }

    try {
        $null = Invoke-WebRequest -Uri $Config.URLs.GitHub -UseBasicParsing -TimeoutSec 5
        Start-Process $Config.URLs.DGTLHubDumpRepo
        Write-Host "Successfully Opened $($Config.URLs.DGTLHubDumpRepo)"
    }
    catch {
        Write-Warning "Could not connect to GitHub. Please check your internet connection."
    }
}

function global:ghub {
    try {
        $path = $Config.Paths.GitHub
        if (Test-Path $path) {
            Set-Location -Path $path -ErrorAction Stop
            Write-Host "Successfully changed directory to: $path" -ForegroundColor Green
            
            if (Get-Command gh -ErrorAction SilentlyContinue) {
                Write-Host "`nGitHub Repositories:" -ForegroundColor Cyan
                Write-Host "─────────────────────────────" -ForegroundColor DarkGray
                gh repo list --limit 100 | ForEach-Object {
                    $repo = $_ -split '\s+'
                    Write-Host ("{0,-40} {1}" -f $repo[0], $repo[1]) -ForegroundColor Gray
                }
            }
            else {
                Write-Host "GitHub CLI (gh) is not installed. Please install it to list repositories." -ForegroundColor Yellow
                Write-Host "Installation command: winget install GitHub.cli" -ForegroundColor Yellow
            }
            
            Write-Host "`nContents of GitHub directory:" -ForegroundColor Cyan
            Get-ChildItem -Path $path | Format-Table Name, LastWriteTime, Length -AutoSize
        }
        else {
            Write-Host "Error: Directory does not exist at path: $path" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error changing directory: $_" -ForegroundColor Red
    }

    Start-Process $Config.URLs.GitHub
}
# region Obsidian Blogs
function global:cd_blog {
    $path = "C:\Users\Digital_Russkiy\iCloudDrive\iCloud~md~obsidian\Digital_Blog"
    if (Test-Path $path) {
        Set-Location -Path $path
        Write-Host "Changed directory to: $path" -ForegroundColor Green
    }
    else {
        Write-Host "Directory does not exist: $path" -ForegroundColor Red
    }
    $netSite = "a-digital-blog.netlify.app"
    $blogRepoUrl = "https://github.com/Digital-gitz/Digital_Blog"
    Write-Host "Blog repository URL: $blogRepoUrl" -ForegroundColor Cyan
    Start-Process $blogRepoUrl
    Write-Host "the Site to the blog is $netSite"
    Start-Process "msedge.exe" "https://$netSite"
}
function o_blog {
    <#
    .SYNOPSIS
    Navigates to the Hugo Obsidian Blog directory.

    .DESCRIPTION
    Changes the current directory to the Hugo Obsidian Blog folder located at:
    C:\Users\Digital_Russkiy\iCloudDrive\iCloud~md~obsidian\HugoPage

    .EXAMPLE
    cd_blog
    #>
    $blogPath = "C:\Users\Digital_Russkiy\iCloudDrive\iCloud~md~obsidian\HugoPage"
    $Hugopage = "https://github.com/Digital-gitz/HugoPage"
    $blgUrlGHhost = "https://digital-gitz.github.io/HugoPage/"
    if (Test-Path $blogPath) {
        Set-Location $blogPath
        Write-Host "Navigated to Hugo Obsidian Blog directory:" -ForegroundColor Blue
        Write-Host $blogPath -ForegroundColor Cyan
        Write-Host "The path to the repository is" -ForegroundColor Blue 
        Write-Host $Hugopage -ForegroundColor Cyan
        Write-Host "you can visit the Site here:" -ForegroundColor Blue 
        Write-Host $blgUrlGHhost -ForegroundColor Cyan
    }
    else {
        Write-Host "Blog directory not found: $blogPath" -ForegroundColor Red
    }
    Write-Host "hugo server -D" -ForegroundColor Green -NoNewline
    Write-Host " - Will start the Development server" -ForegroundColor Gray 
    Write-Host "hugo new content <directiory/tofile.md>" -ForegroundColor Green -NoNewline
    Write-Host " - will crate a new page" -ForegroundColor Gray
    Write-Host "hugo server --buildDrafts" -ForegroundColor Green -NoNewline
    Write-Host " - Will build the draft content" -ForegroundColor Gray 
}
#region End