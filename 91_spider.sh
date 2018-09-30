#!/usr/bin/env bash
#描述:抓取91pron视频资源
#作者:King-1025
#邮箱:1543641386@qq.com
#时间:2018.9.28

#参数定义
ROOT=.
#运行该脚本需求的工具
REQUIREMENT="curl sed ua awk"
OFFSET_PAGE=0
MAX_PAGE=8
IS_CONTINUE=0 
PROCESS=8
SITE="http://91porn.com/"
TEST_URL="http://zzuli.edu.cn/"
SAVE_TYPE="html"
SAVE_FILE=$ROOT/out.html
CURL_OPTION="-# -L -f --tcp-fastopen --tcp-nodelay --trace-time"
TIME=0
SELF_UA=0
LOG_LEVEL=0
LOG_FILE=
LOG_STYLE=

#入口
function app()
{
  parse_args "$*"
  show
  check $REQUIREMENT
  at_time
  prepare
  crawl $OFFSET_PAGE $MAX_PAGE
  free
  check_time
} 

#抓取
function crawl()
{
  log i "start crawling..."
  local flag=$1
  local max_value=$2
  while [ $flag -le $max_value ]; do
     read -u 6
     {
     local page_url="${SITE}v.php?next=watch&page=$flag"
     local page_data=".page_tmp$flag"
     log i "fetch $page_url"
     fetch $page_data $page_url $page_url
     if [ $? -eq 0 ] && [ -e "$page_data" ]; then
	log i "page data is ok.($flag)"
	#解析view
	local views=($(pick_keys $page_data))
	rm -f $page_data
	local index=0
	local length=${#views[@]}
	while [ $index -lt $length ]; do
	   read -u 6
	   {
	     local view_url=${views[index]}
	     local view_data=".view_tmp$flag$index"
	     log i "fetch $view_url"
             fetch $view_data $view_url $page_url
	     if [ $? -eq 0 ] && [ -e "$view_data" ]; then
		local tag="$flag:$index"
	        log i "view data is ok.($tag)"
	        #提取视频
	        local title=$(pick_title $view_data)
                is_null "title[$tag]" $title
	        if [ $? -eq 1 ]; then
		   local poster=$(pick_poster $view_data)
		   is_null "poster[$tag]" $poster
		   if [ $? -eq 1 ]; then
		      local video_src=$(pick_video $view_data)
	              is_null "video_src[$tag]" $video_src
	              if [ $? -eq 1 ]; then
			 is_new $title
			 if [ $? -eq 1 ]; then
			    save $title $poster $video_src
			    log i "view data save ok!($tag)"
			    add "valid" 1
		         fi
		       fi
	            fi
	         fi
	      rm -f $viewdata
	      else
	         log w "view data is no."
	      fi
	      add "total" 1
	      echo >&6
          } &
	  let index+=1
	done
	wait
     else
	log w "page data is no."
     fi
     log i "page $flag over."
     echo >&6
     } &
     let flag+=1
  done
  wait
  local total=$(get "total")
  local valid=$(get "valid")
  log i "all works is done.(total:$total valid:$valid)"
}

function add()
{
   local count=$(get $1)
   let count+=$2
   sed -i "s#$1=.*#$1=$count#" .config_tmp  
}

function get()
{
  local val
  if [ "$1" == "total" ]; then
     val=$(cat .config_tmp | awk -F "=" '/total/ {print $2}')
  elif [ "$1" == "valid" ]; then
     val=$(cat .config_tmp | awk -F "=" '/valid/ {print $2}')
  fi
  echo $val
}

function init_config()
{
  rm -f .config_tmp
  echo "total=0" >  .config_tmp
  echo "valid=0" >> .config_tmp
}

function is_new()
{
   if [ $SAVE_TYPE == "file" ]; then
      return 1
   fi
   if [ -e $SAVE_FILE ]; then
      local res=$(sed -n "#$1#p" $SAVE_FILE)
      if [ "$res" != "" ]; then
	 log w "repeate:$res"
         return 0
      fi
   fi 	      
   return 1
}

function at_time()
{
  TIME=$(date +%s)
  log i "time start at $TIME"
}

function check_time()
{
  let tmp_time=$(date +%s)-$TIME
  if [ $tmp_time -lt 0 ]; then
     tmp_time=0
  fi
  local info="during time:"
  if [ $# -eq 1 ]; then
     info=$1" "$info
  fi
  log i "${info}${tmp_time}s"
}

function save()
{
  if [ $SAVE_TYPE == "html" ]; then
     if [ ! -e $SAVE_FILE ]; then
	touch $SAVE_FILE
	init_html $SAVE_FILE
	log i "create file:$SAVE_FILE"
     fi
     local html='<div><a href="'$3'"><img src="'$2'" width="100%"><hr></a><p>'$1'</p></div><br>'
     sed  -i "s#^</body>#$html\n&#" $SAVE_FILE
  elif [ $SAVE_TYPE == "txt" ]; then
     if [ ! -e $SAVE_FILE ]; then
	touch $SAVE_FILE
	log i "create file:$SAVE_FILE"
     fi
     echo $1 >> $SAVE_FILE
     echo $3 >> $SAVE_FILE
     echo "" >> $SAVE_FILE
   elif [ $SAVE_TYPE == "file" ]; then
      if [ ! -e $SAVE_FILE ]; then
        mkdir -p $SAVE_FILE
	log i "create dir:$SAVE_FILE"
      fi
      local d=$SAVE_FILE/$1
      if [ ! -e $d ]; then
         mkdir -p $d
      fi
      curl -# -o $d/1.jpg $2
      curl -# -o $d/1.mp4 $3
 fi
}

function init_html()
{
echo '<!DOCTYPE Html>
<html>                                                                                    <head><title>91pron videos</title>                                                        <meta charset="utf-8">                                                                    <style>div{border:2px solid #333333;} p{font-size:20px;}</style>                          </head>                                                                                   <body align="center">
</body>' > $1                                                         
}

function pick_keys()
{
  #cat $1 | sed -n "/viewkey.*title/p" | sed 's/\(.*\)?\(.*\)" t\(.*\)/\2/g'
  #cat $1 | sed -n "/viewkey.*title/p" | sed 's/\(.*\)="\(.*\)" \(.*\)/\2/g'
  sed -n "/viewkey.*title/p" $1 | sed 's/\(.*\)="\(.*\)" \(.*\)/\2/g'
}

function pick_title()
{
  #cat $1 | sed -n "/<title>/p" | sed "s/\(.*\)>\(.*\)/\2/g" | sed s/[[:space:]]//g
  sed -n "/<title>/p" $1 | sed "s/\(.*\)>\(.*\)/\2/g" | sed s/[[:space:]]//g
}

function pick_poster()
{
  #cat $1 | sed -n "/poster/p" | sed 's/\(.*\)="\(.*\)" \(.*\)/\2/g'
  sed -n "/poster/p" $1 | sed 's/\(.*\)="\(.*\)" \(.*\)/\2/g'
}

function pick_video()
{
  #cat $1 | sed -n "/source/p" | sed 's/\(.*\)="\(.*\)" \(.*\)/\2/g'
  #sed -n "/source/p" $1 | sed 's/\(.*\)="\(.*\)" \(.*\)/\2/g'
  sed -n "/source/p" $1 | sed 's/\(.*\)="\(.*\)" \(.*\)/\2/g' | sed 's/185.38.13.130/192.240.120.34/' | sed 's/185.38.13.159/192.240.120.34/'
}

function get_random_ip()
{
   local ch="."
   if [ "$#" -eq 1 ]; then
      ch=$1
   fi
   echo "$(rand 0 255)$ch$(rand 0 255)$ch$(rand 0 255)$ch$(rand 0 255)"
}

function rand(){
    local min=$1
    local max=$(($2-$min+1))
    local num=$(($RANDOM+1000000000)) #添加一个10位的数再求余
    echo $(($num%$max+$min))
}

function fetch()
{
   echo "" > $1
   curl -A "$(gen_ua)" -e $3 -o $1 -H "Accept-Language: zh-CN,zh;q=0.9" -H "X-Forwarded-For: $(get_random_ip)" -H "Content-Type: multipart/form-data; session_language=cn_CN" --connect-timeout 3 --retry 1 --retry-max-time 2 $CURL_OPTION $2 2>&1 > /dev/null
   sleep 1
}   

function is_null()
{
  if [ "$2" == "" ]; then
      log w "$1 is null!"
      return 0
  else
      log i "$1:$2"
      return 1
  fi
}

function show()
{
  log d "view config"
  log d "OFFSET_PAGE:$OFFSET_PAGE"
  log d "MAX_PAGE:$MAX_PAGE"
  log d "IS_CONTINUE:$IS_CONTINUE"
  log d "PROCESS:$PROCESS"
}

function prepare()
{
   init_config
   
   if [ $IS_CONTINUE -ne 1 ]; then
      log d "clean $SAVE_FILE"
      rm -rf $SAVE_FILE
   else
      log i "continue to use $SAVE_FILE for saving data"
   fi

   rm -f .page_tmp*
   rm -f .view_tmp*

   log d "build FIFO..."
   local tmp="$ROOT/.fifo_tmp"
   log d "create temp file:$tmp"
   mkfifo $tmp
   log d "use 6 to bind FIFO"
   exec 6<>$tmp
   log d "delete temp file:$tmp"
   rm -f $tmp
   log d "set process:$PROCESS"
   for ((i=0;i<$PROCESS;i++))
   do
        echo >&6
   done
   log d "FIFO ok!"
}

function free()
{
   log d "close FIFO"
   exec 6>&-
   log d "make clean"
   rm -f .page_tmp*
   rm -f .view_tmp*
   rm -f .config_tmp
}

function introduce()
{
date 
echo "作者:King-1025
邮箱:1543641386@qq.com
描述:抓取91pron视频资源"
}

function help()
{
  echo "Usage:$0 [-c|--continue] [-r|--range <start end>|index] [-p|--process <value>] [-t|--save-type <html|txt|file>] [-o|--out-file outfile] [-ll|--log-level <d|i|w|e>] [-lf|--log-file logfile] [ls|--log-style <default|less|middle|more>] [-h|--help]."
}

function parse_args()
{
 local index=0
 local argv=($1)
 local length=${#argv[@]}
 for((i=0;i<$length;i++));do
    case ${argv[$i]} in
         "-c"|"--continue")
            IS_CONTINUE=1
            ;;
	 "-ls"|"--log-style")
	    inspect $i 1 $length
	    if [ $? -eq 1 ]; then   
	    local v0=${argv[$[$i+1]]}         
	       if [ ${v0:0:1} != "-" ]; then       
		  LOG_STYLE=$v0          
	       fi                            
            fi
	    ;;
         "-lf"|"--log-file")
	    inspect $i 1 $length
	    if [ $? -eq 1 ]; then
	      local v0=${argv[$[$i+1]]}
	      if [ ${v0:0:1} != "-" ]; then
                LOG_FILE=$v0
	      fi
            fi
	    LOG_FILE="91pron-$(date +'%y%m%d%H%M%S').log"
	    rm -f $LOG_FILE
	    ;;
         "-ll"|"--log-level")
            inspect $i 1 $length
	    if [ $? -eq 1 ]; then
	      local v0=${argv[$[$i+1]]}
              if [ "$v0" == "d" ]; then
		 LOG_LEVEL=0
	      elif [ "$v0" == "i" ]; then
		 LOG_LEVEL=1
	      elif [ "$v0" == "w" ]; then
		 LOG_LEVEL=2
	      elif [ "$v0" == "e" ]; then
		 LOG_LEVEL=3
	      else
	         echo "error log level:$v0"
	         help
		 exit 1
	      fi
	    fi
	    ;;
	 "-o"|"--out-file")
            inspect $i 1 $length
	    if [ $? -eq 1 ]; then
	       local v0=${argv[$[$i+1]]}
	       if [ ${v0:0:1} != "-" ]; then
	          SAVE_FILE=$v0
	       fi
	    else 
	       echo "-o needs a filename"
	       help
	       exit 1
	    fi
	    ;;
	 "-t"|"--save-type")
	    inspect $i 1 $length
	    if [ $? -eq 1 ]; then
               local v0=${argv[$[$i+1]]}
	       if [ "$v0" == "html" ]; then
                  SAVE_TYPE="html"
	       elif [ "$v0" == "txt" ]; then
		  SAVE_TYPE="txt"
	       elif [ "$v0" == "file" ]; then
		  SAVE_TYPE="file"
	       else
		  echo "without type:$v0"
		  help
		  exit 1
               fi
	       SAVE_FILE=$ROOT/out.$SAVE_TYPE
	    fi
	    ;;
         "-r"|"--range")
            inspect $i 2 $length
            if [ $? -eq 1 ]; then
               local v0=${argv[$[$i+1]]}
               local v1=${argv[$[$i+2]]}
	       if [ ${v0:0:1} != "-" ] && [ ${v1:0:1} != "-" ]; then
                  OFFSET_PAGE=$v0
                  MAX_PAGE=$v1
		  continue
	       fi
            fi
            inspect $i 1 $length
            if [ $? -eq 1 ]; then
               local v0=${argv[$[$i+1]]}
	       if [ ${v0:0:1} != "-" ]; then
                  OFFSET_PAGE=$v0
                  MAX_PAGE=$v0
               fi
            fi
            ;;
        "-p"|"--process")
            inspect $i 1 $length
            if [ $? -eq 1 ]; then
               local v0=${argv[$[$i+1]]}
	       if [ ${v0:0:1} != "-" ]; then
                  PROCESS=$v0
	       fi
            fi
            ;;
        "-h"|"--help")
	    introduce
            help
            exit 0                                                 
	    ;;                                            
    esac
 done
if [ $OFFSET_PAGE -lt 0 ]; then
   OFFSET_PAGE=0
fi

if [ $PROCESS -lt 1 ]; then
   PROCESS=1
fi
}

function not_implement()
{
  log w "$1 not implement!"
  exit 0
}

#审查参数长度
function inspect()
{
   if [ $[$1+$2] -lt $3 ]; then
      return 1
   else
      return 0
   fi
}

#检查运行需求
function check()
{
  log i "requirement checking..."
  local nc=0
  for i in $@; do
      which $i > /dev/null  2>&1
      if [ $? -ne 0 ]; then
	 if [ "$i" == "ua" ]; then
            SELF_UA=1
	    log w "use self ua instead."
         else
	    log e "$i not found!"
	    let nc+=1
	 fi
      fi
  done
  if [ $nc -gt 0 ]; then
     log e "$nc requirements not found!"
     exit 1
  else
     log i "all requirements ok!"
  fi
}

function log()
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
    {                                                                    case $logtype in          
         "d"|"debug")                                                             [[ $loglevel -le 0 ]] && echo -e "\033[30m[debug] ${format}\033[0m"
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

function gen_ua()
{
  if [ $SELF_UA == 1 ]; then
      local user_agent=("Mozilla/5.0 (Windows NT 10.0; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2870.18 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.3; Trident/4.0)" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2917.90 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2792.54 Safari/537.36" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.2; Win64; x64; Trident/5.0)" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2818.55 Safari/537.36" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2676.60 Safari/537.36" "Mozilla/5.0 (Windows NT 6.3; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2896.66 Safari/537.36" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 5.1; WOW64; Trident/6.0)" "Mozilla/5.0 (X11; Linux i686; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (X11; Linux i686; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2912.44 Safari/537.36" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Windows NT 6.1; Win64; x64; Trident/7.0; rv:11.0) like Gecko")
      local min=0                                                                  local max=$((${#user_agent[@]}-1))
      local index=$(rand $min $max)
      echo ${user_agent[$index]}
  else 
      echo $(ua)
  fi
}

app "$#" "$*"
