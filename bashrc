# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# set bash prompt
face0() { echo ' ✔ '; }
face1() { echo ' ✘ '; }
PS1_1='\[\e[1;$((42-(($?>0))))m\]$(face$(($?>0)))\[\e[00m\]'
PS1_2='\[\e[0;34m\][\h:\[\e[00m\]\[\e[1;34m\]\W\[\e[00m\]\[\e[0;34m\]]\$\[\e[00m\] '
export PS1="$PS1_1 $PS1_2"
ps1off() {
    PS1="[\u@\h \W]\$ "
}

# run this when terminal starts so that other users (namely stb-tester) have access to my stuff
xhost +

#------------------------------------#
# User specific aliases and functions
#------------------------------------#
# ls dirs first with color
alias ls="ls -h --group-directories-first --color=auto"
# ll lists details
alias ll="ls -l"
# la list hidden
alias la='ls -a'

# always parent
alias mkdir='mkdir -p'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias pypath='echo -e ${PYTHONPATH//:/\\n}'

# disk usage
alias du='du -kh'
alias df='df -kTh'

# function then alias means that whenever I cd, I get the cd dir's contents
cdd() { cd $1 && ls; }
alias cd=cdd

# asks for confirmation for every delete
alias rm="rm -i"

# does an ls after a clear
cls() { clear # incase any programs have closed
    clear && ls; }
alias clear=cls

# taken from http://soft.zoneo.net/Linux/remove_backup_files.php
# finds all instances of backup files (that end with ~) and deletes them
rmb() { find ./ -name '*~' | xargs rm; }

Sleep() {
    v="$1"
    u=1
    while [ "$u" -le "$v" ]; do
        echo -en "Sleeping $u \r"
        sleep 1
        ((++u))
    done
    echo
}

# search for process, uses pid to kill -9
ekill() {
    if [ "$#" -ne 1 ]; then
        echo "only takes ones arg!";
        exit 1
    fi
    proc="$1"
    ps aux | \
    grep -e "$proc" |\
    grep -v grep |\
    awk '{print $2}' |\
    xargs -i kill -9 {}
}

# shows debug images from stbt templatematch
DEBUG() {
    if [ -d "stbt-debug" ]; then
        eog $(find -path ./stbt-debug/*/*.png)
    else
        echo "No stbt-debug directory!"
    fi
}

# go to uitests repo
alias UITESTS="cd $HOME/test-dev/uitests"
# go to stb-tester repo
alias STBT="cd $HOME/stbt-dev/stb-tester"


#-----------------------------#
# Export environment variables
#-----------------------------#
export PYTHONPATH="$HOME/test-dev/uitests/library":"$HOME/libexec/stbt/":$PYTHONPATH
export PYTHONPATH="/usr/libexec/stbt/":$PYTHONPATH
export PATH="$HOME/test-dev/uitests/tools/":"$HOME/bin":$PATH
export CDPATH="$HOME"

#-------------------------#
# Infinite history in bash
#-------------------------#
# Append to ~/.bash_history instead of overwriting it -- this stops terminals
# from overwriting one another's histories.
shopt -s histappend
## The following HISTSIZE & HISTFILESIZE settings don't work because bash sets
## HISTFILESIZE later in the startup process. See
## http://old.nabble.com/Re%3A-%22unset-HISTFILESIZE%22-not-working-in-.bashrc-p22030981.html
## Setting HISTFILESIZE to a large number (with a small HISTSIZE) doesn't seem
## to work either.
## # Only load the last 1000 lines from your ~/.bash_history -- if you need an
## # older entry, just grep that file.
## HISTSIZE=1000
## # Don't truncate ~/.bash_history -- keep all your history, ever.
## unset HISTFILESIZE
HISTSIZE=1000000000
# Add a timestamp to each history entry.
HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S  "
# Don't remember trivial 1- and 2-letter commands.
HISTIGNORE=?:??
# What it says.
HISTCONTROL=ignoredups
# Save each history entry immediately (protects against terminal crashes/
# disconnections, and interleaves commands from multiple terminals in correct
# chronological order).
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# Command completion
source /usr/share/bash-completion/bash_completion
