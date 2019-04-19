#!/usr/bin/env bash

SELF=self
BIN=$SELF/bin
SCRIPT=$BIN/script
LIB=$SELF/lib

LINK_RULE="local config kalinethunter log ohMyzsh"

function add_config()
{
  if [ $# -eq 2 ]; then
     local c="$1/$SCRIPT/config.sh"
     local f="$1/$2"
     if [ -e "$f" ]; then
	local r=$(sed -n "/O_o/p" "$f")
	#echo $r
	if [ "$r" != "" ]; then
           return
        fi
     fi
     echo "#[O_o]" >> "$f"
     echo ". $c" >> "$f"
     echo -e "\033[5;36mconfig -> $c $2\033[0m"
  fi
}

function link_script()
{
   if [ $# -eq 1 ]; then
    for s in $1/$SCRIPT/*.sh; do
      local t=$(echo $(basename "$s")|awk -F "." '{print $1}')
      eval "echo \"$LINK_RULE\"|grep -qvE \"$t\""
      [ $? -eq 0 ] && echo -e "\033[5;32mlink -> $t\033[0m" && ln -sf "$s" "$1/$BIN/$t" && continue
      echo -e "\033[5;33mignore -> $t\033[0m"
      rm -rf "$1/$BIN/$t"
    done
   fi
}

function fix_script()
{
   if [ $# -eq 1 ]; then
     local cur=$(pwd)
     if [ "$cur" != "$1/$SCRIPT" ]; then
        echo -e "\033[5;37mfix -> $1/$SCRIPT\033[0m"
        mv "$cur" "$1/$SCRIPT"
     fi
   fi
}

function make_dirs()
{
   if [ $# -eq 1 ]; then
      for p in $1/{$SELF,$BIN,$LIB}; do
          if [ -e $p ]; then
             echo -e "\033[5;34mskip -> $p\033[0m"
	  else
	     echo -e "\033[5;35mmkdir -> $p\033[0m"
	     mkdir "$p" || exit 1
	  fi
      done
   fi
}

function bootstrap()
{
   local loc=$HOME
   if [ -z $loc ]; then
      echo "HOME is not defined! please set it firstly"
      exit 0
   fi
   make_dirs "$loc"
   fix_script "$loc"
   link_script "$loc"
   add_config "$loc" ".bashrc"
   add_config "$loc" ".zshrc"
}

echo "bootstrap... "
bootstrap
echo "ok!"
