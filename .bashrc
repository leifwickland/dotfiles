#!/bin/bash 

# Stick the GNU utils from homebrew at the front of my path so that everything after works.
if [ -d ~/bin/gnubin ]; then PATH=~/bin/gnubin:$PATH ; fi 

if [ -f /etc/bashrc ]; then source /etc/bashrc; fi

# Stolen from /etc/profile in RHEL 7.3
# Lets you add to PATH without duplicating
pathmunge () {
  cleanPath="$(echo "$PATH" | sed -r -e "s@(^|:)$1/*(:|\$)@:@g" -e 's/^://' -e 's/:$//' -e 's/::/:/g')"
  if [ "$2" = "after" ] ; then
     PATH="$cleanPath:$1"
  else
     PATH="$1:$cleanPath"
  fi
}

run_local_bashrc() {
  f=~/.bashrc.local/$(/bin/hostname -s).$1.sh
  if [ -f "$f" ]; then
    source "$f"
  fi
  unset f
}

run_local_bashrc "pre"

[ -f /etc/profile.d/bash-completion ] && source /etc/profile.d/bash-completion

#typo me not
alias gti='git'
alias amke='make'
alias jbos='jobs'
alias mdkir='mkdir'
alias get='git'

alias ls='ls --color=auto'
alias ll='ls --color=auto -lh'
alias lla='ls --color=auto -lhA'
alias llt='ls --color=auto -lhtr'
alias lls='ls --color=auto -lhSr'
alias nicest="nice --adjustment=19"
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'



source ~/.git-completion.sh
source ~/.git-prompt.sh
PS1='\n\u@\h $(__git_ps1 "[%s] ")\w\$ '


shopt -s cmdhist # Try to save multiline commands as a single unit.
shopt -s histappend # Append to, rather than overwrite, the history file when bash closes
shopt -s cdspell # Attempt to correct misspellings
shopt -s dirspell 2>/dev/null # Attempt to correct more misspellings
shopt -u mailwarn # I don't care about new mail.
shopt -s globstar 2>/dev/null # Make ** do a recursive wildcard.
shopt -s checkwinsize # Checks the window size after each command and, if necessary, updates the values of LINES and COLUMNS.


set -o vi # use vi style command editing
if [ "$TERM" != "dumb" ]; then
  stty -ixon # Don't lock up the terminal when Ctrl-S is pressed.
fi

# Shutup OSX about bash being old
export BASH_SILENCE_DEPRECATION_WARNING=1

# Enable colored man pages. Stolen from http://fahdshariff.blogspot.com/2011/03/my-bash-profile-part-i.html
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# I have trouble with vim's attempts to connect to X disconnecting my terminal.
alias vi="vim -X"
alias vim="vim -X"
export EDITOR="vim -X"
export SVN_EDITOR="vim -X"

export GITPAGER="less -FXR"

export HISTFILESIZE=99999
export HISTSIZE=$HISTFILESIZE
export HISTTIMEFORMAT='%F %T '

export GOPATH="$HOME/src/go"

export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:/usr/local/share/man:/usr/share/man

# Complete ssh hostnames by rummaging around in bash history. Idea from http://b.sricola.com/post/16174981053/bash-autocomplete-for-ssh
# Technically this version is wrong because it always grabs the last word on the line, but that was the easiest way to skip past options.
complete -W "$(echo $(grep '^ssh ' ~/.bash_history | sort -u |  sed -r 's/^ssh[[:space:]]+([^[:space:]]+[[:space:]]+)*([^[:space:]]+)[[:space:]]*$/\2/'))" ssh

# Dumps the current git branch.
gitbr() {
  git branch --no-color | grep '[*]' | sed 's/[ *]//g'
}

sshpass() {
  eval $(ssh-agent) && ssh-add
}


cdf() {
  if [ $# -lt 1 ]; then
    echo "Usage: cdf <file>"
    echo "Will change to the directory containing that file."
    echo ""
    return 1
  fi
  dir=$(dirname "$1")
  cd "$dir"
}

# Changes directory to the root directory of the current git repo
cdg() {
  D=`pwd`
  while [ ! -d "$D/.git" -a "$D" != "/" ]; do
    D=$(readlink -f $D/../)
  done
  if [ "$D" == "/" ]; then
    echo "I went all the way to / without finding a .git. Giving up."
  else
    cd "$D"
  fi
}

truncateWithEllipsis() {
  if [ $# -lt 2 ]; then
    echo "Usage: substring word maxLength"
    return 1
  fi
  if [ ${#1} -le $2 ]; then
    echo -n "$1"
  else
    let end=$2-3
    echo -n "${1:0:$end}..."
  fi
}

cleanij() {
  if [ -f "build.sbt" ] ; then 
    find . -name target -type d -exec rm -rf {} \; 
    rm -rf .idea/ .bsp/
  else
    echo "Are you where think you are? I don't see a build.sbt"
  fi
}

#-------------------------------
# String manipulation functions
# Stolen from http://fahdshariff.blogspot.com/2011/03/my-bash-profile-part-iv-functions.html
#-------------------------------

# substring word start [length]
substring() {
    if [ $# -lt 2 ]; then
        echo "Usage: substring word start [length]"
        return 1
    fi
    if [ -z $3 ]
    then
        echo ${1:$2}
    else
        echo ${1:$2:$3}
    fi
}

# length of string
length() {
    if [ $# -ne 1 ]; then
        echo "Usage: length word"
        return 1
    fi
    echo ${#1}
}

# Upper-case
upper() {
    if [ $# -lt 1 ]; then
        echo "Usage: upper word"
        return 1
    fi
    echo ${@^^}
}

# Lower-case
lower() {
    if [ $# -lt 1 ]; then
        echo "Usage: lower word"
        return 1
    fi
    echo ${@,,}
}

# replace part of string with another
replace() {
    if [ $# -ne 3 ]; then
        echo "Usage: replace string substring replacement"
        return 1
    fi
    echo ${1/$2/$3}
}

# replace all parts of a string with another
replaceAll() {
    if [ $# -ne 3 ]; then
        echo "Usage: replace string substring replacement"
        return 1
    fi
    echo ${1//$2/$3}
}

# find index of specified string
index() {
    if [ $# -ne 2 ]; then
        echo "Usage: index string substring"
        return 1
    fi
    expr index $1 $2
}

# Download and extract tar
ctar() {
  taroptions="vx$2"
  if [ $# -lt 1 -o $# -gt 2 -o "${1:0:4}" != "http" ]; then
    echo ""
    echo "Download and extract a tar with '$taroptions'"
    echo "USAGE:"
    echo "  $0 <url> [additional tar options]"
    echo ""
  else
    curl "$1" | tar "$taroptions"
  fi
}

# Download and extract gzipped tar
ctarz() {
  ctar "$1" "z"
}

# Download and extract bzipped tar
ctarj() {
  ctar "$1" "j"
}

macalert() {
  osascript -e "display notification \"$*\""
}

alias grep='grep --color=auto'

run_local_bashrc "post"
pathmunge "$HOME/.local/bin"
pathmunge "$HOME/.sbt/1.0/bin"
pathmunge "/opt/homebrew/bin" 
pathmunge "/opt/homebrew/opt/coreutils/libexec/gnubin"
pathmunge "/opt/homebrew/opt/ed/libexec/gnubin"
pathmunge "/opt/homebrew/opt/findutils/libexec/gnubin"
pathmunge "/opt/homebrew/opt/gawk/libexec/gnubin"
pathmunge "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
pathmunge "/opt/homebrew/opt/gnu-tar/libexec/gnubin"
pathmunge "/opt/homebrew/opt/gnu-which/libexec/gnubin"
pathmunge "/opt/homebrew/opt/grep/libexec/gnubin"
pathmunge "/opt/homebrew/opt/gsed/libexec/gnubin"
pathmunge "/opt/homebrew/opt/libtool/libexec/gnubin"
pathmunge "/opt/homebrew/opt/make/libexec/gnubin"
pathmunge "$HOME/bin" # Ensure ~/bin is first in my path.
unset pathmunge

export PATH=$PATH:/Users/lwickland/.sbt/1.0/bin
