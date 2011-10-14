if [ -f /etc/bashrc ]; then source /etc/bashrc; fi

# Stolen from /etc/profile in RHEL 7.3
# Lets you add to PATH without duplicating
pathmunge () {
	if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
	   if [ "$2" = "after" ] ; then
	      PATH=$PATH:$1
	   else
	      PATH=$1:$PATH
	   fi
	fi
}

run_local_bashrc() {
  hostname=$(hostname)
  if [ -f ~/.bashrc.${hostname}.$1 ]; then 
    source ~/.bashrc.${hostname}.$1
  fi
}

run_local_bashrc "pre"

[ -f /etc/profile.d/bash-completion ] && . /etc/profile.d/bash-completion

alias grep="grep --color=auto"
alias ls='ls --color=auto'
alias ll='ls --color=auto -lh'
alias lla='ls --color=auto -lhA'
alias llt='ls --color=auto -lhtr'
alias lls='ls --color=auto -lhSr'
alias amke='make' #typo me not
alias jbos='jobs' #typo me not
alias nicest="nice --adjustment=19"
alias wputs='wget -q --output-document=-'
alias hdfs='hadoop fs'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias cd......='cd ../../../../..'
alias cd.......='cd ../../../../../..'
alias cd........='cd ../../../../../../..'


# The following PS1 depends on stuff defined in .git-completion.sh
source ~/.git-completion.sh
export PS1='\u@\h$(__git_ps1 " [%s]") \w\$ '

shopt -s cmdhist # Try to save multiline commands as a single unit.
shopt -s histappend # Append to, rather than overwrite, the history file when bash closes
shopt -s cdspell # Attempt to correct misspellings
shopt -s dirspell 2>/dev/null # Attempt to correct more misspellings
shopt -u mailwarn # I don't care about new mail.
shopt -s globstar 2>/dev/null # Make ** do a recursive wildcard.
shopt -s checkwinsize # Checks the window size after each command and, if necessary, updates the values of LINES and COLUMNS. 

set -o vi # use vi style command editing

# Enable colored man pages. Stolen from http://fahdshariff.blogspot.com/2011/03/my-bash-profile-part-i.html
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

export EDITOR=vim
export SVN_EDITOR=vim

export GITPAGER="less -FXR"

export HISTFILESIZE=99999
export HISTSIZE=$HISTFILESIZE
export HISTTIMEFORMAT='%F %T '

pathmunge "~/bin"

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

run_local_bashrc "post"
unset pathmunge
