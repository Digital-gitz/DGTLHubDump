# Define the path to your JSON file
$jsonFilePath = Join-Path $PSScriptRoot "urls.json"

# Load URL collections from JSON
$global:UrlCollections = @{}
if (Test-Path $jsonFilePath) {
    try {
        $jsonContent = Get-Content $jsonFilePath -Raw
        $jsonData = ConvertFrom-Json $jsonContent -AsHashtable -ErrorAction Stop
        $global:UrlCollections = $jsonData.UrlCollections
        Write-Verbose "Successfully loaded URL collections from $jsonFilePath"
    }
    catch {
        Write-Error "Error loading URL collections from JSON: $_"
    }
}
else {
    Write-Warning "JSON file not found at path: $jsonFilePath"
}

# Base function for opening URLs with improved error handling and logging
function Open-Urls {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$Urls,
        [string]$Message = "Opened URLs",
        [switch]$ShowUrls,
        [string]$Category,
        [string]$Subcategory
    )
    
    # Debug information
    Write-Verbose "URL Collections available: $($global:UrlCollections.Keys -join ', ')"
    
    # Handle null or empty URLs
    if ($null -eq $Urls -or $Urls.Count -eq 0) {
        Write-Warning "No URLs provided for $Message"
        return
    }
    
    # Filter out invalid URLs and empty strings
    $validUrls = $Urls | Where-Object { 
        $_ -and $_.Trim() -match '^https?://' 
    }
    
    if ($validUrls.Count -eq 0) {
        Write-Warning "No valid URLs found for $Message"
        return
    }
    
    $count = 0
    foreach ($url in $validUrls) {
        try {
            Start-Process $url
            $count++
            if ($ShowUrls) {
                Write-Host "  → $url" -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Warning "Failed to open URL: $url"
            Write-Warning $_.Exception.Message
        }
    }
    
    $categoryInfo = if ($Category -and $Subcategory) { " ($Category > $Subcategory)" } else { "" }
    Write-Host "$Message$categoryInfo ($count URLs)" -ForegroundColor Green
}

# Helper function to get URLs from collections with improved error handling
function Get-UrlCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Category,
        [Parameter(Mandatory)]
        [string]$Subcategory
    )
    
    # Debug information
    Write-Verbose "Looking for Category: $Category, Subcategory: $Subcategory"
    Write-Verbose "Available Categories: $($global:UrlCollections.Keys -join ', ')"
    
    if (-not $global:UrlCollections.ContainsKey($Category)) {
        Write-Warning "Category '$Category' not found in URL collections"
        return $null
    }
    
    if (-not $global:UrlCollections[$Category].ContainsKey($Subcategory)) {
        Write-Warning "Subcategory '$Subcategory' not found in category '$Category'"
        return $null
    }
    
    return $global:UrlCollections[$Category][$Subcategory]
}

# Base function for opening URLs from a collection
function Open-UrlCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Category,
        [Parameter(Mandatory)]
        [string]$Subcategory,
        [string]$Message,
        [switch]$ShowUrls
    )
    
    $urls = Get-UrlCollection -Category $Category -Subcategory $Subcategory
    if ($urls) {
        Write-Host "`n$Message ($Category > $Subcategory)" -ForegroundColor Cyan
        Write-Host "URLs to open:" -ForegroundColor Yellow
        $urls | ForEach-Object {
            $cleanUrl = $_ -replace '^https?://(www\.)?', '' -replace '\.(com|org|net|io|ai|dev|cloud|app|co|me|us|uk|ru|de|fr|jp|cn|in|br|au|ca|nz|za|kr|nl|pl|it|es|se|dk|no|fi|ie|at|ch|be|pt|gr|cz|hu|ro|sk|ua|il|tr|ae|sa|sg|my|th|vn|id|ph|mx|ar|cl|pe|co|za|eg|ma|ng|ke|za).*$', ''
            Write-Host "  → $cleanUrl" -ForegroundColor DarkGray
        }
        Write-Host ""
        Open-Urls -Urls $urls -Message $Message -Category $Category -Subcategory $Subcategory -ShowUrls:$ShowUrls
    }
}

#region Direct URL 
function gally { Start-Process "https://www.powershellgallery.com/" }
function ythistory { Start-Process "https://www.youtube.com/feed/history" }
function winrun { Start-Process "https://win.run/" }
function OhmyPoshTheme { Start-Process "https://ohmyposh.dev/docs/themes/" }
#endregion Direct URL 

function devdocs { Start-Process "https://devdocs.io/" }    
#region DevDocs functions
$devdocsUrls = @{
    'css'        = 'https://devdocs.io/css/'
    'html'       = 'https://devdocs.io/html/'
    'javascript' = 'https://devdocs.io/javascript/'
    'python'     = 'https://devdocs.io/python/'
    'ruby'       = 'https://devdocs.io/ruby/'
    'php'        = 'https://devdocs.io/php/'
}

foreach ($lang in $devdocsUrls.Keys) {
    Set-Item -Path "Function:devdocs_$lang" -Value {
        param()
        Start-Process $devdocsUrls[$lang]
    }
}

# iCloud functions
$icloudUrls = @{
    'drive'    = 'https://www.icloud.com/drive/'
    'photos'   = 'https://www.icloud.com/photos/'
    'mail'     = 'https://www.icloud.com/mail/'
    'contacts' = 'https://www.icloud.com/contacts/'
}

foreach ($service in $icloudUrls.Keys) {
    Set-Item -Path "Function:icloud_$service" -Value {
        param()
        Start-Process $icloudUrls[$service]
    }
}

# Define function categories and their messages
$functionCategories = @{
    'AI'          = @{
        'AiPackages' = '📦 Opening AI development sites (HuggingFace, TensorFlow, etc.)'
        'AiSearch'   = '🔍 Opening AI search engines (Perplexity, Phind, etc.)'
        'AiArt'      = '🎨 Opening AI art generation sites'
        'Azure'      = '☁️ Opening AI Azure services and documentation'
        'LLM'        = '🤖 Opening OpenAI services and documentation'
        'Resources'  = '📂 Opening AI GitHub repositories'
        'General'    = '🔍 Opening AI general sites'
    }
    'Google'      = @{
        'Core'          = '🔍 Opening Google core services'
        'Productivity'  = '📝 Opening Google productivity tools'
        'Communication' = '💬 Opening Google communication tools'
        'Media'         = '🎥 Opening Google media services'
        'Tools'         = '🛠️ Opening Google tools and utilities'
        'Business'      = '💼 Opening Google business tools'
        'Blogs'         = '📰 Opening Google blogs and news'
        'Cloud'         = '☁️ Opening Google cloud services'
        'Other'         = '🔗 Opening other Google services'
    }
    'Development' = @{
        'Docs'            = '📚 Opening developer documentation'
        'Git'             = '📂 Opening Git platforms and repositories'
        'WebDev'          = '🌐 Opening web development resources'
        'APIs'            = '🔌 Opening developer API sites'
        'Javascript'      = '⚡ Opening JavaScript resources'
        'Python'          = '🐍 Opening Python development resources'
        'Css'             = '🎨 Opening CSS resources and tutorials'
        'PackageManagers' = '📦 Opening package manager sites'
        'CloudSites'      = '☁️ Opening cloud platform sites'
        'CloudStorage'    = '💾 Opening cloud storage services'
        'Macro'           = '🔧 Opening microcontroller and hardware sites'
        'Components'      = '🔧 Opening component libraries and frameworks'
        'Database'        = '💾 Opening database sites'
    }
    'Finance'     = @{
        'StockSites'   = '📈 Opening stock trading and analysis sites'
        'Trading'      = '💹 Opening trading platforms and tools'
        'StockTickers' = '�� Opening stock ticker lookup sites'
        'Forex'        = '💱 Opening forex trading sites'
        'Crypto'       = '₿ Opening cryptocurrency sites'
        'CryptoNews'   = '📰 Opening cryptocurrency news sites'
        'Banking'      = '🏦 Opening banking sites'
        'Wallets'      = '👛 Opening digital wallet sites'
        'CreditCards'  = '💳 Opening credit card sites'
        'RealEstate'   = '🏠 Opening real estate sites'
        'Insurance'    = '🛡️ Opening insurance sites'
        'Retirement'   = '👴 Opening retirement planning sites'
    }
    'News'        = @{
        'General'   = '📰 Opening general news sites'
        'Tech'      = '💻 Opening technology news sites'
        'NewsSites' = '📰 Opening general news sites'
    }
    'Art'         = @{
        'General'   = '🎨 Opening art and design sites'
        'Reference' = '📚 Opening art reference and resource sites'
    }
    'Social'      = @{
        'General'      = '🌐 Opening general social media sites'
        'Professional' = '💼 Opening professional social networks'
        'Personal'     = '👤 Opening personal social media sites'
        'Content'      = '📱 Opening content platforms'
        'Community'    = '👥 Opening community sites'
    }
    'Utilities'   = @{
        'General' = '🛠️ Opening general utility sites'
        'Drawing' = '✏️ Opening drawing and design tools'
        'Loans'   = '💰 Opening loan services'
        'Energy'  = '⚡ Opening energy provider sites'
        'Other'   = '🔧 Opening other utility sites'
    }
    'Learning'    = @{
        'General' = '📖 Opening learning platforms'
    }
}

# Generate functions for each category and subcategory
foreach ($category in $functionCategories.Keys) {
    foreach ($subcategory in $functionCategories[$category].Keys) {
        $message = $functionCategories[$category][$subcategory]
        
        # Create function name (different patterns based on category)
        $functionName = switch ($category) {
            'AI' { "Open-$subcategory" }
            'Google' { "Open-Google$subcategory" }
            'Development' { "Open-Dev$subcategory" }
            'Finance' { "Open-$subcategory" }
            'News' { "Open-News$subcategory" }
            'Art' { "Open-Art$subcategory" }
            'Social' { "Open-Social$subcategory" }
            'Utilities' { "Open-Utilities$subcategory" }
            default { "Open-$category$subcategory" }
        }
        
        # Create the function
        $scriptBlock = [ScriptBlock]::Create("
            param()
            Open-UrlCollection -Category '$category' -Subcategory '$subcategory' -Message '$message'
        ")
        
        Set-Item -Path "Function:$functionName" -Value $scriptBlock
    }
    
    # Create category-level functions for selected categories
    if ($category -in @('Utilities', 'Social', 'Learning')) {
        $scriptBlock = [ScriptBlock]::Create("
            param()
            foreach (`$subcategory in `$functionCategories['$category'].Keys) {
                Open-UrlCollection -Category '$category' -Subcategory `$subcategory -Message `$functionCategories['$category'][`$subcategory]
            }
        ")
        
        Set-Item -Path "Function:Open-$category" -Value $scriptBlock
    }
}

# Create specific aliases
Set-Alias -Name 'llm' -Value 'Open-LLM'
Set-Alias -Name 'ai-search' -Value 'Open-AiSearch'
Set-Alias -Name 'google-core' -Value 'Open-GoogleCore'
Set-Alias -Name 'google-productivity' -Value 'Open-GoogleProductivity'
Set-Alias -Name 'google-media' -Value 'Open-GoogleMedia'

Write-Host "URL Commands loaded" -ForegroundColor Green
