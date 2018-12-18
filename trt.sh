#!/usr/bin/env bash

#在线翻译工具

BAIDU_APPID="20180407000143698"
BAIDU_KEY="7eflq1FNSEGlAzYwQhCY"
BAIDU_TRANSLATE_API_URL="http://api.fanyi.baidu.com/api/trans/vip/translate"
BAIDU_TRANSLATE_MAX_QUERY_LENGTH=2000
BAIDU_TRANSLATE_SUPPORT_LANGUAGES="\
auto	自动检测
zh	中文
en	英语
yue	粤语
wyw	文言文
jp	日语
kor	韩语
fra	法语
spa	西班牙语
th	泰语
ara	阿拉伯语
ru	俄语
pt	葡萄牙语
de	德语
it	意大利语
el	希腊语
nl	荷兰语
pl	波兰语
bul	保加利亚语
est	爱沙尼亚语
dan	丹麦语
fin	芬兰语
cs	捷克语
rom	罗马尼亚语
slo	斯洛文尼亚语
swe	瑞典语
hu	匈牙利语
cht	繁体中文
vie	越南语"

DEFAULT_FROM_LANGUAGE=auto
DEFAULT_TO_LANGUAGE=en
DEFAULT_OUTPUT_FORMAT=plain

SUPPORT_OUTPUT_FORMATS="\
raw	输出json格式
plain	输出文本格式"

VERSION=1.0

function app()
{
  if [ $1 -eq 0 ]; then
    echo "support:pof,psl,use,help,version"
  else
    declare -a argv=($2)
    for ((i=0;i<$1;i++));do
      #echo "$i:${argv[i]}"
      case "${argv[i]}" in
	  "pof") print_support_output_format; break;;
	  "psl") print_support_language ${argv[i+1]}; break;;
	  "use") translate $2; break;;
          "help") user_help $(basename $0); break;;
	  "version") echo "$VERSION";;
	  *) exit 0;;
      esac
    done
    unset i
  fi
}

function user_help()
{
  echo "在线翻译工具 $VERSION"
  echo "Usage:$1 psl baidu"
  echo "      $1 use baidu <query-string>"  
  echo "      $1 use baidu -t en <query-string>"  
  echo "      $1 use baidu -f auto -t en -o raw <query-string>"
  echo "      "
  echo "Default: from:$DEFAULT_FROM_LANGUAGE to:$DEFAULT_TO_LANGUAGE output-format:$DEFAULT_OUTPUT_FORMAT"
}

function translate()
{
   shift 1
   local handler=""
   case "$1" in
	"baidu") handler=baidu_translate ;;
	*)
	    echo "invalid:'$1'"
	    echo "support handler:baidu"
	    exit 1
	;;
   esac
   if [ "$handler" != "" ]; then
      shift 1
#      set -x
      $handler $(gen_translate_args $@)
#      set +x
   fi
}

function gen_translate_args()
{
  local from=$DEFAULT_FROM_LANGUAGE
  local to=$DEFAULT_TO_LANGUAGE
  local output_format=$DEFAULT_OUTPUT_FORMAT
  while getopts "f:t:o:" opt; do
     case "$opt" in
        "f") from=$OPTARG ;;
        "t") to=$OPTARG ;;
        "o") output_format=$OPTARG ;;
	?) exit 1 ;;
     esac
  done
  unset opt
  shift $((OPTIND-1))
  echo "$from" "$to" "$output_format" "$*"
}

function baidu_translate()
{
  if [ $# -ge 4 ]; then
     local from=$1
     local to=$2
     local format=$3
     shift 3
     local query="$*"
     check_support_language "baidu" "$from" &&
     check_support_language "baidu" "$to" &&
     check_query "$query" "$BAIDU_TRANSLATE_MAX_QUERY_LENGTH"
     if [ $? -eq 0 ]&&[ "$to" != "auto" ]; then
       #set -x
       local url=$(check_value "${BAIDU_TRANSLATE_API_URL}" "baidu translate api url")
       local appid=$(check_value "${BAIDU_APPID}" "baidu translate appid")
       local key=$(check_value "${BAIDU_KEY}" "baidu translate key")
       local salt="$(rand 0 9)$(rand 10 99)$(rand 100 999)$(rand 1000 9999)"
       local str="${appid}${query}${salt}${key}"
       local sign=$(printf "$str" | md5sum | awk '{print $1}')
       local tmp=$(mktemp -u)
       curl -s -X POST --data-urlencode "q=$query" --data "from=$from&to=$to&appid=$appid&salt=$salt&sign=$sign" -o $tmp $url
       if [ $? -eq 0 ]&&[ -e "$tmp" ]; then
	  local emsg=$(jq -r ".error_msg" $tmp)
	  if [ "$emsg" = "null" ]; then
             format_result "$tmp" "$format"
	  else
	    echo "error:$emsg"
	  fi
	  rm -rf $tmp
       fi
     fi
  fi
}

function format_result()
{
  if [ $# -ge 1 ]; then
     local data=$1
     if [ -e "$data" ]; then
        local format=$2
	if [ "$format" = "" ]; then format=$DEFAULT_OUTPUT_FORMAT; fi
        case "$format" in
           "raw") cat $data ;;
	   "plain") jq -r ".trans_result[].dst" $data ;;
	   *) echo "unknown output format:$format";;
        esac
     fi
  fi
}

function print_support_output_format()
{
  local tmp=$(mktemp -u)
  echo "$SUPPORT_OUTPUT_FORMATS" > "$tmp"
  if [ -e "$tmp" ]; then
     sed -i "s/^/ /g" "$tmp"
     echo -e " 格式   |   说明\n--------------------"
     cat $tmp
     rm -rf $tmp
  fi
}

function rand(){
  if [ $# -eq 2 ]; then
    local min=$1
    local max=$(($2-$min+1))
    local num=$(($RANDOM+1000000000))
    echo $(($num%$max+$min))
  fi
}

function check_value()
{                
  local val=""
  if [ $# -eq 2 ]; then
     if [ "$1" != "" ]; then
        val=$1
     else
	while true; do
	  read -p "$2 is empty! please to reset it:" option
          if [ "$option" != "" ]; then
	     val=$option
	     break
	  fi
	done
	unset option
       fi
    fi
  echo "$val"
}

function print_support_language()
{
  if [ $# -eq 1 ]; then
     local tag=$1
     local tmp=$(mktemp -u)
     case "$tag" in
        "baidu") echo "$BAIDU_TRANSLATE_SUPPORT_LANGUAGES" > "$tmp" ;;
	*) echo "unknown tag:$tag!" ;;
     esac
     if [ -e "$tmp" ]; then
        sed -i "s/^/ /g" "$tmp"
        echo -e "代号  |  名称\n----------------"
        cat $tmp
        rm -rf $tmp
     fi
  else
     echo "support tags:baidu"
  fi
}

function check_support_language()
{
  local is_ok=1
  if [ $# -eq 2 ]; then
     local tag=$1
     local lang=$2
     declare -a list=()
     case "$tag" in
        "baidu") list=($BAIDU_TRANSLATE_SUPPORT_LANGUAGES) ;;
	*) echo "unknown tag:$tag!" ;;
     esac
     if [[ "$lang" =~ ^[a-zA-Z]+$ ]]; then
        echo "${list[*]}" | grep -q "$lang" > /dev/null
        is_ok=$?
     fi
     if [ $is_ok -ne 0 ]; then
	echo "don't support language:$lang!"
     fi
  fi
  return $is_ok
}

function check_query()
{
  local is_ok=1
  if [ $# -eq 2 ]; then
     local query=$1
     local limit=$2
     if [[ "$limit" =~ ^[0-9]+$ ]]; then
        local real=${#query}
	if [ $limit -eq 0 ]; then limit=1; fi
	if [ $real -gt 0 ]&&[ $real -le $limit ]; then
	   is_ok=0
	else
	   echo "query length is in (0,$limit]"	
	fi
     else
       echo "limit must be number!"
     fi
  fi
  return $is_ok
}

app "$#" "$*"
