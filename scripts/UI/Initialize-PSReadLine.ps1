function Initialize-PSReadLine {
    [CmdletBinding()]
    param()

    # Check if PSReadLine is available
    if (-not (Get-Module -Name PSReadLine)) {
        Write-Warning "PSReadLine module not found. Attempting to install..."
        try {
            Install-Module -Name PSReadLine -Force -AllowClobber -Scope CurrentUser
        } catch {
            Write-Error "Failed to install PSReadLine: $_"
            return
        }
    }

    # Configure PSReadLine options
    try {
        # Set prediction source to History
        Set-PSReadLineOption -PredictionSource History

        # Enable ListView style predictions
        Set-PSReadLineOption -PredictionViewStyle ListView

        # Set Windows edit mode
        Set-PSReadLineOption -EditMode Windows

        # Configure key handlers
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Tab -Function Complete

        # Set colors for better visibility
        Set-PSReadLineOption -Colors @{
            Command            = 'Yellow'
            Parameter         = 'DarkCyan'
            Operator         = 'DarkGray'
            Variable         = 'Green'
            String           = 'DarkYellow'
            Comment          = 'DarkGreen'
            InlinePrediction = 'DarkGray'
        }

        Write-Verbose "PSReadLine configuration completed successfully"
    } catch {
        Write-Error "Failed to configure PSReadLine: $_"
    }
}

# Initialize PSReadLine when the script is loaded
Initialize-PSReadLine 