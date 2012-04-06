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
  f=~/.bashrc.local/$(hostname).$1.sh
  if [ -f $f ]; then
    source $f
  fi
  unset f
}

run_local_bashrc "pre"

[ -f /etc/profile.d/bash-completion ] && . /etc/profile.d/bash-completion

#typo me not
alias amke='make'
alias jbos='jobs'
alias mdkir='mkdir'

export GREP_OPTIONS="$GREP_OPTIONS --color=auto"
alias ls='ls --color=auto'
alias ll='ls --color=auto -lh'
alias lla='ls --color=auto -lhA'
alias llt='ls --color=auto -lhtr'
alias lls='ls --color=auto -lhSr'
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
__truncated_git_ps1() {
  g=$(__git_ps1)
  # __get_ps1 returns a string like: " (branchName)"
  # The following syntax doesn't work in Bash 3.  Don't care.
  let e=${#g}-3 #so strip the leading space and both parens
  if [ $e -gt 0 ]; then # If we're not in a git repo, don't put mention it.
    echo -n "[$(truncateWithEllipsis ${g:2:e} 20)] "
  fi
}
export PS1='\u@\h $(__truncated_git_ps1)\w\$ '

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

# Complete ssh hostnames by rummaging around in bash history. Idea from http://b.sricola.com/post/16174981053/bash-autocomplete-for-ssh
# Technically this version is wrong because it always grabs the last word on the line, but that was the easiest way to skip past options.
complete -W "$(echo $(grep '^ssh ' ~/.bash_history | sort -u |  sed -r 's/^ssh[[:space:]]+([^[:space:]]+[[:space:]]+)*([^[:space:]]+)[[:space:]]*$/\2/'))" ssh

pathmunge "~/bin"

# Dumps the current git branch.
gitbr() {
  git branch --no-color | grep '[*]' | sed 's/[ *]//g'
}

cdr() {
  if [ $# -lt 2 ]; then
    echo "Usage: cdr <segment to match> <replacement" 1>&2
    echo "Changes to the directory that is formed by replacing the specified segment with the replacement." 1>&2
    echo "" 1>&2
    return 1
  fi
  end='$'
  newdir=`pwd | sed -r "s@/$1(/|$end)@/$2/@"`
  if [ "$newdir" == "`pwd`" ]; then
    echo "ERROR: I couldn't find '$1' in $(pwd)." 1>&2
    echo "" 1>&2
    return 1
  else
    cd "$newdir"
  fi
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

run_local_bashrc "post"
unset pathmunge
