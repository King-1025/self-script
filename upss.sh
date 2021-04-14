#!/usr/bin/env bash

#set -x

ROOT="$HOME"
STORE_FILE="$ROOT/.up_store"
DEFAULT_TAG=oo
DEFAULT_HOST=47.93.58.31
ONLY_EXECUTE_COMMAND_ON_SSH=0

function app()
{
   parse_args $*
}

function parse_args()
{
  declare -a args=("$@")
  local length=${#args[@]}
  for ((i=0;i<$length;i++)); do
     let j=i+1
     local may_value=${args[j]}
     case "${args[i]}" in
        "-f"|"--file")
	   echo "$may_value" | grep -E "^[-|\-\-]" > /dev/null 2>&1
	   if [ $? -eq 1 ]; then
              STORE_FILE=$may_value
	   else
	      echo "invalid value:$may_value"
	      exit 1
	   fi
	 ;;
         "-t"|"--tag")
	    TAG=$may_value
	 ;;
         "-m"|"--mode")
	    MODE=$may_value
	 ;;
         "-h"|"--host")
	    HOST=$may_value
	 ;;
         "-p"|"--port")
	    PORT=$may_value
	 ;;
         "-e"|"--execute-command")
	    ONLY_EXECUTE_COMMAND_ON_SSH=1
	 ;;
         "-dt")
	    TAG=$DEFAULT_TAG
	 ;;
         "-dh")
	    HOST=$DEFAULT_HOST
	 ;;
         "push")
	    #set -x
	    auto_push $(ask_mode)
	    break
	 ;;
         "pull")
	    #set -x
	    auto_pull $(ask_mode)
	    break
	 ;;
         "ssh")
	    local host=$HOST
            if [ "$host" == "" ]; then
	       read -p "please input ssh host: " host
	    fi
	    local port=$PORT
	    if [ "$port" == "" ]; then
	       port=22
	    fi
	    local command_chunk=""
	    if [ $ONLY_EXECUTE_COMMAND_ON_SSH -eq 1 ]; then
#	       set -x
	       for ((p=$j;p<$length;p++)); do
                  command_chunk+="${args[p]} "
               done
	       unset p
#	       set +x
	    fi
	    auto_ssh $(ask_mode) "$host" "$port" "$command_chunk"
	    break
	 ;;
         "scp")
	    local host=$HOST
            if [ "$host" == "" ]; then
	       read -p "please input scp host: " host
	    fi
	    local port=$PORT
	    if [ "$port" == "" ]; then
	       port=22
	    fi
	    local vc=$((length-j))
            if [ $vc -ge 3 ]; then
	       local options=""
	       local m=$((j+1))
	       local n=$((length-2))
	       for ((p=$m;p<$n;p++)); do
                  options+="${args[p]} "
               done
	       unset p
	       auto_scp $(ask_mode) "$host" "$port" "${args[j]}" "${args[length-2]}" "${args[length-1]}" "$options"
	    fi
	    break
	 ;;
         "store")
            add_account
	    break
	 ;;
         "ask")
            ask_mode
	    break
	 ;;
     esac
  done
}

function ask_mode()
{
    if [ "$TAG" != "" ]; then
       echo $(ask_mode_t auto $TAG)
    else
      if [ "$MODE" != "" ]; then
         echo $(ask_mode_t "$MODE")
      else
         echo $(ask_mode_t "tag")
      fi
    fi
}

function ask_mode_t()
{
  if [ $# -ge 1 ]; then
     local mode=$1
     local tag=$2
     local site=$3
     local abort=0
     case "$mode" in
	 "tag")
            read -p "please input tag: " tag
	 ;;
	 "site")
            read -p "please input protocol: " protocol
            read -p "please input host: " host
            protocol=$(echo "$protocol" | sed "s/protocol=//")
            host=$(echo "$host" | sed "s/host=//")
            site=$(echo "$protocol:$host" | base64 | md5sum | awk '{print $1}')
         ;;
         "auto")
	    mode="tag"
	 ;;
         *) abort=1
	 ;;
     esac
     if [ $abort -eq 0 ]; then
        #printf "protocol=%s\nhost=%s\n" "$protocol" "$host"
        local account=$(query_account "$mode" "$tag" "$site")
        if [ $? -eq 0 ]&&[ "$account" != "" ]; then  
           local value=$(echo "$account" | base64 -d)
           if [ $? -eq 0 ]; then
              printf "\n%s %s\n" $(echo "$value" | awk -F ":" '{print $1}') $(echo "$value" | awk -F ":" '{print $2}' | base64 -d)
           fi
        fi
     fi
  fi
}

function auto_pull()
{
   if [ $# -eq 2 ]; then
    local username=$1
    local password=$2
    local tmp=$(mktemp -u)
    echo "set timeout 120"      >> $tmp
    echo "spawn git pull"       >> $tmp
    echo "expect Username"      >> $tmp
    echo "send \"$username\r\"" >> $tmp
    echo "expect Password"      >> $tmp
    echo "send \"$password\r\"" >> $tmp
    echo "expect off"           >> $tmp
    expect -f $tmp
    rm -rf $tmp
    git status
   else
    echo "auto_pull only needs 2 arguments!"
  fi
}

function auto_push()
{
   if [ $# -eq 2 ]; then
    local username=$1
    local password=$2
    local tmp=$(mktemp -u)
    echo "set timeout 120"      >> $tmp
    echo "spawn git push"       >> $tmp
    echo "expect Username"      >> $tmp
    echo "send \"$username\r\"" >> $tmp
    echo "expect Password"      >> $tmp
    echo "send \"$password\r\"" >> $tmp
    echo "expect off"           >> $tmp
    expect -f $tmp
    rm -rf $tmp
    git status
   else
    echo "auto_push only needs 2 arguments!"
  fi
}

function auto_ssh()
{
   if [ $# -eq 5 ]; then
    local username=$1
    local password=$2
    local host=$3
    local port=$4
    local comm=$5
    local tmp=$(mktemp -u)
    echo "set timeout 120"                    	       >> $tmp
    echo "spawn ssh ${username}@${host} -p ${port} \"${comm}\""   >> $tmp
    echo "expect password"                             >> $tmp
    echo "send \"$password\r\""                        >> $tmp
    if [ "$comm" = "" ]; then
       echo "interact"                                 >> $tmp
    else
       echo "expect off"                               >> $tmp
    fi
    expect -f $tmp
    rm -rf $tmp
   else
    echo "auto_ssh only needs 4 arguments!"
  fi
}

function auto_scp()
{
  if [ $# -eq 8 ]; then
    local remote="$1@$3"
    local password=$2
    local host=$4
    local method=$5
    local p1=$6
    local p2=$7
    local opt=$8
    local comm=""
    case "$method" in
	 "dl") comm="$opt $remote:$p1 $p2";;
	 "up") comm="$opt $p1 $remote:$p2";;
	  "*") comm="";;
    esac
    if [ "$comm" != "" ]; then
       echo $comm
       #exit
       #set -x
       local tmp=$(mktemp -u)
       echo "set timeout 120"         >> $tmp
       echo "spawn scp -P ${port} ${comm}"   >> $tmp
       echo "expect \"$remote*\""          >> $tmp
       echo "send \"$password\r\""      >> $tmp
       echo "expect off"              >> $tmp
       expect -f $tmp
       rm -rf $tmp
       set +x
    fi
   else
    echo "auto_ssh only needs 7 arguments!"
  fi
}

function query_account()
{
  if [ $# -ne 3 ]; then exit 1; fi
  local mode=$1
  local tag=$2
  local site=$3
  if [ -e "$STORE_FILE" ]; then
    account=$(awk -F ":" \
    -v mode="$mode" -v tag="$tag" -v site="$site" '{
      if(NF == 3){
	if(mode == "tag"){
          if($1 == tag){
            value=$3
	  }
        }else if(mode == "site"){
          if($2 == site){
	    value=$3
          }
        }
      }
     } END{print value}' $STORE_FILE)
  fi
  echo "$account"
}

function add_account()
{
  if [ "$STORE_FILE" != "" ]; then
    local value=""
    while true ; do
       read -p "tag: " tag
       echo "$tag" | grep -E ":" > /dev/null 2>&1
       if [ $? -eq 0 ]; then echo "invalid tag:$tag"; continue; fi
       read -p "site: " site
       site=$(echo "$site" | sed "s/\/\///" | base64 | md5sum | awk '{print $1}')
       read -p "account: " account
       value+="${account}:"
       read -p "password: " password
       value+="$(echo $password | base64)"
       value=$(echo "$value" | base64)
       echo "$tag:$site:$value" >> $STORE_FILE
       echo "add ok!"
       break # once
    done
  else
    echo "store file is invalid!"
    exit 1	
  fi
}

app $*
