#!/usr/bin/env bash

export PATH=$PATH:$HOME/self/bin

#export OO=/sdcard/oo
#export DL=/sdcard/Download
export OO=/storage/sdcard0/O_o
export DL=/storage/sdcard0/Download
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
alias fhp="find_httpd_pid"
alias kh="kill_httpd"

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

function find_httpd_pid()
{
  echo $(ps -ef | grep httpd | grep -v grep | awk '{print $1}')
}

function kill_httpd()
{
   local pid=$(find_httpd_pid)
   if [ ! -z $pid ]; then
     echo "kill httpd:$pid"
     kill -9 $pid
   else
     echo "not found httpd process!"
   fi
}
