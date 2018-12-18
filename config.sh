#!/usr/bin/env bash

export TERMUX_ROOT=/data/data/com.termux
export TERMUX_PREFIX=$TERMUX_ROOT/files/usr
export TERMUX_HOME=$TERMUX_ROOT/files/home

export SELF=$TERMUX_HOME/self
export PATH=$PATH:$SELF/bin:$SELF/sbin:$SELF/bin/busybox
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SELF/lib:$SELF/lib64

export SCRIPT=$SELF/bin/script
export KALI_HOME=$TERMUX_HOME/kali-arm64

export SD=/storage/sdcard0
export OO=$SD/O_o
export DL=$SD/Download
export QQ=$SD/tencent/QQfile_recv

alias sc="cd $SCRIPT"
alias sd="cd $SD"
alias oo="cd $OO"
alias dl="cd $DL"
alias qq="cd $QQ"
alias 91="91_spider"
alias vse="if [ -f out.html ];then cp out.html $OO|android view -f $OO/out.html;else echo Sorry,not found out.html!;fi"
alias v91="91 -r 0 3 -p 10 -ll i -ls middle -t html -o out.html;vse"
alias gvs="git status"
alias gaa="git add ."
alias gm="git commit -m"
alias uf="update_termux_font"
alias fhp="find_httpd_pid"
alias kh="kill_httpd"
alias klh='cd $KALI_HOME/root'
alias kali="exec_command_by_proot --no-exec $KALI_HOME" 
alias skl="exec_command_by_proot --exec $KALI_HOME /bin/bash --login"
alias ten="trt use baidu -t en"
alias tzh="trt use baidu -t zh"
alias tjp="trt use baidu -t jp"
alias aup="upss -dt push"                                                          alias ash="upss -dt -dh -e ssh"
alias ipk="if [ -e "output/signed-debug.apk" ]; then cp "output/signed-debug.apk" $
OO/1.apk && android install $OO/1.apk; fi"

function exec_command_by_proot()
{
#  set -x
  if [ $# -gt 2 ]; then
    local mode=$1
    if [ "$mode" = "--exec" ]; then
        mode="exec"
    elif [ "$mode" = "--no-exec" ]; then
        mode=""
    else
      echo "not found mode:$mode!"
      exit 1
    fi
    local sysdir=$2
    shift 2
    unset LD_PRELOAD
    $mode proot --link2symlink -0 -r $sysdir -b /dev -b /proc -b /sys -b $TERMUX_HOME:/termux -w /root /usr/bin/env -i HOME=/root USER=root TERM="xterm-256color" LANG=en_US.UTF-8 PATH=/bin:/usr/bin:/sbin:/usr/sbin $@
  else
    echo "need at least 3 arguments!"
  fi
#  set +x
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

function upf()
{
  declare -a files=("$@")
  for ((i=1;i<=${#files[@]};i++)); do
    local f=${files[i]}
    if [ -e "$f" ]; then
	echo -n "upload $f..."
        sf put .tmp/$(basename "$f") "$f" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
           echo "ok!"
        else
           echo "faild!"
        fi
    else
	echo "${f} is not exist! pass it"
    fi
  done
}

function dlf()
{
  declare -a files=("$@")
  for ((i=1;i<=${#files[@]};i++)); do
    local f=${files[i]}
    local n=./$(basename "$f")
    local opt="yes"
    if [ -e "$n" ]; then
       local tmp=$(mktemp -u)
       echo "read -p \"${n} is exist! overwrite?(yes/no)\" opt" > $tmp
       echo "echo \$opt" >> $tmp
       chmod +x $tmp
       while true; do
         opt=$(sh $tmp)
	 if [ "$opt" = "yes" ]||[ "$opt" = "no" ]; then
	    rm -rf $tmp
	    break
	 fi
       done
    fi
    if [ "$opt" = "no" ]; then echo "pass ${f}..."; continue; fi
    echo -n "download $f..."
    sf get "$n" ".tmp/$f" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
       echo "ok!"
    else
       echo "faild!"
    fi
  done
}

