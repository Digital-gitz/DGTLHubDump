
#region Prompt Configuration
# Initialize Oh My Posh with fallback
try {
    $themeFile = "$env:POSH_THEMES_PATH\agnosterplus.omp.json"
    if (Test-Path $themeFile) {
        oh-my-posh init pwsh --config $themeFile | Invoke-Expression
    }
    else {
        throw "Theme file not found"
    }
}
catch {
    function prompt {
        $lastCommand = Get-History -Count 1
        $lastCommandTime = if ($lastCommand) { 
            $duration = $lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime
            " [$([math]::Round($duration.TotalMilliseconds))ms]"
        }
        else { "" }

        $currentLocation = Get-Location
        $adminIndicator = if ($isAdmin) { "[ADMIN] " } else { "" }
        
        $gitCommand = Get-Command -Name git -ErrorAction SilentlyContinue
        $gitBranch = if ($gitCommand) { 
            $branch = git branch --show-current 2>$null
            if ($branch) { " [$branch]" } else { "" }
        }
        else { "" }

        Write-Host "`n$adminIndicator" -NoNewline -ForegroundColor Red
        Write-Host "PS" -NoNewline -ForegroundColor Blue
        Write-Host "$lastCommandTime" -NoNewline -ForegroundColor DarkGray
        Write-Host " $($currentLocation)" -NoNewline -ForegroundColor Yellow
        Write-Host "$gitBranch" -NoNewline -ForegroundColor Green
        return "`n❯ "
    }
}

#region PSReadLine Configuration
if (Get-Module -Name PSReadLine) {
    try {
        $validPredictionSources = @("None", "History", "Plugin", "HistoryAndPlugin")
        $predictionSource = if ($Config.PSReadLine.PredictionSource -and $validPredictionSources -contains $Config.PSReadLine.PredictionSource) {
            $Config.PSReadLine.PredictionSource
        }
        else {
            "History"
        }
        Set-PSReadLineOption -PredictionSource $predictionSource

        $predictionViewStyle = if ($Config.PSReadLine.PredictionViewStyle) { $Config.PSReadLine.PredictionViewStyle } else { "InlineView" }
        Set-PSReadLineOption -PredictionViewStyle $predictionViewStyle

        Set-PSReadLineOption -EditMode $Config.PSReadLine.EditMode `
            -HistorySaveStyle $Config.PSReadLine.HistorySaveStyle

        if ($Config.PSReadLine.HistorySavePath) {
            Set-PSReadLineOption -HistorySavePath $Config.PSReadLine.HistorySavePath
        }

        Set-PSReadLineOption -Colors $Config.PSReadLine.Colors

        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function AcceptSuggestion
        Set-PSReadLineKeyHandler -Key Alt+Enter -Function AcceptNextSuggestionWord
    }
    catch {
        Write-Warning "Error configuring PSReadLine - $($_.Exception.Message)"
    }
}


