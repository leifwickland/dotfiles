if [ -n "$TERM" -a "$TERM" != "dumb" ]; then
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        better_bash=/nfs/project/aarnone/bash/install/bin/bash
        if [ -x $better_bash ] ; then
            exec $better_bash
            if [ "$?" -eq 0 ]; then
                exit # If everything went well with executing the better bash, then when it's done, exit this one.
            fi
        fi
        echo ""
        echo "Sadly, you're running a version of bash from many years ago."
        echo ""
    fi
fi
