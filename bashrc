# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

if [ -z "${SSH_CLIENT}" ]; then
    # start the day the right way
    echo -e "${Black}${On_Cyan}Please enjoy your trip through this door...\n"
    if [ -x /usr/bin/fortune ]; then
        /usr/bin/fortune
    else
        echo "Install fortune!"
    fi
    echo -e "${NC}"

    # set bash prompt
    PS1='\[\e[1;$((42-(($?>0))))m\] $([ $? -eq 0 ] && echo ✔ || echo ✘)'
    PS1="$PS1 \[${NC}\] \[${Blue}\][\u@\h:\[${NC}\]\[${BBlue}\]\w\[${NC}\]\[${Blue}\]]"
    PS2="\[${Blue}\]▶\[${NC}\] "
    PS1="$PS1\n$PS2"
    export PS1
    export PS2
else
    PS1='$([ $? -eq 0 ] && echo ✔ || echo ✘)'
    PS1="$PS1 [ssh \u@\h:\w]"
    PS2="▶ "
    PS1="$PS1\n$PS2"
    export PS1
    export PS2
fi

ps1off() {
    PS1="[\u@\h \W]\$ "
}

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

# open file manager at current dir
FM() { gnome-open "${PWD}" &>/dev/null; }

# open gimp quietly
GIMP() { gimp ${@} &>/dev/null; }

# open eye-of-gnome (eog) quietly
see() { eog ${@} &>/dev/null; }

# set whether to show stbt on screen
stbt-sink() {
  box=$1
  mode=$2
  on='xvimagesink sync=false force-aspect-ratio=true'
  off='fakesink sync=false'
  case $mode in
    'on')
      sed -i -E "s/^(sink_pipeline = ).*$/\1$on/" \
        ~/stb-$box.conf
      ;;
    'off')
      sed -i -E "s/^(sink_pipeline = ).*$/\1$off/" \
        ~/stb-$box.conf
      ;;
  esac
}

# Shorthand for ssh-ing to the box
ssh-to-box() {
    local url="$(stbt config global.network_interface)"
    [[ -n "$url" ]] || {
        echo global.network_interface parameter is missing from stbt config >&2
        return 1
    }
    local params="$(curl -s "$url")"
    local ip="$(echo "$params" | jq -r .box.ip 2>/dev/null)"
    local oem="$(echo "$params" | jq -r .box.oem 2>/dev/null)"

    [[ -n "$ip" ]] || {
        echo Box IP is unknown >&2
        return 1
    }
    [[ -n "$oem" ]] || {
        echo Box OEM is unknown >&2
        return 1
    }
    sshpass -p $(stbt config ${oem}.box_ssh_pass) \
        ssh $(stbt config ${oem}.box_ssh_user)@$ip "$@"
}

# print a random 2dp float being min and max or 0 and max
randnum() {
  local min=0
  local max=1
  case $# in
    2) min=$1; max=$2;;
    1) min=0; max=$1;;
    *) echo "[error] usage: 'randum min max' or 'randnum max'!" >&2; return 1;;
  esac
  [ $min -ge $max ] && { echo "[error] min < max"; return 1; }
  echo "$((min+((RANDOM%((max-min)))))).$((RANDOM%10))$((RANDOM%10))"
}

# randcsv <lines> <max> <title> [<title> [...]]
# produce CSV output of length `lines` and maximum value `max`
# with row length equal to number of `title`s
randcsv() {
  local lines=$1
  local max=$2
  shift; shift
  local titles=''
  for t in "$@"; do
    titles+="$t,"
  done
  local num=$#
  echo "${titles%,}"
  for ((i=0; i<lines; i++)); do
    for ((j=0; j<num-1; j++)); do
      echo -n "$(randnum $max),"
    done; echo "$(randnum $max)"
  done
}

# Nice wrapper for fortune which prints blank lines to the
# bottom of the terminal window.
FORTUNE() {
  local category="$1"
  local text="$(fortune ${category})"
  local num_lines="$(echo "${text}" | wc -l)"
  printf "\ec\n\n\n\n\n${On_Black}${BWhite}%s${NC}\n" "${text}"
  printf "%0.s\n" $(seq 1 $((LINES - ((num_lines + 5)))))
}

# Reverse a `mv` with arguments 1 and 2 being swapped
unmv() {
  mv "${2}" "${1}"
}

get_testcase() {
  python <<-EOF
	import common, testrail
	print common.json_pretty(
	    testrail.TestRail.get_testaut_authed_testrail().get_case('${1}'))
	EOF
}

alias UITESTS="cd $HOME/test-dev/uitests"
# go to stb-tester repo
alias STBT="cd $HOME/stbt-dev/stb-tester"

#-----------------------------#
# Export environment variables
#-----------------------------#

# pathmunge is lifter from /etc/profile
pathmunge() {
  case ":${PATH}:" in
    *:"${1}":*)
      ;;
    *)
      if [ "${2}" = "after" ]; then
        PATH="${PATH}:${1}"
      else
        PATH="${1}:${PATH}"
      fi
  esac
}

pypathmunge() {
  case ":${PYTHONPATH}:" in
    *:"${1}":*)
      ;;
    *)
      if [ "${2}" = "after" ]; then
        PYTHONPATH="${PYTHONPATH}:${1}"
      else
        PYTHONPATH="${1}:${PYTHONPATH}"
      fi
  esac
}

pathmunge "$HOME/test-dev/uitests/tools"
pathmunge "$HOME/repos/zinc-git-tools"

pypathmunge "${HOME}/libexec/stbt"
pypathmunge "${HOME}/test-dev/uitests/library"
pypathmunge "${HOME}/test-dev/uitests/stb-tester"

export PATH PYTHONPATH

export STBT_CONFIG_FILE="${HOME}/vidiu.conf"

docker_env="${HOME}/repos/docker-build-environments/docker-env.sh"
[ -f "${docker_env}" ] && source "${docker_env}"
unset docker_env


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
