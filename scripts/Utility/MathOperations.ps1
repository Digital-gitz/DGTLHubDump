# Function to get the sum of numbers
function Get-Sumation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [int[]]$Numbers
    )

    begin { $retValue = 0 }

    process {
        foreach ($n in $Numbers) {
            $retValue += $n
        }
    }

    end { $retValue }
}

# Function to get subtraction of numbers
function Get-Subtraction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [int[]]$Numbers
    )

    begin { $retValue = 0 }

    process {
        foreach ($n in $Numbers) {
            $retValue -= $n
        }
    }

    end { $retValue }
}

# Function to get substitutes for a word
function Get-Substitutes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Word
    )

    $url = "https://api.datamuse.com/words?rel_syn=$Word"
    $response = Invoke-RestMethod -Uri $url
    $response.word
}

# Function to get cheat sheet for a command
function Get-CheatSh {
    [Alias("cheatsh")]
    param (
        [string] $command
    )
    curl cheat.sh/$command
}