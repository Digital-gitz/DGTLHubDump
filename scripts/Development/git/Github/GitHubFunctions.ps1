# GitHub.ps1
#
# Set a new token
# Set-GitHubToken -Token "ghp_yourTokenHere" -Store

# . "GitHubVisibility.ps1"
# Create aliases for GitHub functions are at root script.
#Set-Alias -Name ghs -Value Search-GitHubRepos
#Set-Alias -Name ghl -Value Get-GitHubRepoList
# Set-Alias -Name ghmr -Value Get-GitHubRepoView
#Set-Alias -Name ghc -Value Get-GitHubRepoclone
# Get token info
# gh-tokeninfo

# Create a new token in browser
# gh-newtoken

# GitHub Token Management


function global:Get-GithubFunctionList {
    <#
    .SYNOPSIS
        Displays the contents of the Github FunctionList.txt file.
    .DESCRIPTION
        Reads and prints the contents of FunctionList.txt that describes directory and URL helper functions for Github & Github-related navigation.
    .EXAMPLE
        Get-GithubFunctionList
    #>
    $functionListPath = Join-Path -Path $PSScriptRoot -ChildPath "FunctionList.txt"
    if (Test-Path $functionListPath) {
        Write-Host "`nGitHub Function List:" -ForegroundColor Cyan
        Write-Host "─────────────────────────────" -ForegroundColor DarkGray
        Get-Content $functionListPath | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
        Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    }
    else {
        Write-Host "Could not find FunctionList.txt in $PSScriptRoot" -ForegroundColor Red
    }
}

function Set-GitHubToken {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Token,
        [switch]$Store
    )
    $env:GH_TOKEN = $Token
    if ($Store) {
        $secureToken = ConvertTo-SecureString $Token -AsPlainText -Force
        New-StoredCredential -Target "GitHub:CLI" -UserName $env:USERNAME -Password $secureToken -Persist LocalComputer
    }
}


function Open-GitHubRepo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepoName
    )
    
    $repoUrl = "https://github.com/$RepoName"
    try {
        Start-Process $repoUrl
        Write-Host "Opened GitHub repository: $RepoName" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to open GitHub repository: $_"
    }
}

function Update-AllRepos {
    $currentLocation = Get-Location
    Get-ChildItem -Directory | ForEach-Object {
        Set-Location $_
        if (Test-Path .git) {
            Write-Host "Updating $($_.Name)..." -ForegroundColor Cyan
            git pull
        }
        Set-Location $currentLocation
    }
}

function New-GitHubRepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$RepoName,
        [switch]$Private,
        [string]$Description
    )
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed. Please install it first."
        return
    }
    
    if (-not $RepoName) {
        $RepoName = Read-Host -Prompt "Enter the repository name"
    }
    
    if ([string]::IsNullOrWhiteSpace($RepoName)) {
        Write-Error "Repository name cannot be empty."
        return
    }
    
    $visibility = if ($Private) { "--private" } else { "--public" }
    $descParam = if ($Description) { "--description `"$Description`"" } else { "" }
    
    try {
        $result = gh repo create $RepoName $visibility $descParam -y
        Write-Host "Repository '$RepoName' created successfully." -ForegroundColor Green
        return $result
    }
    catch {
        Write-Error "Failed to create repository: $_"
    }
}
function Search-for-GitHubRepositories {
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


# GitHub helper functions
function Search-GitHubRepos { 
    [CmdletBinding()]
    param([string]$Query)
    gh search repos $Query 
}

function Get-GitHubRepoList { 
    [CmdletBinding()]
    param([switch]$All)
    if ($All) {
        gh repo list --limit 1000
    }
    else {
        gh repo list
    }
}

function Get-GitHubRepoView { 
    [CmdletBinding()]
    param([string]$Repo)
    gh repo view $Repo 
}

function gitstatus {
    git status -s
}

function Get-GitHubRepoclone {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepoName
    )
}
function Git_QuickPush {
    try {
        Write-Host "Running: git add ." -ForegroundColor Cyan
        git add .
        if ($LASTEXITCODE -ne 0) {
            Write-Host "git add failed." -ForegroundColor Red
            return
        }

        Write-Host "Running: git commit -m 'Updating...'" -ForegroundColor Cyan
        git commit -m "Updating..."
        if ($LASTEXITCODE -ne 0) {
            Write-Host "git commit failed or nothing to commit." -ForegroundColor Yellow
            return
        }

        Write-Host "Running: git push" -ForegroundColor Cyan
        git push
        if ($LASTEXITCODE -ne 0) {
            Write-Host "git push failed." -ForegroundColor Red
            return
        }

        Write-Host "Git add, commit, and push completed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during Git-QuickPush: $($_.Exception.Message)" -ForegroundColor Red
    }
}
#region GitHub Repository Creation
function global:gh_create_repo {
    param(
        [string]$RepoName = "",
        [string]$Visibility = ""
    )
    
    # Get repository name if not provided
    if ([string]::IsNullOrWhiteSpace($RepoName)) {
        $RepoName = Read-Host "Enter the name for your repository"
    }
    
    # Validate repository name
    if ([string]::IsNullOrWhiteSpace($RepoName)) {
        Write-Host "Repository name cannot be empty!" -ForegroundColor Red
        return
    }
    
    # Get visibility preference if not provided
    if ([string]::IsNullOrWhiteSpace($Visibility)) {
        do {
            $Visibility = Read-Host "Do you want the repository to be public or private? (public/private)"
            $Visibility = $Visibility.ToLower()
        } while ($Visibility -notin @("public", "private"))
    }
    
    # Validate visibility
    if ($Visibility -notin @("public", "private")) {
        Write-Host "Visibility must be either 'public' or 'private'!" -ForegroundColor Red
        return
    }

    try {
        Write-Host "Creating GitHub repository: $RepoName ($Visibility)" -ForegroundColor Cyan

        # Try to detect if this directory is already a git repo
        $isGitRepo = Test-Path .git

        # If not a git repo, initialize one
        if (-not $isGitRepo) {
            Write-Host "Initializing a new git repository in the current directory..." -ForegroundColor Yellow
            git init
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Failed to initialize git repository." -ForegroundColor Red
                return
            }
        }

        # Remove any existing 'origin' remote to avoid remote add errors
        $existingRemote = git remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Removing existing 'origin' remote to avoid conflicts..." -ForegroundColor Yellow
            git remote remove origin
        }

        # Create the repository on GitHub without --push/--source (to avoid remote add error)
        $createCommand = "gh repo create $RepoName --$Visibility --confirm"
        Write-Host "Executing: $createCommand" -ForegroundColor Gray
        Invoke-Expression $createCommand

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to create repository on GitHub. Exit code: $LASTEXITCODE" -ForegroundColor Red
            return
        }

        # Add the new GitHub repo as origin
        $user = gh api user --jq ".login" 2>$null
        if (-not $user) {
            $user = $env:GITHUB_USER
        }
        if (-not $user) {
            $user = Read-Host "Enter your GitHub username"
        }
        $remoteUrl = "https://github.com/$user/$RepoName.git"
        Write-Host "Adding remote 'origin': $remoteUrl" -ForegroundColor Gray
        git remote add origin $remoteUrl

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to add remote 'origin'. You may need to add it manually." -ForegroundColor Red
        }
        else {
            Write-Host "Remote 'origin' added successfully." -ForegroundColor Green
        }

        Write-Host "Repository '$RepoName' created successfully!" -ForegroundColor Green
        Write-Host "Repository is $Visibility" -ForegroundColor Green
        Write-Host "You can now push your code with: git push -u origin main" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error creating repository: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function GitHubRepos {
    <#
    .SYNOPSIS
    Opens your GitHub repositories page in the default browser.

    .DESCRIPTION
    Navigates to https://github.com/Digital-gitz?tab=repositories in your default web browser.

    .EXAMPLE
    Open-MyGitHubRepositories
    #>
    $url = "https://github.com/Digital-gitz?tab=repositories"
    try {
        Write-Host "Opening your GitHub repositories page..." -ForegroundColor Cyan
        Start-Process $url
    }
    catch {
        Write-Host "Failed to open the GitHub repositories page: $($_.Exception.Message)" -ForegroundColor Red
    }
}

#region Index

Get-Content $MyInvocation.MyCommand.Path | ForEach-Object {
    if ($_ -match '^\s*function\s+([^\s{(]+)') {
        Write-Host $Matches[1]
    }
}


function Remove-GitHubRepo {
    <#
    .SYNOPSIS
        Deletes a GitHub repository for the authenticated user.
    .DESCRIPTION
        Uses the GitHub CLI (`gh`) to delete a repository by name. Prompts for confirmation.
    .PARAMETER RepoName
        Name of the repository to delete (e.g., "MyRepo" or "Digital-gitz/MyRepo").
    .EXAMPLE
        Remove-GitHubRepo -RepoName "MyRepo"
    .EXAMPLE
        Remove-GitHubRepo -RepoName "Digital-gitz/MyRepo"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoName
    )

    # If user didn't supply username as prefix, auto prepend your username
    if ($RepoName -notmatch "/") {
        $user = "Digital-gitz"
        $fullName = "$user/$RepoName"
    }
    else {
        $fullName = $RepoName
    }

    Write-Warning "You are about to delete the repository: $fullName"
    $confirmation = Read-Host "Are you sure you want to delete this repository? This action CANNOT be undone! (y/N)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Deletion cancelled."
        return
    }

    try {
        gh repo delete $fullName --yes
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Repository '$fullName' deleted successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Failed to delete repository '$fullName'. Please check that the repository exists and you have permission." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error deleting repository: $($_.Exception.Message)" -ForegroundColor Red
    }
}


#region End