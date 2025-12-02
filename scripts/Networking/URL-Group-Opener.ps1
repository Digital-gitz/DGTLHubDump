# URL-Group-Opener.ps1
# A simple script to open groups of URLs based on a JSON configuration file

# Define the path to the JSON file
$jsonFilePath = "$PSScriptRoot\url_groups.json"

# Function to load URL groups from JSON file
function Load-UrlGroups {
    param (
        [string]$FilePath = $jsonFilePath
    )
    
    if (Test-Path $FilePath) {
        try {
            $jsonContent = Get-Content -Path $FilePath -Raw -ErrorAction Stop
            $urlGroups = ConvertFrom-Json $jsonContent -ErrorAction Stop
            return $urlGroups
        }
        catch {
            Write-Error "Error reading or parsing JSON file: $_"
            return $null
        }
    }
    else {
        Write-Error "JSON file not found at: $FilePath"
        return $null
    }
}

# Function to open URLs from a specific group
function Open-UrlGroup {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$GroupName,
        
        [switch]$List
    )
    
    # Load the URL groups
    $urlGroups = Load-UrlGroups
    
    if ($null -eq $urlGroups) {
        return
    }
    
    # Check if the group exists
    if (-not ($urlGroups.PSObject.Properties.Name -contains $GroupName)) {
        # Check if it's a nested group with Category-Subcategory format
        $parts = $GroupName -split '-'
        
        if ($parts.Count -eq 2 -and ($urlGroups.PSObject.Properties.Name -contains $parts[0])) {
            $category = $parts[0]
            $subcategory = $parts[1]
            
            if ($urlGroups.$category.PSObject.Properties.Name -contains $subcategory) {
                $urls = $urlGroups.$category.$subcategory
                Write-Host "Opening URLs from group '$category-$subcategory':" -ForegroundColor Cyan
                
                for ($i = 0; $i -lt $urls.Count; $i++) {
                    Write-Host "[$i] $($urls[$i])" -ForegroundColor White
                }
                
                if (-not $List) {
                    $confirmation = Read-Host "`nOpen these URLs? (Y/N/S for select)"
                    
                    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
                        foreach ($url in $urls) {
                            Start-Process $url
                            Start-Sleep -Milliseconds 500
                        }
                        Write-Host "Opened $($urls.Count) URLs" -ForegroundColor Green
                    }
                    elseif ($confirmation -eq "S" -or $confirmation -eq "s") {
                        $selection = Read-Host "Enter URL numbers to open (comma-separated, e.g. 0,2,3)"
                        $indices = $selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
                        
                        foreach ($index in $indices) {
                            if ([int]$index -lt $urls.Count) {
                                Start-Process $urls[[int]$index]
                                Start-Sleep -Milliseconds 500
                            }
                        }
                        Write-Host "Opened selected URLs" -ForegroundColor Green
                    }
                    else {
                        Write-Host "Operation cancelled" -ForegroundColor Yellow
                    }
                }
                return
            }
        }
        
        Write-Error "Group '$GroupName' not found. Available groups:"
        Show-UrlGroups
        return
    }
    
    # Handle direct group
    $urls = $urlGroups.$GroupName
    
    # If this is a category with subcategories, list them
    if ($urls -is [PSCustomObject]) {
        Write-Host "`n'$GroupName' contains these subgroups:" -ForegroundColor Cyan
        $urls.PSObject.Properties.Name | ForEach-Object {
            Write-Host "  $GroupName-$_" -ForegroundColor Yellow
        }
        return
    }
    
    # Display the URLs
    Write-Host "URLs in group '$GroupName':" -ForegroundColor Cyan
    for ($i = 0; $i -lt $urls.Count; $i++) {
        Write-Host "[$i] $($urls[$i])" -ForegroundColor White
    }
    
    # Open the URLs if not just listing
    if (-not $List) {
        $confirmation = Read-Host "`nOpen these URLs? (Y/N/S for select)"
        
        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
            foreach ($url in $urls) {
                Start-Process $url
                Start-Sleep -Milliseconds 500
            }
            Write-Host "Opened $($urls.Count) URLs" -ForegroundColor Green
        }
        elseif ($confirmation -eq "S" -or $confirmation -eq "s") {
            $selection = Read-Host "Enter URL numbers to open (comma-separated, e.g. 0,2,3)"
            $indices = $selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
            
            foreach ($index in $indices) {
                if ([int]$index -lt $urls.Count) {
                    Start-Process $urls[[int]$index]
                    Start-Sleep -Milliseconds 500
                }
            }
            Write-Host "Opened selected URLs" -ForegroundColor Green
        }
        else {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
        }
    }
}

# Function to show all available URL groups
function Show-UrlGroups {
    $urlGroups = Load-UrlGroups
    
    if ($null -eq $urlGroups) {
        return
    }
    
    Write-Host "`nAvailable URL Groups:" -ForegroundColor Cyan
    
    foreach ($groupName in $urlGroups.PSObject.Properties.Name) {
        $group = $urlGroups.$groupName
        
        if ($group -is [PSCustomObject]) {
            # This is a category with subcategories
            Write-Host "`n${groupName}:" -ForegroundColor Green
            
            foreach ($subgroupName in $group.PSObject.Properties.Name) {
                $subgroup = $group.$subgroupName
                $urlCount = $subgroup.Count
                Write-Host "  ├─ $groupName-$subgroupName ($urlCount URLs)" -ForegroundColor Yellow
            }
        }
        else {
            # This is a direct URL group
            $urlCount = $group.Count
            Write-Host "$groupName ($urlCount URLs)" -ForegroundColor White
        }
    }
}

# Function to create a sample JSON file if none exists
function Create-SampleJson {
    $sampleJson = @"
{
    "AI": {
        "LLM": [
            "https://chat.openai.com/",
            "https://claude.ai/",
            "https://bard.google.com/"
        ],
        "Search": [
            "https://www.perplexity.ai/",
            "https://www.bing.com/search?q=Bing+AI&showconv=1"
        ],
        "Creation": [
            "https://clipdrop.co/",
            "https://www.midjourney.com"
        ]
    },
    "Google": {
        "Core": [
            "https://www.google.com/",
            "https://mail.google.com/"
        ],
        "Productivity": [
            "https://docs.google.com/",
            "https://drive.google.com/"
        ]
    },
    "Development": {
        "GitHub": [
            "https://github.com/"
        ],
        "Documentation": [
            "https://learn.microsoft.com/en-us/powershell/"
        ]
    },
    "SocialMedia": [
        "https://twitter.com/",
        "https://www.linkedin.com/",
        "https://www.facebook.com/"
    ]
}
"@
    
    try {
        Set-Content -Path $jsonFilePath -Value $sampleJson -Force
        Write-Host "Created sample JSON file at: $jsonFilePath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to create sample JSON file: $_"
        return $false
    }
}

# Main script execution
if ($args.Count -gt 0) {
    # Command-line mode
    $groupName = $args[0]
    $listOnly = $args -contains "-list" -or $args -contains "-l"
    
    # Check if we're just showing groups
    if ($groupName -eq "list" -or $groupName -eq "show") {
        Show-UrlGroups
    }
    else {
        Open-UrlGroup -GroupName $groupName -List:$listOnly
    }
}
else {
    # Check if JSON file exists, create sample if not
    if (-not (Test-Path $jsonFilePath)) {
        Write-Host "URL groups JSON file not found." -ForegroundColor Yellow
        $createSample = Read-Host "Create a sample file? (Y/N)"
        if ($createSample -eq "Y" -or $createSample -eq "y") {
            if (Create-SampleJson) {
                Show-UrlGroups
            }
        }
    }
    else {
        Show-UrlGroups
    }
}