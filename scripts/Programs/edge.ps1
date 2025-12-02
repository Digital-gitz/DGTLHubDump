
function global:edge {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Url
    )
    
    $edgePath = "C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe"
    
    if ($Url) {
        Start-Process -FilePath $edgePath -ArgumentList $Url
    }
    else {
        Start-Process -FilePath $edgePath
    }
}