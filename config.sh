#!/usr/bin/env bash

export TERMUX_ROOT=/data/data/com.termux
export TERMUX_PREFIX=$TERMUX_ROOT/files/usr
export TERMUX_HOME=$TERMUX_ROOT/files/home

export SELF=$TERMUX_HOME/self
export PATH=$PATH:$SELF/bin:$SELF/sbin:$SELF/bin/busybox
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SELF/lib:$SELF/lib64

export SCRIPT=$SELF/bin/script
export KALI_HOME=$TERMUX_HOME/kali-arm64

export OO=/storage/sdcard0/O_o

alias 91="91_spider"
alias vse="if [ -f out.html ];then cp out.html $OO|android view -f $OO/out.html;else echo Sorry,not found out.html!;fi"
alias v91="91 -r 0 3 -p 10 -ll i -ls middle -t html -o out.html;vse"
alias sc="cd $SCRIPT"
alias gvs="git status"
alias gaa="git add ."
alias gm="git commit -m"
alias uf="update_termux_font"
alias fhp="find_httpd_pid"
alias kh="kill_httpd"
alias klh='cd $KALI_HOME/root'
alias kali="exec_command_by_proot $KALI_HOME" 
alias skl="kali bash"

function exec_command_by_proot()
{
  if [ $# -gt 1 ]; then
    local sysdir=$1
    shift 1
    unset LD_PRELOAD
    proot --link2symlink -0 -r $sysdir -b /dev/ -b /sys/ -b /proc/ -b $TERMUX_HOME:/termux -w /root /usr/bin/env -i HOME=/root USER=root TERM="xterm-256color" LANG=en_US.UTF-8 PATH=/bin:/usr/bin:/sbin:/usr/sbin $@
  else
    echo "need at least 2 arguments!"
  fi
}

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
        cp -fr "$1" "$TERMUX_HOME/.termux/font.ttf";
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
