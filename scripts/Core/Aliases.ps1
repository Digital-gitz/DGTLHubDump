#region Aliases
$aliasDefinitions = @{
    'clr'       = 'Clear-Host'
    'home'      = 'Set-HomeLocation'
    'checkpath' = 'Show-Path'
    'path'      = { Show-Path -Formatted }
    'files'     = 'Get-FilesBaseName'
    'lsa'       = 'Get-ChildItem -Force'
    'touch'     = { param($f) New-Item -ItemType File -Path $f -Force }
    'which'     = { param($c) (Get-Command $c).Path }
    'open'     = 'explorer.exe .'
    '..'        = 'cd ..'
    '...'       = 'cd ...'
    '....'      = 'cd ....'
}



function Set-ProfileAliases {
    foreach ($alias in $aliasDefinitions.GetEnumerator()) {
        try {
            if ($alias.Value -is [scriptblock]) {
                Set-Item -Path "function:global:__alias_$($alias.Key)" -Value $alias.Value
                Set-Alias -Name $alias.Key -Value "__alias_$($alias.Key)" -Scope Global -ErrorAction Stop
            }
            elseif ($alias.Value -match '\s') {
                $scriptBlock = [ScriptBlock]::Create($alias.Value)
                Set-Item -Path "function:global:__alias_$($alias.Key)" -Value $scriptBlock
                Set-Alias -Name $alias.Key -Value "__alias_$($alias.Key)" -Scope Global -ErrorAction Stop
            }
            else {
                Set-Alias -Name $alias.Key -Value $alias.Value -Scope Global -ErrorAction Stop
            }
        }
        catch {
            Write-Host "Failed to set alias '$($alias.Key)': $_" -ForegroundColor Red
        }
    }

    # Add alias for singular version
    Set-Alias -Name Get-ScriptsFunction -Value Get-ScriptsFunctions -Scope Global
}
#endregion Aliases

Set-ProfileAliases
Write-Host "Aliases loaded successfully!" -ForegroundColor Green

#Displays all currently defined aliases in the PowerShell session.
#Show-Aliases | Where-Object { $_.Name -like "*git*" }
#Shows only aliases containing "git" in their name.
function Show-Aliases {
    Write-Host "`n📋 Current PowerShell Aliases:" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    
    # Get all aliases and format them
    $aliases = Get-Alias | Sort-Object Name | ForEach-Object {
        [PSCustomObject]@{
            Name  = $_.Name
            Value = $_.Definition
            Type  = if ($_.Definition -like "*function*") { "Function" } else { "Command" }
        }
    }
    
    # Display aliases in a formatted table
    $aliases | Format-Table -AutoSize -Property @(
        @{Name = "Alias"; Expression = { $_.Name }; Width = 15 },
        @{Name = "Command"; Expression = { $_.Value }; Width = 40 },
        @{Name = "Type"; Expression = { $_.Type }; Width = 10 }
    )
    
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "Total aliases: $($aliases.Count)" -ForegroundColor Gray
    Write-Host "Use 'Get-Alias | Where-Object { `$_.Name -like \"*pattern*\" }' to filter aliases" -ForegroundColor DarkGray
}

# Add alias for the function
Set-Alias -Name aliases -Value Show-Aliases -Scope Global

# alias for Module-Managment 
Set-Alias -Name 'pkg-install' -Value 'Install-Package'
Set-Alias -Name 'pkg-update' -Value 'Update-AllPackages'
Set-Alias -Name 'pkg-list' -Value 'Get-InstalledPackages'
Set-Alias -Name 'pkg-status' -Value 'Get-PackageStatus'
Set-Alias -Name 'pkg' -Value 'Invoke-PackageManager'
