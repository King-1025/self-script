#!/usr/bin/env bash

TAG=test0
HOST=39.106.72.49
PORT=22

function auto_rsync()
{
   if [ $# -eq 7 ]; then
    local username=$1
    local password=$2
    local host=$3
    local port=$4
    local left=$5
    local right=$6
    local flag=$7
    local tmp=$(mktemp -u)
    echo "set timeout 120"      >> $tmp
    local comm="spawn rsync -avP -zz -e \"ssh -p ${port}\""  
    if [[ $flag -ge 1 ]]; then
      comm="$comm ${left} ${username}@${host}:${right}"
    else
      comm="$comm ${username}@${host}:${right} ${left}"
    fi
    echo "$comm"                >> $tmp
    echo "expect password"      >> $tmp
    echo "send \"$password\r\"" >> $tmp
    echo "expect off"           >> $tmp
    expect -f $tmp
    rm -rf $tmp
   else
    echo "auto_push only needs 7 arguments!"
  fi
}

auto_rsync $(upss -t $TAG ask) $HOST $PORT $1 $2 $3
