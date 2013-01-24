export HOME=/nfs/users/lwickland
export LD_LIBRARY_PATH=~/src/trunk/rnw/lib/linux_mysql:/nfs/local/linux/lib:/usr/lib
export JAVA_HOME="/nfs/local/linux/jdk/1.6/current/jre"

# The vim in /nfs/project/aarnone/vim/install/bin tries to start X, which busts my terminal.  No X for you.
alias vim='vim -X'

#The bottom of the list appears last in the search order
pathmunge "/bin"
pathmunge "/sbin"
pathmunge "/usr/bin"
pathmunge "/usr/local/bin"
pathmunge "/usr/local/sbin"
pathmunge "/usr/sbin"
pathmunge "~/src/trunk/bin/linux_mysql"
pathmunge "/nfs/local/generic/tools"
pathmunge "/nfs/local/linux/bin"
pathmunge "/home/mysql/current/bin/"
pathmunge "/nfs/local/linux/jdk/1.6/current/bin/"
pathmunge "/nfs/local/linux/git/current/bin"
#pathmunge "/nfs/project/aarnone/tig/install/bin"
#pathmunge "/nfs/project/aarnone/ctags/install/bin"
#pathmunge "/nfs/project/aarnone/vim/install/bin"
#pathmunge "/nfs/project/aarnone/ruby/install/bin"
#pathmunge "/nfs/project/aarnone/python26/install/bin"
#pathmunge "/nfs/project/aarnone/ctags/current/bin"
pathmunge "/nfs/local/linux/gcc-4.2.2/bin"
#The bottom of the list appears first in the search order

# For a reaon I don't understand, the build servers don't drop me into my home directory the way I'd like.
cd $HOME

makecpwithpapi() {
  if [ -d "agedatabase" -a -d "techmail" ]; then
    nice -n 5 make -j 12 PAPI=Y PAPI_MODULES=ConnectPHP clean depend all
  else
    echo "You're in the wrong directory."
  fi
}


export IFDIR=/home/httpd/cgi-bin/leif.cfg/
export LOG=$IFDIR/log/
strl() {
    STRL=`echo "$1" | wc -c | sed 's/ //g'`
    let "STRL -= 1"
    return $STRL
}

# Creates a tr.* file which will enable outlogging
cast() {
    if [ $# -eq 0 ]; then
        echo cast what?
        return 1
    fi
    if [ $# -ge 2 ]; then 
        HOWMUCH=$2
    else
        HOWMUCH="ALL DATE TIME"
    fi

    echo $HOWMUCH > $IFDIR/log/tr.$1
    return 0
}

# Deletes a tr.* file
reel() {
    if [ $# == 0 ]; then
        echo reel what?
        return 1
    fi

    rm $IFDIR/log/tr.$1
    return 0
}

net() {
    pushd $IFDIR/log > /dev/null
    ls -t $1 *.tr 2>/dev/null
    TROUTS=`ls -t *.tr 2>/dev/null | wc -l`
    if [ $TROUTS -eq 0 ]; then
        echo No TROUT in stream
    fi
    popd > /dev/null
}

# Figures out which *.tr file to open
# Takes an argument that is either the Nth previous *.tr file to open (1 based,
# default 1, max 99) or is an expression (of at least 3 characters that will
# evalutate to a single file in the log directory.  If the current directory is
# not the log directory, the expression is prefixed by the path of the log
# directory.  For example troutname 3 would be the third oldest file.
# troutname '*890*.tr' would give you the first file file matching that pattern
# in the log directory
trout() {
    TROUT=

    if [ $# -ge 2 ]; then
        echo "Error: $# files were specified on the command line.  Only the first ($1) will be shown."
        sleep 3s
    fi

    if [ $# == 0 ]; then
        NTH=1
        TROUT=`ls --color=never -t $IFDIR/log/*.tr | head -$NTH | tail -1`
    else
        strl $1
        if [ $STRL -gt 2 ]; then
            if [ "`pwd`" == "$IFDIR" ]; then 
                TROUT=$1
            else
                TROUT=$IFDIR/log/$1
            fi
            strl `echo $1 | grep '[*?]'`
            if [ $STRL -ne 0 ]; then
                TROUT="$TROUT.tr"
                TROUT_COUNT=`ls $TROUT | wc -l | sed 's/ //g'`
                #echo "TROUT_COUNT=$TROUT_COUNT"
                if [ $TROUT_COUNT -gt 1 ]; then
                    echo "Error: $TROUT_COUNT files were named by your pattern.  Only the first will be shown."
                    sleep 3s
                fi
            fi
            NTH=1
            TROUT=`ls --color=never -t $TROUT | head -$NTH | tail -1`
        else 
            NTH=$1
            TROUT=`ls --color=never -t $IFDIR/log/*.tr | head -$NTH | tail -1`
        fi
    fi

    if [ "x" == "x$TROUT" ]; then
        echo 'Error!  TROUT variable is empty'
    else 
        echo "TROUT='$TROUT'"
        if [ ! -e $TROUT ]; then
            echo "Specified file ($TROUT) does not exist"
            TROUT=
        fi
    fi
}

LURE_ED_ARGS='-R -s /nfs/users/ma/lwickland/.bin/.troutIndent.vim'
# Opens the file returned by trout with $EDITOR [$LURE_ED_ARGS]
lure() {
    trout $1
    if [ "x" != "x$TROUT" ]; then
        ~lwickland/bin/troutIndentToFile.pl $TROUT $TROUT.ind
        $EDITOR $LURE_ED_ARGS $TROUT.ind
    fi
}

# Opens the file returned by trout with less
lureless() {
    trout $1
    if [ "x" != "x$TROUT" ]; then
        less $TROUT
    fi
}

# Deletes the *.tr and *.tr.ind files in the log directory
# NOTE: all forms delete *.tr.ind
# usage #1: fish -- deletes *.tr 
# usage #2: fish N -- deletes the N oldest *.tr
# usage #3: fish type -- delete type*.tr.  e.g., fish php deletes php*.tr
# usage #4: fish type N -- delete N oldest type*.tr
fish() {
    if [ $# -eq 0 ]; then 
        WHAT=
        TAIL=
    elif [ $# -eq 1 ]; then
        NUM=`echo "$1" | egrep '[a-zA-Z]' | wc -l`
        if [ $NUM -gt 0 ]; then
            WHAT=$1
            TAIL=
        else
            TAIL="tail -$1"
            WHAT=
        fi
    else 
        WHAT=$1
        TAIL="tail -$2"
    fi
    #echo WHAT=$WHAT
    #echo TAIL=$TAIL
    if [ -z "$TAIL" ]; then
        NUM=`ls -1t $IFDIR/log/$WHAT*.tr 2>/dev/null | wc -l`
    else
        NUM=`ls -1t $IFDIR/log/$WHAT*.tr 2>/dev/null | $TAIL | wc -l`
    fi
    if [ $NUM -gt 0 ]; then
        rm -f $IFDIR/log/xml*.xml*
        rm -f $IFDIR/log/$WHAT*.tr.ind 
        if [ -z "$TAIL" ]; then
            rm -f $IFDIR/log/$WHAT*.tr
        else
            rm -f `ls -t $IFDIR/log/$WHAT*.tr | $TAIL`
        fi
    fi
    echo "$NUM trout caught"
}

function golf() 
{
    if [ -z $1 ]
    then
        echo "USAGE: golf <interface name>"
        return
    fi
    DEVELOPMENT=/home/httpd/cgi-bin/$1.cfg 
    HOSTED=/www/rnt/$1/cgi-bin/$1.cfg/ 
    if [ -d $DEVELOPMENT ] 
    then
        cd $DEVELOPMENT
        pwd
    elif [ -d $HOSTED ]
    then
        cd $HOSTED 
        pwd
    else
        echo "I can't find an interface named $1 at $DEVELOPMENT or $HOSTED"
    fi
}

function gov() 
{
    if [ -z $1 ]
    then
        echo "USAGE: gov <interface name>"
        return
    fi
    DEVELOPMENT=/home/httpd/html/per_site_html_root/$1/
    HOSTED=/www/rnt/$1/vhosts/$1/ 
    if [ -d $DEVELOPMENT ] 
    then
        cd $DEVELOPMENT
        pwd
    elif [ -d $HOSTED ]
    then
        cd $HOSTED 
        pwd
    else
        echo "I can't find a docroot named $1 at $DEVELOPMENT or $HOSTED"
    fi
}

function stv()
{
    /usr/bin/strace $* 2>&1
}

function stq()
{
    /usr/bin/strace $* 2>&1 1>/dev/null
}

#-------------------------------------------------------------------------------
#  Make scripts
#
#  Compile php files, must be in /src directory
#
make_scripts()
{
  if [ `pwd | grep 'scripts/' | grep '/src'` ]
  then
    old_path=$PATH
    new_path="../../../../../bin:$PATH"

    export PATH=$new_path
    make -f ../../makefile_php
    export PATH=$old_path
  else
    echo 'This script runs from <site>/cgi-bin/scripts/*/src'
  fi
}

#-------------------------------------------------------------------------------
#  Make scripts verbosely
#
#  Compile php files, must be in /src directory
#
make_scripts_debug()
{
  if [ `pwd | grep 'scripts/' | grep '/src'` ]
  then
    old_path=$PATH
    new_path="../../../../../bin:$PATH"

    export PATH=$new_path
    make --debug=a -f ../../makefile_php
    export PATH=$old_path
  else
    echo 'This script runs from <site>/cgi-bin/scripts/*/src'
  fi
}

function _bak()
{
    cmd=$1
    if [ -z "$cmd" ] ; then
        echo "You must specify a command"
        return
    elif [ -z "$2" ] ; then
        echo "You must specify a file"
        return
    fi

    while [ -n "$2" ] ; do
        bak=`echo "$2" | sed 's/\/$//'` # Strip trailing slash
        if [ -e "$bak.bak" ] ; then
            echo "$bak.bak already exists.  I won't overwrite it."
            return
        fi
        $cmd "$bak" "$bak.bak"
        ls -dl $bak*
        shift
    done
}

function mvbak() {
    _bak "mv" "$@"
}

function sudomvbak() {
    _bak "sudo mv" "$@"
}

function cpbak() {
    while [ -n "$1" ] ; do
        bak=`echo "$1" | sed 's/\/$//'` # Strip trailing slash
        mvbak "$bak"
        cp -R "$bak.bak" "$bak"
        shift
    done
}

function sudocpbak() {
    while [ -n "$1" ] ; do
        bak=`echo "$1" | sed 's/\/$//'` # Strip trailing slash
        sudomvbak "$bak"
        sudo cp -R "$bak.bak" "$bak"
        find  "$bak" -type d -exec sudo chmod 777 {} \;
        find  "$bak" -type f -exec sudo chmod 666 {} \;
        shift
    done
}

function _unbak() {
    cmd=$1
    while [ -n "$2" ] ; do 
        bak=`echo "$2" | sed 's/\/$//'` # Strip trailing slash
        orig=`echo "$bak" | grep '\.bak$' | sed 's/\.bak$//'`
        if [ -z "$orig" ] ; then
            echo "$2 doesn't appear to end in .bak.  I'm running away."
            return
        fi
        if [ -e "$orig" ] ; then
            echo "$orig already exists.  I won't overwrite it."
            return
        fi
        $cmd "$2" "$orig"
        ls -ld $orig*
        shift
    done
}

function unbak() {
    _unbak "mv" "$@"
}

function sudounbak() {
    _unbak "sudo mv" "$@"
}

function safeeditphp() {
    while [ -n "$1" ] ; do 
        sudomvbak $1.op_codes
        sudocpbak $1
        shift
    done
}

function lslast() {
    ls -tr $1 | tail -n 1
}

function bush() {
    if [ -z "$1" ] ; then 
        echo "Usage: bush widget_name_or_pattern"
        echo ""
        echo "If one match is found, the script will change to that directory."
        echo "If multiple matches are found, they will be printed."
        echo ""
        echo "This must be run from within a scripts/euf direcotry or subdirectory."
        echo ""
        return
    fi
    widget=$1
    realPwd=`pwd -P`
    if [ 0 -eq `pwd -P | grep -P '/scripts/euf(/|$)' | wc -l` ]; then
        echo "You don't appear to be in an euf directory or subdirectory.  You must be to use this function."
        echo ""
        return
    fi
    baseEuf=`pwd -P | sed -r 's@^(.*/scripts/euf).*$@\1@'`
    if [ -z "$baseEuf" ]; then
        echo "Totally unexpected failure."
        echo ""
        return
    fi
    widgetBase="$baseEuf/application/rightnow/widgets" 
    matches=`find $widgetBase -iname "$widget"`
    matchesCount=`echo "$matches" | grep -v -P "^ *$" | wc -l`
    if [ $matchesCount -eq 0 ] ; then
        echo "No widgets matching '$widget' were found in $widgetBase."
    elif [ $matchesCount -eq 1 ] ; then
        prettyWidget=`echo $matches | sed -r 's@.*/scripts/euf/(.*)$@\1@'`
        echo "going to $prettyWidget"
        cd "$matches"
    else
        echo "Multiple matches:"
        for i in $matches; do
            widgetName=`basename $i`
            echo "    $widgetName"
        done
    fi
    echo ""
}

function cdv() {
    if [ $# -lt 1 ]; then
        echo ""
        echo "USAGE: cdv <replacementSegment>"
        echo "" 
        echo "  Example: cdv rnw102"
        echo "" 
        return
    fi
    dirPattern='/(trunk|rnw[0-9]+)(/|$)'
    if [ ! "`pwd -P | grep -P $dirPattern`" ]; then
        echo ""
        echo "You don't appear to be in a path which contains 'trunk' or 'rnwXX'"
        echo ""
        return
    fi
    newSeg=$1
    newdir=`pwd -P | sed -r "s@$dirPattern@/$newSeg/@"`
    cd $newdir
}

