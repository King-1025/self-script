#!/usr/bin/env bash

#set -x

ROOT="$HOME"
STORE_FILE="$ROOT/.up_store"
DEFAULT_TAG=king
USE_TAG=1
USE_DEFAULT_TAG=0

function parse_args()
{
  declare -a args=("$@")
  local length=${#args[@]}
  for ((i=0;i<$length;i++)); do
     let j=i+1
     local may_value=${args[$j]}
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
         "-s"|"--site")
	    USE_TAG=0
	 ;;
         "-d"|"--default-tag")
	    USE_DEFAULT_TAG=1
         ;;
         "push")
             if [ $USE_TAG -eq 1 ]; then
                mode="only_tag"
		if [ $USE_DEFAULT_TAG -eq 0 ]; then
                   read -p "please input tag:" tag
	        else
		   tag=$DEFAULT_TAG
		   echo "use default tag:$tag"
		fi
		echo ""
             else
                mode="only_site"
                read -p "please input protocol:" protocol
                read -p "please input host:" host
                protocol=$(echo "$protocol" | sed "s/protocol=//")
                host=$(echo "$host" | sed "s/host=//")
                site=$(echo "$protocol:$host" | base64 | md5sum | awk '{print $1}')
		echo ""
#		printf "protocol=%s\nhost=%s\n" "$protocol" "$host"
            fi
	    local account=$(query_account "$mode" "$tag" "$site")
	    if [ $? -eq 0 ]&&[ "$account" != "" ]; then  
               local value=$(echo "$account" | base64 -d)
               if [ $? -eq 0 ]; then
                 auto_push $(echo "$value" | awk -F ":" '{print $1}') $(echo "$value" | awk -F ":" '{print $2}' | base64 -d)
               fi
	    fi
	 ;;
         "store")
            add_account
	    break
	 ;;
     esac
  done
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
	if(mode == "only_tag"){
          if($1 == tag){
            value=$3
	  }
        }else if(mode == "only_site"){
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
    read -p "tag:" tag
    echo "$tag" | grep -E ":" > /dev/null 2>&1
    if [ $? -eq 0 ]; then echo "invalid tag:$tag"; continue; fi
    read -p "site:" site
    site=$(echo "$site" | sed "s/\/\///" | base64 | md5sum | awk '{print $1}')
    read -p "account:" account
    value+="${account}:"
    read -p "password:" password
    value+="$(echo $password | base64)"
    value=$(echo "$value" | base64)
    echo "$tag:$site:$value" >> $STORE_FILE
    echo "add ok!"
    break
    done
  else
    echo "store file is invalid!"
    exit 1	
  fi
}

parse_args $*
