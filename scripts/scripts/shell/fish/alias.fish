#!bin/fish
#######  _    _ _           _  ##########
#       _    _ _           _       _
#      / \  | | |   __ _  (_)___  ( )___
#     / _ \ | | |  / _` | | / __| |// __|
#    / ___ \| | | | (_| | | \__ \   \__ \
#   /_/   \_\_|_|  \__,_| |_|___/   |___/
#########################################

alias xosh='source ~/.config/fish/config.fish'  # reload shell
alias resh='source ~/.config/fish/config.fish'  # reload shell


# ERROR:  I need to fix this to work with the new fish shell.
alias fishie='sudo cd ~ && sudo code-insiders .'
# manipulation

# File/Directory manipulation. 
# mv, rm, cp
alias mv 'command gmv --interactive --verbose'
alias rm 'command grm --interactive --verbose'
alias cp 'command gcp --interactive --verbose'

# alias chmod commands |d-irectory|OWNER r-ead, w-rite, x-execute|GROUP rwx|OTHERS rwx|
alias modax='sudo chmod a+x'        #add execute permissions for all
alias 000='sudo chmod -R 000'
alias 644='sudo chmod -R 644'    #chane it from root to user
alias 666='sudo chmod -R 666'    
alias 755='sudo chmod -R 755'    
alias 777='sudo chmod -R 777'    #add write permissions for all
alias chown='sudo chown'         #change ownership
alias chmox='chmod +x'
alias where=which # sometimes i forget

alias push="git push"
# TODO: need to change this to Arch
#Open any file using its default program (eg. pdfs, torrents, etc).
# alias update='sudo apt update'
# alias upgrade='sudo apt upgrade'
# alias uninstall='sudo apt remove'
#############################################################################
# Alias's to modified commands
alias cp='sudo cp -i'                    # -i option prompts before overwrite
alias mv='sudo mv -i'                    # -i option prompts before overwrite
alias mkdir='sudo mkdir -p'              # create parent directories as needed
alias mknf='sudo touch'                  # make a new file
alias ps='sudo ps auxf'                  # show all processes
alias ping='sudo ping -c 10'             # ping with 10 packets
alias less='sudo less -R'                # raw control characters
alias apt-get='sudo apt-get'             # debian based systems
alias cat=ccat                           # cat
alias c='vimcat'                         # colored file display
alias fish-alias='c ~/.config/fish/aliases.fish' # open fish aliases
set EDITOR "nvim"                    #Editor is the default text editor in the terminal.
set VISUAL "nvim"                    #Visual mode is the mode that allows you to select text or move the cursor with the mouse.
alias nvim="sudo nvim"
alias iv="feh -FZ"                        # open image in full screen
alias find="sudo locate"                  #swap find for locate
alias py="sudo python3"                        #python3

# TODO: This is going to be a complicated function that takes in a $ that I dont complt- understand yet.
# alias cd='cd; pwd'                      # always print the current directory
#############################################################################

alias lx='ls -lXBh'                     # sort by extension
alias lk='ls -lSrh'                     # sort by size
alias lc='ls -lcrh'                     # sort by change time
alias lu='ls -lurh'                     # sort by access time
alias lr='ls -lRh'                      # recursive ls
alias lt='ls -ltrh'                     # sort by date
alias lm='ls -alh |more'                # pipe through 'more'
alias lw='ls -xAh'                      # wide listing format
alias labc='ls -lap'                    # alphabetical sort, -p adds / to dir
alias wget='sudo wget'


alias newfile='sudo touch'                            # create a new file
alias lf="ls -l | egrep -v '^d'"                      # files only
alias ldir="ls -l | egrep '^d'"                       # directories only
# alias re_shell='source ~/.config/fish/config.fish'  # reload shell
alias clr='clear -x'
alias cls='clear'                       
alias home='cd ~ && pwd'
alias root='cd / && pwd'


#uninstall and or remove a package
alias uninstall='sudo apt remove'   	 # remove a package from apt package manager.
alias rm='sudo rm -iv'                 # ignore nonexistent files, prompt before every removal + explain what is being done.
alias rmdir='sudo rm -Rfv'             # remove empty directories.
alias h="history | grep "
alias pacd="sudo pacman -Syu"                 #download pkg 
alias pacs="sudo pacman -Ss"                  #searh pkgs
alias yodow=" yay -Syu"                        #download pkg
alias yosee=" yay -Ss"                         #search pkgs


# TODO:  Downgit need to write this in a function prompt moselikely....  
alias downgit='https://minhaskamal.github.io/DownGit/#/home?url='  # ? will I need a completion  for this?
#? man what the fuck is going on here...... why is it opening microsoft store
#? and why dose firefox open my donuments. 
alias monkwr='open moz-extension://574700a5-f4dd-44e7-b728-2a1d217a5a18/options.html#url=aHR0cHM6Ly9naXRodWIuY29tL2Rhc2hib2FyZA==&nav=dashboard'


alias gs='git status'               # View Git status.
alias ga='git add'                  # Add a file to Git.
alias gaa='git add --all'           # Add all files to Git.
alias gc='git commit'               # Commit changes to the code.
alias gl='git log --oneline'        # View the Git log.
alias gb='git checkout -b'          # new Git branch and move to new branch at same time.
alias gd='git diff'                 # View the difference between the current branch and the master branch.

###github
# alias ghss='gh gist list --starred'         	                                                   #list starred gists.
# alias ghlg='gh gist list'                                                                     	#list gists.
# alias ghsg='gh search repos list --starred'                                                    #list starred repositories.      	
alias ghv='gh repo view'            	                                                         #Vew details about a repository.
alias ghs='gh search repos'         	                                                         #search for a github repository.
alias ghl='gh repo list'             	                                                         #Get a list of my repositorys.
alias ghr='gh repo rename'		                                                                 #rename a repo.
alias ghc='gh repo clone'		                                                                  #clone a repo.
alias gh_del='gh repo delete'		                                                              #delete a repo.
alias ghdrip='git status; git add .; git status; git commit -a -m "droppin some \.\.\.\.\. dribs"' #add and commit all changes. 
# Show current network information
# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"

# Show open ports
alias openports='netstat -nape --inet'

# Please use 'begin; ...; end' instead of 'function ...; end'
# netinfo ()
# {
# 	echo "--------------- Network Information ---------------"
# 	/sbin/ifconfig | awk /'inet addr/ {print $2}'
# 	echo ""
# 	/sbin/ifconfig | awk /'Bcast/ {print $3}'
# 	echo ""
# 	/sbin/ifconfig | awk /'inet addr/ {print $4}'

# 	/sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
# 	echo "---------------------------------------------------"
# }

#System Information
# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4 | head -5'

# get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3 | head -5'


# Show all logs in /var/log
# alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# IP address lookup
# alias whatismyip="whatsmyip"
# function whatsmyip ()
# {
# 	# Dumps a list of all IP addresses for every device
# 	# /sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }';

# 	# Internal IP Lookup
# 	echo -n "Internal IP: " ; /sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'


# -O flag specifies the output file, -q suppresses the output
# 	# External IP Lookup
# 	echo -n "External IP: " ; wget http://smart-ip.net/myip -O - -q  
# }


# is it a `main` or a `master` repo?
alias gitmainormaster="git branch --format '%(refname:short)' --sort=-committerdate --list master main | head -n1"
alias main="git checkout (gitmainormaster)"
alias master="main"


# ag defaults. go as wide as terminal (minus some space for line numbers)
# i used to like `--follow --hidden` but dont anymore. -follow ends up with lots of fstat errors on broken symlinks. and --hidden is something that should be turned on explicitly.
alias ag='command ag -W (math $COLUMNS - 14)'  

# fd is fast but their multicore stuff is dumb and slow and bad. https://github.com/sharkdp/fd/issues/1203
alias fd='command fd -j1 --exclude node_modules'
# By default watchexec thinks the project origin is higher up.  So dumb. 
alias watchexec='command watchexec --project-origin . --ignore node_modules'


# for counting instances.. `ag -o 'metadata","name":".*?"' trace.json | sorteduniq`
alias sorteduniq="sort | uniq -c | sort -r"
alias sorteduniq-asc="sort | uniq -c | sort"


alias diskspace_report="df -P -kHl"
alias free_diskspace_report="diskspace_report"

alias hosts='sudo $EDITOR /etc/hosts'   # yes I occasionally 127.0.0.1 twitter.com ;)

alias resetmouse='printf '"'"'\e[?1000l'"'"

alias dotfiles="subl ~/code/dotfiles" # open dotfiles for viewing


# Networking. IP address, dig, DNS
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias dig="dig +nocmd any +multiline +noall +answer"
# wget sucks with certificates. Let's keep it simple.
alias wget="curl -O"





# Recursively delete `.DS_Store` files
alias cleanup_dsstore="find . -name '*.DS_Store' -type f -ls -delete"

alias ungz="gunzip -k"

# File size
alias fs="stat -f \"%z bytes\""

# emptytrash written as a function

# Update installed Ruby gems, Homebrew, npm, and their installed packages
# alias brew_update="brew -v update; brew upgrade --force-bottle --cleanup; brew cleanup; brew cask cleanup; brew prune; brew doctor; npm-check -g -u"
# alias update_brew_npm_gem='brew_update; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update --no-document'

# url file path's
# alias glass2k='open /mnt/c/Users/russk/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/Glass2k.exe'

# ? this might not work with windows exixutables I could try to figure out how Pengwin impliments it but that is a hell of a segway to go down the WSL file syst.
#  alias obsidian='open /mnt/c/Users/russk/AppData/Roaming/obsidian/obsidian.exe'
alias desktop='cd /mnt/c/Users/russk/Desktop'
alias progs='cd /mnt/c/Program\ Files/'
alias adobe='cd /mnt/c/Program\ Files/Adobe'
alias russk='cd /mnt/c/Users/russk/'
alias obsidian='cd /mnt/c/Users/russk/digital/Obsidian/Obsidian-github/Obsidian-Second-Brain'
alias ios-obsidian='cd /mnt/c/Users/russk/iCloudDrive/Obsidian'
alias ios='cd /mnt/c/Users/russk/iCloudDrive/'
alias ffchrome='cd /mnt/c/Users/russk/AppData/Roaming/Mozilla/Firefox/Profiles/3e9qvlk6.dev-edition-default/chrome'
alias Ddump='cd /mnt/c/Users/russk/digital/DGTLHubDump'
# ? how am I going to call powershell from wsl??
# alais powershell=
# obsidian 
# obsidian-export /path/to/my-obsidian-vault /path/to/exported-notes/


# Windows executables
alias pureRef='/mnt/c/Program\ Files/PureRef/PureRef.exe'
alias eagle='/mnt/c/Program\ Files/Eagle/Eagle.exe'
alias gifImageTools='/mnt/c/Program\ Files/GIF\ Image\ Tools.exe'
alias screenToGif='/mnt/c/Program\ Files/ScreenToGif/ScreenToGif.exe'
#web urls##


# ! problem with this????
# TODO I need to fix this this is dumb need to fix this.and search engins need to take in a $argv anyhow there is a web-search pgk maybe i could just use that.
# alias DevientArt='open https://www.deviantart.com/'
# alias startpage='open https://www.startpage.com/en/'
# alias spotifysong='open https://open.spotify.com/'
# alias discordchan='open https://discord.com/channels/'
# alias browsetwitch='open https://www.twitch.tv/directory'
# alias google="web-search google"
# alias stackoverflow="web-search stackoverflow"
# alias github="web-search github"
# alias githubfeed='open https://discord.com/channels/'

# AI  Url's
# alias OpenPhind='open https://www.phind.com/'
# alias downgit='open https://minhaskamal.github.io/DownGit/#/home'
# alias OpenDuck='open https://duckduckgo.com/'
# alias OpenChatGpt='open https://www.chatgpt.com/'
# alias gchat='open https://www.chatgpt.com/'
# alias OpenChatGptWriter='open https://chat.openai.com/g/g-3SIdOvkZx-writer'
# alias gchattW='open https://chat.openai.com/g/g-3SIdOvkZx-writer'
# alias OpenDigitalHub='open https://github.com/DGTL-Hub'
# alias OpenSplashPage='https://snazzy-starship-b11073.netlify.app/'
# alias Opendigdump='open https://dgtl-hub.github.io/DGTLHubDump/'
# alias OpenPerplex='open https://www.perplexity.ai/'
# alias OpenHuggingFaceChat='open https://huggingface.co/chat/'
alias hugchat='open https://huggingface.co/chat/'

#sites that take a search argument
# https://www.deviantart.com/search?q=


#! this dont  work the way it is supposed too.
# function www
#   echo "Select your Search engine:"
#   switch $argv[1]
#       case downgit
#           open https://minhaskamal.github.io/DownGit/#/home
#           ;;
#       case OpenDuck
#           open https://duckduckgo.com/
#           ;;
#       case OpenChatGpt
#           open https://www.chatgpt.com/
#           ;;
#       case gchat
#           open https://www.chatgpt.com/
#           ;;
#       case OpenChatGptWriter
#           open https://chat.openai.com/g/g-3SIdOvkZx-writer
#           ;;
#       case gchattW
#           open https://chat.openai.com/g/g-3SIdOvkZx-writer
#           ;;
#       case OpenDigitalHub
#           open https://github.com/DGTL-Hub
#           ;;
#       case OpenSplashPage
#           open https://snazzy-starship-b11073.netlify.app/
#           ;;
#       case Opendigdump
#           open https://dgtl-hub.github.io/DGTLHubDump/
#           ;;
#       case OpenPerplex
#           open https://www.perplexity.ai/
#           ;;
#       case OpenHuggingFaceChat
#           open https://huggingface.co/chat/
#           ;;
#       case hugchat
#           open https://huggingface.co/chat/
#           ;;
#       case '*'
#           echo "Invalid search engine selection."
#   end
#   echo "Searching for $argv[1]"
# end

#TODO when I fix python deps and install gallery-dl.




#file type Handling
# Extracts any archive(s) (if unp isn't installed)
# extract () {
# 	for archive in $*; do
# 		if [ -f $archive ] ; then
# 			case $archive in
# 				*.tar.bz2)   tar xvjf $archive    ;;
# 				*.tar.gz)    tar xvzf $archive    ;;
# 				*.bz2)       bunzip2 $archive     ;;
# 				*.rar)       rar x $archive       ;;
# 				*.gz)        gunzip $archive      ;;
# 				*.tar)       tar xvf $archive     ;;
# 				*.tbz2)      tar xvjf $archive    ;;
# 				*.tgz)       tar xvzf $archive    ;;
# 				*.zip)       unzip $archive       ;;
# 				*.Z)         uncompress $archive  ;;
# 				*.7z)        7z x $archive        ;;
# 				*)           echo "don't know how to extract '$archive'..." ;;
# 			esac
# 		else
# 			echo "'$archive' is not a valid file!"
# 		fi
# 	done
# }
#     
#################################################
#                 Image Art                         #
# Convert images to other formats

alias convert2webp='mogrify -format webp *'
alias termimg='jp2a --colors --background=light --fill --size=80x40'



# Function to rotate an image                    
# function iRot
#   echo "Select your file:"
#   read -P "File: " file
#   echo "Select your angle:"
#   read -P "Angle: " angle
#   convert $file -rotate $angle $file
# end


###############################################
#
# Example usage:
# To convert JPG images to PNG:
# jpg2png
# To rotate an image:
# rotateImage
# project-specific shorthands



# function readme
#   # Check if the note file exists; create it if it doesn't
#   set note_file "README.txt"
#   touch "$note_file"
  
#   echo "Choose an action:"
#   echo "1. Add a new note."
#   echo "2. View all notes."
#   echo "3. Clear all notes."
#   echo -n "Enter your choice (1/2/3):"  # -n is for no new line.

#   read choice

#   switch $choice
#       case 1
#           echo -n "Enter your note: "
#           read -l user_note

#           echo "(date): $user_note" >> "$note_file"
#           echo "Note added: $user_note"
#       case 2
#           echo "All Notes:"
#           cat "$note_file" 2>/dev/null; and echo "" # Suppress error if file doesn't exist
#       case 3
#           > "$note_file"
#           echo "All notes cleared."
#       case '*'
#           echo "Invalid choice. Please enter 1, 2, or 3."
#   end


alias li=lighthouse
alias lperf 'lighthouse --only-categories=performance'
alias comp 'node build/build-report-components.js && yarn eslint --fix report/renderer/components.js'
alias reportunit 'yarn jest (find report -iname "*-test.js" | grep -v axe)'
# pretty sure watchexec has just won my heart after years of using `entr`
alias reportwatch 'watchexec "node build/build-report-components.js && node build/build-report.js --psi && node build/build-sample-reports.js && echo \$(date) && yarn eslint --fix report/renderer/components.js" && bash core/scripts/copy-util-commonjs.sh'

alias rppunit 'npm run auto-unittest -- --expanded-reporting --mocha-fgrep=Processor\|Timeline\|trace\|Appender\|Handler\|Performance'
alias rppinter 'HTML_OUTPUT_FILE=rppscreenshots.html npm run interactionstest -- --test-file-pattern="*/performance/**"'
alias rppscreen 'HTML_OUTPUT_FILE=rppscreenshots.html third_party/node/node.py --output scripts/test/run_test_suite.js --config test/interactions/test-runner-config.json --mocha-fgrep "[screenshot]" --test-file-pattern="*/performance/**"'

#print a lolcat
alias RGBcat="echo {a..z}{a..z}{a..z} | lolcat"
fastfetch
alias lil_death='cat ~/.config/fish/fish.txt' 
# echo                              "_your files sire..  }"
# echo              "(ツ)_/¯"   "  (ツ)_/¯"   "  (ツ)_/¯"