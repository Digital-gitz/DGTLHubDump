#!bin/fish
#######  _    _ _           _  ##########
#       _    _ _           _       _
#      / \  | | |   __ _  (_)___  ( )___
#     / _ \ | | |  / _` | | / __| |// __|
#    / ___ \| | | | (_| | | \__ \   \__ \
#   /_/   \_\_|_|  \__,_| |_|___/   |___/
#########################################

# need to make this universal
alias xosh='source ~/.config/fish/config.fish'  # reload shell
alias resh='source ~/.config/fish/config.fish'  # reload shell
# ERROR:  I need to fix this to work with the new fish shell.
alias fishie='sudo cd ~ && sudo code-insiders .'

#go to  user bin
alias usebin='cd /usr/local/bin/'

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
alias newfile='sudo touch'              # create a new file
alias lf="ls -l | egrep -v '^d'"        # files only
alias ldir="ls -l | egrep '^d'"         # directories only
alias clr='clear -x'
alias cls='clear'                       
alias home='cd ~ && pwd'
alias root='cd / && pwd'

#uninstall and or remove a package
alias uninstall='sudo apt remove'  # remove a package from apt package manager.
alias rm='sudo rm -iv'             # ignore nonexistent files, prompt before every removal + explain what is being done.
alias rmdir='sudo rm -Rfv'         # remove empty directories.
alias h="history | grep "
alias pacd="sudo pacman -Syu"      #download pkg 
alias pacs="sudo pacman -Ss"       #searh pkgs
alias yodow=" yay -Syu"            #download pkg
alias yosee=" yay -Ss"             #search pkgs
# TODO:  Downgit need to write this in a function prompt moselikely....  
alias downgit='https://minhaskamal.github.io/DownGit/#/home?url='  # ? will I need a completion  for this?
#? man what the fuck is going on here...... why is it opening microsoft store
#? and why dose firefox open my donuments. 
alias monkwr='open moz-extension://574700a5-f4dd-44e7-b728-2a1d217a5a18/options.html#url=aHR0cHM6Ly9naXRodWIuY29tL2Rhc2hib2FyZA==&nav=dashboard'
###github
alias gs='git status'                                                                           # View Git status.
alias ga='git add'                                                                               # Add a file to Git.
alias gaa='git add --all'                                                                       # Add all files to Git.
alias gc='git commit'                                                                           # Commit changes to the code.
alias gl='git log --oneline'                                                                    # View the Git log.
alias gb='git checkout -b'                                                                       # new Git branch and move to new branch at same time.
alias gd='git diff'                                                                              # View the difference between the current branch and the master branch.
alias ghv='gh repo view'            	                                                         #Vew details about a repository.
alias ghs='gh search repos'         	                                                         #search for a github repository.
alias ghl='gh repo list'             	                                                         #Get a list of my repositorys.
alias ghr='gh repo rename'		                                                                 #rename a repo.
alias ghc='gh repo clone'		                                                                  #clone a repo.
alias gh_del='gh repo delete'		                                                              #delete a repo.
alias ghdrip='git status; git add .; git status; git commit -a -m "droppin some \.\.\.\.\. dribs"' #add and commit all changes. 

# Show current network information #
# Show current network connections to the server 
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"
# Show open ports
alias openports='netstat -nape --inet'

#System Information
# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4 | head -5'

# get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3 | head -5'

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
# Windows executables
alias pureRef='/mnt/c/Program\ Files/PureRef/PureRef.exe'
alias eagle='/mnt/c/Program\ Files/Eagle/Eagle.exe'
alias gifImageTools='/mnt/c/Program\ Files/GIF\ Image\ Tools.exe'
alias screenToGif='/mnt/c/Program\ Files/ScreenToGif/ScreenToGif.exe'
#web urls##
#  select a search engine to open and open it in the default browser.
function web-search
  open "https://www.google.com/search?q=$argv"
end

alias hugchat='open https://huggingface.co/chat/'
#################################################
#                 Image Art                         #
# Convert images to other formats
alias convert2webp='mogrify -format webp *'
alias termimg='jp2a --colors --background=light --fill --size=80x40'

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