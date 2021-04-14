#!/usr/bin/env bash

USER=
PASSWD=
# DOMAIN=39.106.72.49  #www.youming1025.xin(过期)
# HOST=47.93.58.31
# HOST=39.98.142.122
HOST=
REMOTE_FILE=
LOCAL_FILE=
EXE_GET=ftpget
EXE_PUT=ftpput

function getHost(){
   str=$(ping -c 1 $1 | grep -E "from *")
   HOST=${str:14:12}
   return 0
}

function details(){
  echo $(date)
  echo "Author:King-1025"
  echo "Email:1543641386@qq.com"
  print_help
}

function print_help(){
   echo "Usage:sf <get [LOCAL_FILE] | put [REMOTE_FILE]> <file>"
   echo "Description:从$HOST上获取/上传文件"
   return 0
}

if [ "$HOST" == "" ]; then
   getHost $DOMAIN
fi

argc=$#

if [ $argc -lt 2 ] || [ $argc -gt 3 ]; then
   details
   exit 0
fi

if [ $1 == "get" ]; then
  if [ $# = 3 ]; then
     LOCAL_FILE=$2
     REMOTE_FILE=$3
  else
     REMOTE_FILE=$2
  fi
  $EXE_GET -u $USER -p $PASSWD $HOST $LOCAL_FILE $REMOTE_FILE
elif [ $1 == "put" ]; then
  if [ $# = 3 ]; then
     LOCAL_FILE=$3
     REMOTE_FILE=$2
  else
     LOCAL_FILE=$2
  fi
  $EXE_PUT -u $USER -p $PASSWD $HOST $REMOTE_FILE $LOCAL_FILE
else 
  echo "未知选项$1!"
  print_help
  exit 1
fi
