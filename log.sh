#!/bin/bash

#设置日志级别
LOG_LEVEL=0 #debug:0; info:1; warn:2; error:3
LOG_FILE=tmp.log
LOG_STYLE=

rm -f $LOG_FILE

function log ()
{
    local logtype=$1            
    local logmsg=$2
    local logfile=$LOG_FILE
    local loglevel=$LOG_LEVEL
    local logstyle=$LOG_STYLE
    local logdate=$(date +'%F %H:%M:%S')
    local line=$(caller 0 | awk '{print $1}')
    local format="$logmsg"      
    if [ "$logstyle" == "less" ]; then         
       format="$logdate $logmsg"           
    elif [ "$logstyle" == "middle" ]; then         
       format="${FUNCNAME[@]/log/} [line:$line] $logmsg"     
       format=${format:1}                       
    elif [ "$logstyle" == "more" ]; then            
       format="$logdate${FUNCNAME[@]/log/} [line:$line] $logmsg" 
    fi
    {  
    case $logtype in 
        "d"|"debug")
            [[ $loglevel -le 0 ]] && echo -e "\033[30m[debug] ${format}\033[0m"
	;;
        "i"|"info")
            [[ $loglevel -le 1 ]] && echo -e "\033[32m[info] ${format}\033[0m"
	;;
        "w"|"warn")
            [[ $loglevel -le 2 ]] && echo -e "\033[33m[warn] ${format}\033[0m" 
	;;
        "e"|"error")
            [[ $loglevel -le 3 ]] && echo -e "\033[31m[error] ${format}\033[0m"
	;;
    esac
    } | tee -a $logfile
}

#以下为测试
debug () {
    log debug "thereare $# parameters: $@"
    
}
info() {
    log info "funcname:${FUNCNAME[@]},lineno:$LINENO"
}
warn() {
    log warn "funcname:${FUNCNAME[0]},lineno:$LINENO"
}
error() {
    log error "the first para:$1;the second para:$2"
}

set -x
debug first second
set +x
info first second
warn first second 
error first second
log i "Hello World!"
