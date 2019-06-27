#!/usr/bin/env bash
 
if [ $# -eq 0 ]; then
    echo "Git wrapper script that can specify an ssh-key file
Usage:
    git.sh -i ssh-key-file git-command
    "
    exit 1
fi

tmp="$(mktemp -u)"

# remove temporary file on exit
trap "rm -rf $tmp" 0
 
if [ "$1" = "-i" ]; then
    key=$2; shift; shift
    echo "ssh -i \"$key\" \$@" > "$tmp"
    chmod +x "$tmp"
    export GIT_SSH="$tmp"
fi
 
# in case the git command is repeated
[ "$1" = "git" ] && shift
 
# Run the git command
git "$@"
