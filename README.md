# PowerShell Profile & Scripts

## Overview

This repository contains my customized PowerShell profile and collection of utility scripts for enhanced productivity.

## Available Commands

### Navigation & File Management

- `h <pattern>` - Search command history
- `edit_profile` - Edit PowerShell profile

### Applications & Programs

- `Start-Aseprite` - Launch/restart Aseprite
- `Start-DoomEternal` - Launch/restart Doom Eternal
- `godot` - Launch Godot engine

### LLM & AI Tools

- `llm` - Open all LLM chat services
- `chatgpt` - Open ChatGPT
- `claude` - Open Claude
- `gemini` - Open Gemini
- `perplexity` - Open Perplexity AI

## Features

- Enhanced command history with search
- Automatic module management and repair
- Custom color schemes and UI improvements
- Integrated Git support via posh-git
- Oh My Posh theme integration
- Organized script categories:
  - Core utilities
  - File management
  - Development tools
  - UI enhancements
  - Networking tools
  - URL/Web tools
  - Application launchers

Available Commands:
─────────────────────────────────────────────────────────────────────────────

═════════════════════════════════════════════════════════════════════════════
🖥️  APPLICATIONS
  Start-Aseprite     Starts Aseprite Pixel Art Editor
  Start-DoomEternal  Starts Doom Eternal
  godot              Starts Godot
  edge               Starts Edge
  TwitchOverlay      Launches Twitch Chat Overlay
  programs           List Programs
  fonts              Navigate to the fonts folder

📂 NAVIGATION
  ghub             Go to Github Folder and list
  ddump            Go to DigitalHubDump Folder
  edit_powershell  Edit my PowerShell Profile
  cd_blog          Opens My Obsidian Blog
  o_blog           Navigate To my Obsidian Hugo Blog page
  cd_obsidianRoot  Navigate Obsidian cloud directory

🔎 SEARCH & HISTORY
  Search-CommandHistory or h  Search Commands History
  h /pattern/                 Search command history
  list_llm                    List of my LLMs
  Search-GoPackages           Search Go packages
  Search-PyPiPackages         Search Python package to install
  Search-GitHubRepositories   Search GitHub Repo package to install
  Search-GitHubRepos          Search GitHub Repos
  Search-NpmPackages          Search Node Package Manager

🌐 INTERNET & UTILITIES
  Open-Gmail                    Opens up Gmail
  Get-MyIP                      Get my IP
  Get-BIOSInfo                  Get BIOS Info
  Get-SshStatus                 Get the status of SSH (might need elevated permission)
  Get-StockMarketSummary        Get Stock Market Summary
  New-QRCode                    Generate a QR code
  Open-FloridaBlueMemberPortal  Open Florida Blue Member Portal
  Open-EdgePasswords            Open Edge Passwords
  .\Get-ChromeTabs.ps1          get chrome tabs

📱 SOCIAL MEDIA
  Open-SocialChat                           Open all social media platforms
  Get-SocialFunctions                       Show all social media functions
  Get-SocialCategories                      Show social media categories
  facebook, twitter, youtube, twitch, etc.  Open specific platforms

🛠️  GITHUB & GIT
  Git-QuickPush                                                Quick push the repo
  Git_QuickPush                                                Quick push to Repo (Warning: could be faulty)
  gh_create_repo                                               Create a repo in the working directory
  Update-AllRepos                                              Update Github Repos
  New-GitHubRepository                                         New Github Repo
  Open-GitHubRepo                                              Opens a specified GitHub repository
  Set-GitHubRepoVisibility -Owner //myusername// -Repo //myrepo//  Toggle visibility of myusername/myrepo (use -Visibility //public/private//)
  Get-GitHubRepoList                                           Get My Repo List
  Get-GitHubRepoView                                           View Repo
  Get-GitHubRepoclone                                          Clone repo
  password_manager                                             Password Manager

📦 DOWNLOADS
  Download_File        Download file -Url /URL/
  Download_AndRunFile  Download and run file -Url /URL/

❓ HELPERS
  Get-AllFunctions          Show all available functions by category
  Get-FunctionHelp          Show detailed help for a specific function
  Startup                   Open Startup folder on bootup of windows.
  sleep                     Put the computer to sleep.
  restart                   Restart the PowerShell session.
  programs                  List all programs installed on the computer.
  Get-AlphabeticalFileList  example: Get-AlphabeticalFileList -FolderPath C:\Users\\Desktop

🎨 ART
  nmcal             Open a curated list of interesting websites
  Show-ArtCommands  Show Art Commands

🤖 AI
  gemini_url   Open Gemini URL
  gemini_user  Open Gemini User

📁 Files & Directories
  Remove-ItemWithElevation  Remove file or folder with elevated permissions
  Get-AlphabeticalFileList  example: Get-AlphabeticalFileList -FolderPath C:\Users\\Desktop
  Get-My_IP                 Get my IP

🔒 SECURITY
  Get-My_IP           Get my IP
  New-SecurePassword  New-SecurePassword -Length /number/ Options: [-NoNumbers -NoSymbols -NoUppercase -NoLowercase]

🐱GitHub

═════════════════════════════════════════════════════════════════════════════
─────────────────────────────────────────────────────────────────────────────
