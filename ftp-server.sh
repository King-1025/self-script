#!/bin/bash

EXE=ftpd
ARGS=
PORT=2121
DIR=

if [ $# -gt 0 ]
then
  if [ -d $1 ]
  then
    DIR=$1
  else
    echo "不存在$1!"
    exit 1
  fi
else
  DIR="$PWD"
fi

ARGS="-w $DIR"

echo "根目录:$DIR"
tcpsvd -vE 0.0.0.0 $PORT $EXE $ARGS
