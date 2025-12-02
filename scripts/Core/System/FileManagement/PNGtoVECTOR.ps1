function Convert-PngToVector {
    [Alias('png2vec')]
    [CmdletBinding()]
    param()

    # Ask for input file
    $inputFile = Read-Host "Enter the path to your PNG file (or drag and drop the file here)"
    
    # Remove quotes if user dragged and dropped the file
    $inputFile = $inputFile.Trim('"')
    
    # Verify input file exists
    if (-not (Test-Path $inputFile)) {
        Write-Error "Input file not found: $inputFile"
        return
    }
    
    # Verify it's a PNG file
    if ([System.IO.Path]::GetExtension($inputFile) -ne '.png') {
        Write-Error "Input file must be a PNG file"
        return
    }

    # Ask for output filename
    $outputName = Read-Host "Enter the name for your output SVG file (without extension)"
    
    # Ask for output directory
    $defaultDir = Split-Path $inputFile -Parent
    $outputDir = Read-Host "Enter the output directory path (press Enter to use same directory as input: $defaultDir)"
    
    # If no directory specified, use input file's directory
    if ([string]::IsNullOrWhiteSpace($outputDir)) {
        $outputDir = $defaultDir
    }
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $outputDir)) {
        $createDir = Read-Host "Directory doesn't exist. Create it? (Y/N)"
        if ($createDir -eq 'Y') {
            New-Item -ItemType Directory -Path $outputDir -Force
        } else {
            Write-Error "Operation cancelled: Output directory does not exist"
            return
        }
    }
    
    # Construct full output path
    $outputFile = Join-Path $outputDir "$outputName.svg"
    
    # Confirm if file exists
    if (Test-Path $outputFile) {
        $overwrite = Read-Host "File already exists. Overwrite? (Y/N)"
        if ($overwrite -ne 'Y') {
            Write-Host "Operation cancelled by user"
            return
        }
    }
    
    try {
        Write-Host "Converting $inputFile to $outputFile..." -ForegroundColor Cyan
        
        # Call the bash script with the input and output paths
        Invoke-BashScript -ScriptPath "C:\Users\russk\OneDrive\Documentos\PowerShell\Scripts\Bash\png2svg.sh" -Arguments $inputFile, $outputFile
        
        if (Test-Path $outputFile) {
            Write-Host "Conversion completed successfully!" -ForegroundColor Green
            Write-Host "Output saved to: $outputFile"
        } else {
            Write-Error "Conversion failed: Output file was not created"
        }
    }
    catch {
        Write-Error "Error during conversion: $_"
    }
}

# Add alias if it doesn't exist
if (-not (Get-Alias -Name png2vec -ErrorAction SilentlyContinue)) {
    New-Alias -Name png2vec -Value Convert-PngToVector
}
