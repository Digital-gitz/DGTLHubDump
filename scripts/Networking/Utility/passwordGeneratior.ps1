#! THIS IS A FUNCTION returns System.Security.SecureString and dose not generate a password string.
function New-SecurePassword {
    [CmdletBinding()]
    param (
        [int]$Length = 16,
        [switch]$NoUppercase,
        [switch]$NoLowercase,
        [switch]$NoNumbers,
        [switch]$NoSymbols
    )

    # Define character sets
    $upperChars = [char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $lowerChars = [char[]]'abcdefghijklmnopqrstuvwxyz'
    $numberChars = [char[]]'0123456789'
    $symbolChars = [char[]]'!@#$%^&*()_+-=[]{}|;:,.<>?'

    # Construct the character pool based on user choices
    $charPool = @()
    if (-not $NoUppercase) { $charPool += $upperChars }
    if (-not $NoLowercase) { $charPool += $lowerChars }
    if (-not $NoNumbers) { $charPool += $numberChars }
    if (-not $NoSymbols) { $charPool += $symbolChars }

    # Handle case where all character types are excluded
    if ($charPool.Count -eq 0) {
        throw "You must include at least one character type."
    }

    # Generate the password
    $passwordChars = [char[]]::new($Length)
    $charIndex = 0

    # Ensure at least one character of each selected type is included
    if (-not $NoUppercase) { $passwordChars[$charIndex++] = $upperChars | Get-SecureRandom }
    if (-not $NoLowercase) { $passwordChars[$charIndex++] = $lowerChars | Get-SecureRandom }
    if (-not $NoNumbers) { $passwordChars[$charIndex++] = $numberChars | Get-SecureRandom }
    if (-not $NoSymbols) { $passwordChars[$charIndex++] = $symbolChars | Get-SecureRandom }

    # Fill the remaining length with random characters from the pool
    while ($charIndex -lt $Length) {
        $passwordChars[$charIndex++] = $charPool | Get-SecureRandom
    }

    # Shuffle the characters to avoid predictable patterns
    $shuffledPassword = $passwordChars | Get-SecureRandom -Count $Length
    
    # Convert the character array to a SecureString for security
    $securePassword = [SecureString]::new()
    $shuffledPassword | ForEach-Object { $securePassword.AppendChar($_) }

    # Output the SecureString
    return $securePassword
}

#Example New-SecurePassword -Length 20 -NoNumbers -NoSymbols