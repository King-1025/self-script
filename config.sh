#!/usr/bin/env bash

export PATH=$PATH:$HOME/self/bin

export OO=/sdcard/oo
export DL=/sdcard/Download
export SC=$HOME/self/bin/script

alias 91="91_spider"
alias vse="if [ -f out.html ];then cp out.html $OO|android view -f $OO/out.html;else echo Sorry,not found out.html!;fi"
alias v91="91 -r 0 3 -p 10 -ll i -ls middle -t html -o out.html;vse"
alias oo="cd $OO"
alias dl="cd $DL"
alias sc="cd $SC"
alias gvs="git status"
alias gaa="git add ."
alias gm="git commit -m"
