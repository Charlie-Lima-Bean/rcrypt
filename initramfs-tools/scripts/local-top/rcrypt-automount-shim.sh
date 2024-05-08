#!/bin/sh

PREREQ=""

prereqs()
{
    echo "$PREREQ"
}

case "$1" in
    prereqs)
        prereqs
        exit 0
        ;;
esac
# -------

/rcrypt/bin/rcrypt-automount.sh /
exit 0
