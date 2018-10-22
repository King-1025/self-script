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
alias uf="update_termux_font"

function solve_vim_charset()
{
echo "set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
set enc=utf8
set fencs=utf8,gbk,gb2312,gb18030"
}

function update_termux_font()
{ 
  if [ $# -eq 1 ]; then
     if [ -e $1 ];then
        cp -fr "$1" "$HOME/.termux/font.ttf";
	termux-reload-settings
     else
	echo "not exist $1"
     fi
  else
	echo "only need one argument!"
  fi
}
