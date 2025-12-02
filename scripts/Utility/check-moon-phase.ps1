<#
.SYNOPSIS
	Checks the Moon phase
.DESCRIPTION
	This PowerShell script determines the Moon phase and answers by text-to-speech (TTS).
.EXAMPLE
	PS> ./check-moon-phase
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz |Svyatoslav O Russkiy| License: CC0 
#>

# Moon phase calculation script
function Get-MoonPhase {
    [CmdletBinding()]
    param()

    try {
        $LunarCycle = 29.53058868 # Synodic period in days (time between successive new moons)
        $LunarHalfCycle = $LunarCycle / 2.0
        $Phases = @("New moon", "Waxing crescent moon", "First quarter moon", "Waxing gibbous moon", "Full moon", "Waning gibbous moon", "Last quarter moon", "Waning crescent moon")
        $PhaseLength = $LunarCycle / 8.0
        $PhaseHalfLength = $PhaseLength / 2.0

        # Reference Date for New Moon (Dec 4, 2021 06:43 UTC)
        $RefDate = Get-Date -Year 2021 -Month 12 -Day 4 -Hour 6 -Minute 43
        $Now = Get-Date
        $TimeInterval = New-TimeSpan -Start $RefDate -End $Now
        $Days = $TimeInterval.TotalDays

        # Moon phase calculation (modulus with Lunar Cycle)
        $MDays = $Days % $LunarCycle
        $PhaseIndex = [int]($MDays * (8.0 / $LunarCycle))

        # Calculate visibility percentage
        $Visibility = [math]::Round((($Days % $LunarHalfCycle) * 100) / $LunarHalfCycle)

        # Reply with moon phase and visibility
        $Reply = "$($Phases[$PhaseIndex]) with $($Visibility)% visibility"

        # Calculate Moon Age
        $MoonAge = [math]::Round($Days % $LunarCycle)

        # Provide appropriate response based on Moon Age
        if ($MoonAge -eq 0) { 
            $Reply += " today" 
        }
        elseif ($MoonAge -eq 1) { 
            $Reply += " since yesterday" 
        }
        else { 
            $Reply += ", last new moon was $MoonAge days ago"
        }

        # Use the Invoke-Speech function from the module if available
        if (Get-Command -Name Invoke-Speech -ErrorAction SilentlyContinue) {
            Invoke-Speech -Text $Reply
        }
        else {
            Write-Warning "Invoke-Speech function not found"
        }

        # Also return the text
        return $Reply
    }
    catch {
        Write-Error "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        return $null
    }
}

# Write a simple confirmation that the script was loaded
Write-Host "Moon phase functions loaded. Use Get-MoonPhase to check the current moon phase." -ForegroundColor Green
