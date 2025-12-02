# Check if conda is installed
try {
    $condaVersion = conda --version
    Write-Host "Found Conda: $condaVersion"
} catch {
    Write-Host "Conda is not installed. Installing Miniconda3..."
    winget.exe install --id "Anaconda.Miniconda3" --exact --source winget --accept-source-agreements --disable-interactivity --silent --include-unknown --accept-package-agreements
}

# Update conda if already installed
if ($condaVersion) {
    Write-Host "Updating Conda..."
    winget.exe update --id "Anaconda.Miniconda3" --exact --source winget --accept-source-agreements --disable-interactivity --silent --include-unknown --accept-package-agreements --force
}

# Install xonsh package
Write-Host "Installing xonsh package..."
conda install -c conda-forge xonsh -y