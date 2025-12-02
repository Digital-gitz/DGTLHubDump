function Set-GitHubRepoVisibility {
    <#
    .SYNOPSIS
    Toggles a GitHub repository between private and public visibility.

    .DESCRIPTION
    This function uses the GitHub CLI to change repository visibility. It can either:
    - Toggle the current visibility (private -> public, public -> private)
    - Set a specific visibility state

    .PARAMETER Owner
    The GitHub username or organization that owns the repository

    .PARAMETER Repo
    The repository name

    .PARAMETER Visibility
    Optional. Specify 'public' or 'private' to set explicit visibility.
    If not specified, the function will toggle the current visibility.

    .PARAMETER Token
    Optional. GitHub personal access token. If not provided, will use gh CLI authentication.

    .EXAMPLE
    Set-GitHubRepoVisibility -Owner "myusername" -Repo "myrepo"
    Toggles the visibility of myusername/myrepo

    .EXAMPLE
    Set-GitHubRepoVisibility -Owner "myusername" -Repo "myrepo" -Visibility "public"
    Makes myusername/myrepo public

    .EXAMPLE
    Set-GitHubRepoVisibility -Owner "myusername" -Repo "myrepo" -Visibility "private"
    Makes myusername/myrepo private
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,

        [Parameter(Mandatory = $true)]
        [string]$Repo,

        [Parameter(Mandatory = $false)]
        [ValidateSet("public", "private")]
        [string]$Visibility,

        [Parameter(Mandatory = $false)]
        [string]$Token
    )

    # Check if GitHub CLI is installed
    try {
        $ghVersion = & gh --version 2>$null
        if (-not $ghVersion) {
            throw
        }
        Write-Verbose "GitHub CLI found: $($ghVersion | Select-Object -First 1)"
    }
    catch {
        Write-Error "GitHub CLI (gh) is not installed or not in PATH. Please install it from https://cli.github.com/"
        return
    }

    # Set up authentication if token is provided
    if ($Token) {
        $env:GITHUB_TOKEN = $Token
    }
    
    # Check if user is authenticated
    try {
        # $authStatus = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Not authenticated with GitHub CLI. Run 'gh auth login' or provide a token."
            return
        }
    }
    catch {
        Write-Error "Authentication check failed. Please authenticate with GitHub CLI."
        return
    }
    
    $repoFullName = "$Owner/$Repo"
    
    try {
        # Get current repository information
        Write-Verbose "Getting current repository information for $repoFullName"
        $repoInfo = gh repo view $repoFullName --json visibility | ConvertFrom-Json
        $currentVisibility = $repoInfo.visibility.ToLower()
        
        Write-Host "Current visibility of ${repoFullName}: $currentVisibility"
        
        # Determine target visibility
        if ($Visibility) {
            $targetVisibility = $Visibility.ToLower()
            if ($currentVisibility -eq $targetVisibility) {
                Write-Host "Repository $repoFullName is already $targetVisibility"
                return
            }
        }
        else {
            # Toggle visibility
            $targetVisibility = if ($currentVisibility -eq "private") { "public" } else { "private" }
        }
        
        # Confirm the change
        $confirmation = Read-Host "Change $repoFullName from $currentVisibility to $targetVisibility? (y/N)"
        if ($confirmation -notmatch '^[Yy]') {
            Write-Host "Operation cancelled."
            return
        }
        
        # Apply the visibility change
        Write-Host "Changing $repoFullName visibility to $targetVisibility..."
        
        if ($targetVisibility -eq "private") {
            gh repo edit $repoFullName --visibility private --accept-visibility-change-consequences
        }
        else {
            gh repo edit $repoFullName --visibility public --accept-visibility-change-consequences
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully changed $repoFullName to $targetVisibility" -ForegroundColor Green
        }
        else {
            Write-Error "Failed to change repository visibility"
        }
    }
    catch {
        Write-Error "Error processing repository $repoFullName : $($_.Exception.Message)"
    }
    finally {
        # Clean up token from environment if we set it
        if ($Token) {
            Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
        }
    }
}

# Export the function
if ($MyInvocation.InvocationName -eq '.') {
    # Dot-sourced, do not export
}
else {
    Export-ModuleMember -Function Set-GitHubRepoVisibility
}