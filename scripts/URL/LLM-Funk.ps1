Write-Host "Loading URL-Funk.ps1..." -ForegroundColor Green

if (-not (Get-Command -Name Write-Log -ErrorAction SilentlyContinue)) {
    function Write-Log {
        param($Message, $Level = 'Info')
        Write-Host "[URL-Funk.ps1] [$Level] $Message" -ForegroundColor Yellow
    }
}

Write-Log "Defining Open-LLMChat function..." -Level 'Info'

$script:functionDefined = $false

# Define URLs first
$script:OpenLLMUrls = @(
    "https://chat.openai.com/",
    "https://claude.ai/new",
    "https://x.com/i/grok",
    "https://you.com/",
    "https://pi.ai/",
    "https://chatgpt.com/",
    "https://chat.openai.com/",
    "https://claude.ai/new",
    "https://gemini.google.com/app?hl=en-GB",
    "https://chat.deepseek.com/",
    "https://www.perplexity.ai",
    "https://github.com/copilot"
)

# Define the function in global scope
function global:Open-LLMChat {
    [CmdletBinding()]
    param(
        [switch]$ShowProgress
    )
    
    Write-Host "`n🌐 Opening LLM Chat Services..." -ForegroundColor Cyan
    Write-Host "─────────────────────────────" -ForegroundColor DarkGray

    # Create a runspace pool for parallel processing
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, 10)
    $runspacePool.Open()
    $runspaces = New-Object System.Collections.ArrayList
    $failedUrls = New-Object System.Collections.ArrayList

    # Create a script block for opening URLs
    $scriptBlock = {
        param($url)
        try {
            Start-Process $url -WindowStyle Minimized
            return @{ Success = $true; Url = $url }
        }
        catch {
            return @{ Success = $false; Url = $url; Error = $_.Exception.Message }
        }
    }

    # Start all URL openings in parallel
    foreach ($url in $script:OpenLLMUrls) {
        $runspace = [powershell]::Create().AddScript($scriptBlock).AddArgument($url)
        $runspace.RunspacePool = $runspacePool
        $runspaces.Add(@{
                Runspace = $runspace
                Handle   = $runspace.BeginInvoke()
                Url      = $url
            }) | Out-Null
    }

    # Process results as they complete
    $completed = 0
    foreach ($runspace in $runspaces) {
        $result = $runspace.Runspace.EndInvoke($runspace.Handle)
        $completed++
        
        if ($ShowProgress) {
            $percentComplete = ($completed / $script:OpenLLMUrls.Count) * 100
            Write-Progress -Activity "Opening LLM Services" -Status "$($runspace.Url)" -PercentComplete $percentComplete
        }

        if ($result.Success) {
            Write-Host "✓ $($runspace.Url)" -ForegroundColor Green
        }
        else {
            Write-Host "✗ Failed to open $($runspace.Url)" -ForegroundColor Red
            $failedUrls.Add($runspace.Url) | Out-Null
        }

        $runspace.Runspace.Dispose()
    }

    # Cleanup
    $runspacePool.Close()
    $runspacePool.Dispose()

    if ($ShowProgress) {
        Write-Progress -Activity "Opening LLM Services" -Completed
    }

    Write-Host "─────────────────────────────" -ForegroundColor DarkGray
    if ($failedUrls.Count -eq 0) {
        Write-Host "✨ All LLM services opened successfully!" -ForegroundColor Green
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
    Write-Log "Function Open-LLMChat defined successfully" -Level 'Success'
}
else {
    Write-Log "Function Open-LLMChat was already defined" -Level 'Info'
}

# Create an alias for easier access
if (-not (Get-Alias -Name llm -ErrorAction SilentlyContinue)) {
    New-Alias -Name llm -Value Open-LLMChat -Scope Global -Force
}

function global:chatgpt { 
    Write-Host "Opening ChatGPT..." -ForegroundColor Cyan
    Start-Process "https://chatgpt.com/"
}
function global:claude { 
    Write-Host "Opening Claude..." -ForegroundColor Cyan
    Start-Process "https://claude.ai/new"
}
function global:gemini_url {
    Write-Host "Opening Gemini..." -ForegroundColor Cyan 
    Start-Process "https://gemini.google.com/app?hl=en-GB"
}
function global:deepseek {
    Write-Host "Opening DeepSeek..." -ForegroundColor Cyan
    Start-Process "https://chat.deepseek.com/"
}
function global:grok {
    Write-Host "Opening Grok..." -ForegroundColor Cyan
    Start-Process "https://x.com/i/grok"
}
function global:you {
    Write-Host "Opening You..." -ForegroundColor Cyan
    Start-Process "https://you.com/"
}
function global:pi {
    Write-Host "Opening Pi..." -ForegroundColor Cyan
    Start-Process "https://pi.ai/"
}
function global:gally {
    Write-Host "Opening PowerShell Gallery..." -ForegroundColor Cyan
    Start-Process "https://www.powershellgallery.com/"
}
function global:mudlist {
    Write-Host "Opening Grapevine..." -ForegroundColor Cyan
    Start-Process "https://grapevine.haus/"
}
function global:discord {
    Write-Host "Opening Discord..." -ForegroundColor Cyan
    Start-Process "https://discord.com/"
}
function global:github {
    Write-Host "Opening GitHub..." -ForegroundColor Cyan
    Start-Process "https://github.com/"
}
function global:youtube {
    Write-Host "Opening YouTube..." -ForegroundColor Cyan
    Start-Process "https://youtube.com/"
}
function global:reddit {
    Write-Host "Opening Reddit..." -ForegroundColor Cyan
    Start-Process "https://reddit.com/"
}
function global:twitter {
    Write-Host "Opening Twitter..." -ForegroundColor Cyan
    Start-Process "https://twitter.com/"
}
function global:twitch {
    Write-Host "Opening Twitch..." -ForegroundColor Cyan
    Start-Process "https://twitch.tv/"
}
function global:tiktok {
    Write-Host "Opening TikTok..." -ForegroundColor Cyan
    Start-Process "https://tiktok.com/"
}
function global:instagram {
    Write-Host "Opening Instagram..." -ForegroundColor Cyan
    Start-Process "https://instagram.com/"
}
function global:facebook {
    Write-Host "Opening Facebook..." -ForegroundColor Cyan
    Start-Process "https://facebook.com/"
}
function global:linkedin {
    Write-Host "Opening LinkedIn..." -ForegroundColor Cyan
    Start-Process "https://linkedin.com/"
}
function global:patreon {
    Write-Host "Opening Patreon..." -ForegroundColor Cyan
    Start-Process "https://patreon.com/"
}
function global:steam {
    Write-Host "Opening Steam..." -ForegroundColor Cyan
    Start-Process "https://store.steampowered.com/"
}
function global:anythingworld {
    Write-Host "Opening Anything World..." -ForegroundColor Cyan
    Start-Process "https://anything.world/"
}
function global:nintendo {
    Write-Host "Opening Nintendo..." -ForegroundColor Cyan
    Start-Process "https://nintendo.com/"
}
function global:playstation {
    Write-Host "Opening PlayStation..." -ForegroundColor Cyan
    Start-Process "https://playstation.com/"
}
function global:xbox {
    Write-Host "Opening Xbox..." -ForegroundColor Cyan
    Start-Process "https://xbox.com/"
}
function global:epicgames {
    Write-Host "Opening Epic Games..." -ForegroundColor Cyan
    Start-Process "https://epicgames.com/"
}
function global:ea {
    Write-Host "Opening EA..." -ForegroundColor Cyan
    Start-Process "https://ea.com/"
}
function global:gmail {
    Write-Host "Opening Gmail..." -ForegroundColor Cyan
    Start-Process "https://mail.google.com/"
}
function global:outlook {
    Write-Host "Opening Outlook..." -ForegroundColor Cyan
    Start-Process "https://outlook.com/"
}
function global:yahoo {
    Write-Host "Opening Yahoo Mail..." -ForegroundColor Cyan
    Start-Process "https://mail.yahoo.com/"
}

function global:tutanota {
    Write-Host "Opening Tutanota..." -ForegroundColor Cyan
    Start-Process "https://tutanota.com/"
}
function global:perplexity {
    Write-Host "`n🤖 Opening Perplexity AI..." -ForegroundColor Cyan
    Start-Process "https://www.perplexity.ai"
}
function global:retrodiffusion {
    Write-Host "Opening Retrodiffusion..." -ForegroundColor Cyan
    Start-Process "https://www.retrodiffusion.ai/app"
}
function global:copilot {
    Write-Host "Opening Copilot..." -ForegroundColor Cyan
    Start-Process "https://github.com/copilot"
}

function global:list_llm {
    Write-Host "URL-Funk.ps1 loaded successfully!" -ForegroundColor Green
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
    Write-Host "Use 'copilot' to open Copilot" -ForegroundColor Blue
    Write-Host "`nUse the command in parentheses to open the respective service" -ForegroundColor Green
}
