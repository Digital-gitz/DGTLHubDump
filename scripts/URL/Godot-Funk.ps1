Write-Host "Loading Godot-Funk.ps1..." -ForegroundColor Green

if (-not (Get-Command -Name Write-Log -ErrorAction SilentlyContinue)) {
    function Write-Log {
        param($Message, $Level = 'Info')
        Write-Host "[Godot-Funk.ps1] [$Level] $Message" -ForegroundColor Yellow
    }
}

Write-Log "Defining Open-Godot function..." -Level 'Info'

$script:functionDefined = $false

# Define URLs first
$script:GodotUrls = @(
    "https://godotengine.org/",
    "https://docs.godotengine.org/en/stable/",
    "https://github.com/orgs/godotengine/repositories"
)

# Define the function in global scope
function global:________ {
    [CmdletBinding()]
    param(
        [switch]$ShowProgress
    )
    
    Write-Host "`n🌐 Opening ________..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray

    $total = $script:________Urls.Count
    $current = 0
    $failedUrls = @()

    foreach ($url in $script:________Urls) {
        $current++
        $cleanUrl = $url -replace '^https?://(www\.)?', '' -replace '\.(com|org|net|io|ai|dev|cloud|app|co|me|us|uk|ru|de|fr|jp|cn|in|br|au|ca|nz|za|kr|nl|pl|it|es|se|dk|no|fi|ie|at|ch|be|pt|gr|cz|hu|ro|sk|ua|il|tr|ae|sa|sg|my|th|vn|id|ph|mx|ar|cl|pe|co|za|eg|ma|ng|ke|za).*$', ''
        
        if ($ShowProgress) {
            $percentComplete = ($current / $total) * 100
            Write-Progress -Activity "Opening ________" -Status "$cleanUrl" -PercentComplete $percentComplete
        }

        try {
            Start-Process $url
            Write-Host "✓ $cleanUrl" -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        }
        catch {
            Write-Host "✗ Failed to open $cleanUrl" -ForegroundColor Red
            $failedUrls += $url
        }
    }

    if ($ShowProgress) {
        Write-Progress -Activity "Opening ________" -Completed
    }

    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    if ($failedUrls.Count -eq 0) {
        Write-Host "✨ All ________ opened successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ Some URLs failed to open:" -ForegroundColor Yellow
        $failedUrls | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Red
        }
    }
    Write-Host
}

if ($script:functionDefined) {
    Write-Log "Function ________ defined successfully" -Level 'Success'
}
else {
    Write-Log "Function ________ was already defined" -Level 'Info'
}

# Create an alias for easier access
if (-not (Get-Alias -Name ___ -ErrorAction SilentlyContinue)) {
    New-Alias -Name ___ -Value Open-______ -Scope Global -Force
}

function global:________ { 
    Write-Host "Opening _____..." -ForegroundColor Cyan
    Start-Process ""
}

function global:________ { Start-Process "edge://wallet/passwords?source=assetsSettingsPasswords%22}" }
Write-Host "________-Funk.ps1 loaded successfully!" -ForegroundColor Green
Write-Host "Use 'Open-LLMChat' or 'llm' to open all LLM chat URLs" -ForegroundColor Cyan
Write-Host "Use 'chat-gpt' to open ChatGPT" -ForegroundColor Blue
Write-Host "Use 'claude' to open Claude" -ForegroundColor Blue
Write-Host "Use 'gemini' to open Gemini" -ForegroundColor Blue
Write-Host "Use 'deepseek' to open DeepSeek" -ForegroundColor Blue
Write-Host "Use 'grok' to open Grok" -ForegroundColor Blue
Write-Host "Use 'you' to open You" -ForegroundColor Blue
Write-Host "Use 'pi' to open Pi" -ForegroundColor Blue
Write-Host "Use 'gally' to open PowerShell Gallery" -ForegroundColor Blue
Write-Host "Use 'perplexity' to open Perplexity AI" -ForegroundColor Blue




