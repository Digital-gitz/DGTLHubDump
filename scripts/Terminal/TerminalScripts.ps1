function Pass-Help {
    # Open the password-store documentation website
    Start-Process "https://git.zx2c4.com/password-store/about/"
    
    # Execute gopass --help command
    gopass --help
}
