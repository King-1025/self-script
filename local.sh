#!/usr/bin/env bash

SELF=$HOME/self
BIN=$SELF/bin
LIB=$SELF/lib
SCRIPT=$BIN/script

GIT_URL="https://github.com/King-1025/self-script.git"

declare -a MKDIR_LIST=($SELF $BIN $LIB)
declare -a UN_LINK_LIST=(log ohMyzsh local config kalinethunter)

function app()
{
   echo "bootstrap... "
   check_tool git
   check_home
   make_dirs
   get_script
   link_script
   add_config ".bashrc" ".zshrc"
}

function check_home()
{
   if [ -z $HOME ]; then
      echo "\$HOME is not defined! please set it firstly"
      exit 1
   fi
}

function make_dirs()
{
   for path in "${MKDIR_LIST[@]}"; do
          if [ -e $path ]; then
             echo -e "\033[5;34mskip -> $path\033[0m"
	  else
	     echo -e "\033[5;35mmkdir -> $path\033[0m"
	     mkdir "$path" || exit 1
	  fi
   done
}

function check_tool()
{
    local list=""
    for tool in "$@"; do
       echo checking $tool...
       which $tool 2>/dev/null
       if [ $? -ne 0 ]; then
	  echo "$tool not exist, add!"
          list="$list $tool"
       else
	  echo "$tool oK!"
       fi
    done
    if [ "$list" != "" ]; then
       apt update -y && apt install $list -y
    fi
}

function get_script()
{
   rm -rf $SCRIPT && git clone $GIT_URL $SCRIPT -j 4
}

function link_script()
{
   for s in $SCRIPT/*.sh; do
      local t=$(echo $(basename "$s")|awk -F "." '{print $1}')
      eval "echo \"${UN_LINK_LIST[*]}\"|grep -qvE \"$t\""
      [ $? -eq 0 ] && echo -e "\033[5;32mlink -> $t\033[0m" && ln -sf "$s" "$BIN/$t" && continue
      echo -e "\033[5;33mignore -> $t\033[0m"
      rm -rf "$BIN/$t"
   done
}

function add_config()
{
  for n in "$@"; do
     local c="$SCRIPT/config.sh"
     local f="$HOME/$n"
     if [ -e "$f" ]; then
	local r=$(sed -n "/O_o/p" "$f")
	#echo $r
	if [ "$r" != "" ]; then
           echo -e "\033[5;34mskip -> $n\033[0m" && continue
        fi
     fi
     echo "#[O_o]" >> "$f"
     echo ". $c" >> "$f"
     echo -e "\033[5;36mconfig -> $c $2\033[0m"
  done
}

app $*
