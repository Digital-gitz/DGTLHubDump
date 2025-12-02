# TODO need to stringafy the param's in the array. to be installed also needs to check if pkg is installed and check for updates. 

function Install-PipPackages {
    param(
        [string[]]$DefaultPackages = @('instagrapi', 'tweepy', 'requests', 'pandas', 'numpy', 'matplotlib')
        yewtube 
    )


    annotated-types             
    anthropic                   
    anyio                       
    argcomplete                 
    arrow                       
    attrs                       
    beautifulsoup4              
    bs4                         
    cachetools                  
    certifi                     
    cffi                        
    charset-normalizer          
    click                       
    colorama                    
    curl_cffi                   
    dacite                      
    decorator                   
    Deprecated                  
    distlib                     
    distro                      
    docstring_parser            
    fastapi                     
    filelock                    
    future                      
    google-ai-generativelanguage
    google-api-core             
    google-api-python-client    
    google-auth                 
    google-auth-httplib2        
    google-generativeai         
    googleapis-common-protos    
    greenlet                    
    groq                        
    grpcio                      
    grpcio-status               
    h11                         
    httpcore                    
    httplib2                    
    httpx                       
    idna                        
    ImageIO                     
    imageio-ffmpeg              
    instagrapi                  
    jaconv                      
    jiter                       
    kick-chat                   
    markdown-it-py              
    mdurl                       
    moviepy                     
    msgpack                     
    mutagen                     
    neovim                      
    numpy                       
    oauthlib                    
    obsidian-to-hugo            
    openai                      
    outcome                     
    packaging                   
    pandas                      
    parse_pip_search            
    pillow                      
    pip                         
    pipx                        
    platformdirs                
    proglog                     
    prompt_toolkit              
    proto-plus                  
    protobuf                    
    pyasn1                      
    pyasn1_modules              
    pycparser                   
    pycryptodomex               
    pydantic                    
    pydantic_core               
    Pygments                    
    pykakasi                    
    pynvim                      
    pyparsing                   
    PySocks                     
    python-dateutil             
    python-slugify              
    pytube                      
    PyTumblr                    
    pytz                        
    qrcode                      
    RapidFuzz                   
    redis                       
    rel                         
    requests                    
    requests-oauthlib           
    rich                        
    rsa                         
    rtoml                       
    selenium                    
    setuptools                  
    six                         
    sniffio                     
    sortedcontainers            
    soundcloud-v2               
    soupsieve                   
    spotdl                      
    spotipy                     
    starlette                   
    syncedlyrics                
    text-unidecode              
    topydo                      
    tqdm                        
    trio                        
    trio-websocket              
    tweepy                      
    typing_extensions           
    typing-inspection           
    tzdata                      
    Unidecode                   
    uritemplate                 
    urllib3                     
    urwid                       
    userpath                    
    uvicorn                     
    virtualenv                  
    watchdog                    
    wcwidth                     
    websocket-client            
    websockets                  
    wrapt                       
    wsproto                     
    yt-dlp                      
    ytmusicapi                  
        
        
    e-Host "Available pip packages for installation:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $DefaultPackages.Count; $i++) {
        Write-Host ("[{0}] {1}" -f $i, $DefaultPackages[$i]) -ForegroundColor Green
    }
    Write-Host "`nEnter the numbers of the packages you want to install separated by commas (e.g. 0,2,4):" -ForegroundColor Yellow
    $selection = Read-Host "Selection"
    if (-not $selection) {
        Write-Host "No selection made. Aborting." -ForegroundColor Red
        return
    }
    $indices = $selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
    $chosen = @()
    foreach ($idx in $indices) {
        if ($idx -ge 0 -and $idx -lt $DefaultPackages.Count) {
            $chosen += $DefaultPackages[$idx]
        }
    }
    if ($chosen.Count -eq 0) {
        Write-Host "No valid packages selected to install." -ForegroundColor Red
        return
    }
    $pkgList = $chosen -join ' '
    Write-Host "`nInstalling: $pkgList" -ForegroundColor Cyan
    pip install $pkgList
}