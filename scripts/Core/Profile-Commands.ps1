function Get-ScriptsFunctions {
    [CmdletBinding()]
    param()
    
    try {
        # Get the Scripts directory path from the profile's location
        $scriptsDir = Join-Path $PSScriptRoot ".." "Scripts"
        Write-Host "Debug: Looking for scripts in: $scriptsDir" -ForegroundColor Gray
        
        if (-not (Test-Path $scriptsDir)) {
            Write-Warning "Scripts directory not found at: $scriptsDir"
            return
        }
        
        $scripts = Get-ChildItem -Path $scriptsDir -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
        Write-Host "Debug: Found $($scripts.Count) script files" -ForegroundColor Gray
        
        Write-Host "`nAvailable Script Functions:" -ForegroundColor Cyan
        
        foreach ($script in $scripts) {
            try {
                $content = Get-Content $script.FullName -Raw -ErrorAction Stop
                $functions = [regex]::Matches($content, 'function\s+([A-Za-z0-9-]+)\s*{')
                
                if ($functions.Count -gt 0) {
                    Write-Host "`n$($script.Name):" -ForegroundColor Yellow
                    foreach ($function in $functions) {
                        Write-Host "  $($function.Groups[1].Value)" -ForegroundColor Green
                    }
                }
            }
            catch {
                Write-Warning "Error processing script $($script.Name): $_"
            }
        }
    }
    catch {
        Write-Warning "Error getting script functions: $_"
        Write-Host "Debug: Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
    }
}

# Add alias for singular version
Set-Alias -Name Get-ScriptsFunction -Value Get-ScriptsFunctions

function Show-ProfileCommands {
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [string]$Category,
        [switch]$NoColor
    )
    
    $commands = @{
        'Package Management' = @{
            'pkg-install <package>' = 'Install a package using winget'
            'pkg-update' = 'Update all installed packages'
            'pkg-list' = 'List installed packages'
            'pkg-status' = 'Show available package updates'
            'Install-Package' = 'Install or update a specific package using winget'
            'Install-ConfiguredPackages' = 'Install packages from config.psd1'
        }
        'Module Management' = @{
            'Import-RequiredModule' = 'Import and install if needed a PowerShell module'
            'Update-PowerShellModule' = 'Update PowerShell modules'
            'Remove-UnusedModules' = 'Clean up unused modules'
            'Update-ModulePath' = 'Display or update PowerShell module paths'
            'modpath' = 'Alias for Update-ModulePath'
        }
        'URL Commands' = @{
            'llm'                      = '🤖 Open AI sites (ChatGPT, Claude, Gemini, etc.)'
            'Open-AiPKGsearch'         = '📦 Open AI development sites (HuggingFace, TensorFlow, etc.)'
            'Open-AiSearch'            = '🔍 Open AI search engines (Perplexity, Phind, etc.)'
            'Open-AiArt'               = '🎨 Open AI art generation sites'
            'Open-AiAzure'             = '☁️ Open AI Azure services and documentation'
            'Open-AiOpenAI'            = '🤖 Open OpenAI services and documentation'
            'Open-AiGithub'            = '📂 Open AI GitHub repositories'
            'Open-AiGoogle'            = '🔍 Open Google AI services'
            'Open-AiMicrosoft'         = '🪟 Open Microsoft AI services'
            'Open-AiStackOverflow'     = '💡 Open AI Stack Overflow discussions'
            'Open-AiReddit'            = '🤝 Open AI Reddit communities'
            'Open-AiTwitter'           = '🐦 Open AI Twitter feeds'
            'Open-AiYoutube'           = '📺 Open AI YouTube channels'
            'Open-AiLinkedin'          = '💼 Open AI LinkedIn content'
            'Open-AiDiscord'           = '💬 Open AI Discord communities'
            'Open-GoogleCore'          = '🔍 Open Google core services'
            'Open-GoogleProductivity'  = '📝 Open Google productivity tools'
            'Open-GoogleCommunication' = '💬 Open Google communication tools'
            'Open-GoogleMedia'         = '🎥 Open Google media services'
            'Open-GoogleTools'         = '🛠️ Open Google tools and utilities'
            'Open-GoogleBusiness'      = '💼 Open Google business tools'
            'Open-GoogleBlogs'         = '📰 Open Google blogs and news'
            'Open-GoogleCloud'         = '☁️ Open Google cloud services'
            'Open-GoogleOther'         = '🔗 Open other Google services'
            'Open-DevDocs'             = '📚 Open developer documentation'
            'Open-DevGit'              = '📂 Open Git platforms and repositories'
            'Open-DevWebDev'           = '🌐 Open web development resources'
            'Open-DevJavascript'       = '⚡ Open JavaScript resources'
            'Open-DevPython'           = '🐍 Open Python development resources'
            'Open-DevCss'              = '🎨 Open CSS resources and tutorials'
            'Open-DevPackageManagers'  = '📦 Open package manager sites'
            'Open-DevCloudSites'       = '☁️ Open cloud platform sites'
            'Open-DevCloudStorage'     = '💾 Open cloud storage services'
            'Open-DevMacro'            = '🔧 Open microcontroller and hardware sites'
            'Open-StockSites'          = '📈 Open stock trading and analysis sites'
            'Open-Trading'             = '💹 Open trading platforms and tools'
            'Open-StockTickers'        = '📊 Open stock ticker lookup sites'
            'Open-Forex'               = '💱 Open forex trading sites'
            'Open-Crypto'              = '₿ Open cryptocurrency sites'
            'Open-CryptoNews'          = '📰 Open cryptocurrency news sites'
            'Open-Banking'             = '🏦 Open banking sites'
            'Open-Wallets'             = '👛 Open digital wallet sites'
            'Open-CreditCards'         = '💳 Open credit card sites'
            'Open-RealEstate'          = '🏠 Open real estate sites'
            'Open-Insurance'           = '🛡️ Open insurance sites'
            'Open-Retirement'          = '👴 Open retirement planning sites'
            'Open-NewsSites'           = '📰 Open general news sites'
            'Open-TechNews'            = '💻 Open technology news sites'
            'Open-Art'                 = '🎨 Open art and design sites'
            'Open-ArtReff'             = '📚 Open art reference and resource sites'
            'Open-Social'              = '🌐 Open general social media sites'
            'Open-SocialProfessional'  = '💼 Open professional social networks'
            'Open-SocialPersonal'      = '👤 Open personal social media sites'
            'Open-SocialContent'       = '📱 Open content platforms'
            'Open-SocialCommunity'     = '👥 Open community sites'
            'Open-Learning'            = '📖 Open learning platforms'
            'Open-CloudStorage'        = '💾 Open cloud storage services'
            'Open-Utilities'           = '🛠️ Open general utility sites'
            'Open-UtilitiesDrawing'    = '✏️ Open drawing and design tools'
            'Open-UtilitiesLoans'      = '💰 Open loan services'
            'Open-UtilitiesEnergy'     = '⚡ Open energy provider sites'
            'Open-UtilitiesOther'      = '🔧 Open other utility sites'
            'gally'                    = '📦 Open PowerShell Gallery'
            'ythistory'                = '📺 Open YouTube history'
            'winrun'                   = '🚀 Open Windows Run dialog'
            'devdocs'                  = '📚 Open DevDocs documentation'
            'icloud'                   = '☁️ Open iCloud services'
            'icloud_drive'             = '💾 Open iCloud Drive'
            'icloud_photos'            = '📸 Open iCloud Photos'
            'icloud_mail'              = '✉️ Open iCloud Mail'
            'icloud_contacts'          = '👥 Open iCloud Contacts'
        }
        'Utility Commands'   = @{
            'reload'                         = '🔄 Reload PowerShell profile'
            'Get-Guid'                       = '🔑 Generate a new GUID'
            'Show-Welcome'                   = '👋 Display welcome message'
            'Show-ProfileMetrics'            = '📊 Display profile load metrics'
            'Show-ProfileCommands -Detailed' = '📝 Show detailed descriptions for commands'
            'Write-ProfileLog'               = '📋 Write a log message to profile.log'
            'Note'                           = '📝 Create, read, and manage notes -Action [new, read, add, list, delete]'
            'aish'                           = '🤖 Open AI Shell use /help to get a list of commands HK: Ctrl+dCtrl+c copy cmd  Ctrl+<n>'
            'Start-AIShell'                  = '🚀 Start AI Shell'
            'Start-AIShell -Detailed'        = '📊 Start AI Shell with detailed output'
            'Get-ScriptsFunctions'           = '📚 Get Scripts Functions'
        }
    }
    
    # Color configuration
    $colors = @{
        Header = if ($NoColor) { 'White' } else { 'Cyan' }
        Category = if ($NoColor) { 'White' } else { 'Yellow' }
        Command = if ($NoColor) { 'White' } else { 'Green' }
        Description = if ($NoColor) { 'White' } else { 'Gray' }
        Tip = if ($NoColor) { 'White' } else { 'DarkGray' }
    }

    # Header
    Write-Host "`nAvailable Profile Commands:" -ForegroundColor $colors.Header
    
    # Filter categories if specified
    $categoriesToShow = if ($Category) {
        $commands.Keys | Where-Object { $_ -like "*$Category*" }
    } else {
        $commands.Keys
    }

    # Display commands
    foreach ($category in $categoriesToShow) {
        Write-Host "`n$($category):" -ForegroundColor $colors.Category
        
        $commands[$category].GetEnumerator() | Sort-Object Key | ForEach-Object {
            if ($Detailed) {
                Write-Host ("  {0,-30}" -f $_.Key) -NoNewline -ForegroundColor $colors.Command
                Write-Host " - $($_.Value)" -ForegroundColor $colors.Description
            } else {
                Write-Host "  $($_.Key)" -ForegroundColor $colors.Command
            }
        }
    }
    
    # Show tips
    if (-not $Category) {
        Write-Host "`nTips:" -ForegroundColor $colors.Tip
        Write-Host "- Use 'Show-ProfileCommands -Detailed' for command descriptions" -ForegroundColor $colors.Tip
        Write-Host "- Use 'Show-ProfileCommands -Category <name>' to filter by category" -ForegroundColor $colors.Tip
        Write-Host "- Use 'Show-ProfileCommands -NoColor' for plain text output" -ForegroundColor $colors.Tip
    }
}
