#TODO create a Generate QR code from  my GH repo
function gen_qr {
$pythonScript = 
"C:\Users\Digital_Russkiy\python_Scripts\Code\Gen-QRcode.py"
Write-Host "Running: python $pythonScript `"$Query`"" -ForegroundColor Cyan
python "$pythonScript" "$Query"
}

function Search-Art {
    param(
        [string]$Query
    )
    $pythonScript = "C:\Users\Digital_Russkiy\Python_Scripts\art_search.py"
    if (-not (Test-Path $pythonScript)) {
        Write-Host "Python script not found at $pythonScript" -ForegroundColor Red
        return
    }
    if (-not $Query) {
        Write-Host "Please provide a search query." -ForegroundColor Yellow
        return
    }
    Write-Host "Running: python $pythonScript `"$Query`"" -ForegroundColor Cyan
    python "$pythonScript" "$Query"
}