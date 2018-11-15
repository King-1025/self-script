#!/usr/bin/env bash
#描述:获取SSR账号和密码
#作者:King-1025
#邮箱:1543641386@qq.com
#日期:2018.10.1

ROOT=.
REQUIREMENT="curl zbarimg base64 sed ua awk"
CURL_OPTION="-#"
SELF_UA=1
SAVE_FILE=$ROOT/ssr.html
SAVE_TYPE=html

function app
{
  check $REQUIREMENT
  prepare
  crawl
  free
}

function crawl()
{
  log "crawl()" "start..."
  log "crawl()" "pick ss.freess.org..."
  save "ss.fress.org" "$(pick_ss_freess_org)"
  log "crawl()" "pick free.yitianjianss.com..."
  save "free.yitianjianss.com" "$(pick_free_yitianjianss_com)"
  log "crawl()" "pick doubi.iom..."
  save "doubi.com" "$(pick_doubi_io)"
  log "crawl()" "result is in $SAVE_FILE"
}

function save()
{
   local tag=$1
   local data=($2)
   if [ $SAVE_TYPE == "html" ]; then            
	 if [ ! -e $SAVE_FILE ]; then      
	 touch $SAVE_FILE        
	 init_html $SAVE_FILE
         log "save()" "create file:$SAVE_FILE"
     fi
     local length=${#data[@]}
     local html="<div><p>"$tag" (total:$length)</p>"
     rm -rf ssr.txt
     for((i=0;i<length;i++)); do
         echo "${data[i]}" >> ssr.txt
         html=$html'<a href="'${data[i]}'">'${data[i]}'</a><br><br>'
     done
     html=$html'</div><br>'
     sed  -i "s#^</body>#$html\n&#" $SAVE_FILE
  fi
  log "save()" "save $tag is ok"
}

function init_html()                                        {
echo '<!DOCTYPE Html>
<html>
<head>
<title>ssr</title>                                  
<meta charset="utf-8">
<style>div{border:2px solid #1FFE8E; padding:5px;} p{font-size:20px;}</style>
</head>                                                     <body>
</body>' > $1
}

function fetch()
{
   curl -A "gen_ua" -H "Accept-Language: zh-CN,zh;q=0.9" -H "Content-Type: multipart/form-data; session_language=cn_CN" --connect-timeout 5 --retry 1 --retry-max-time 3 $CURL_OPTION $1
}

function pick_my_ishadowx_net()
{
  local url="https://my.ishadowx.net/"
}

function pick_doubi_io()
{
  local url="https://doub.io/sszhfx/"
  fetch $url > .data_tmp
  local ssr=($(sed -n '/<pre class="prettyprint linenums" >/,+20p' .data_tmp | sed -n "/ssr:\/\//p" | sed "s/\(.*\)ssr\(.*\)/ssr\2/g"))
  local data="";
  local length=${#ssr[@]}
  for((i=0;i<length;i++)); do
    local ts="${ssr[i]}"
    ts=${ts:6:11}
    local rs=$(echo "$data" | sed -n "/$ts/p")
    if [ "$rs" == "" ]; then
       data="$data ${ssr[i]}"
    fi
  done
  data=$data" "$(sed -n "/dl1.*ss/p" .data_tmp | sed 's/\(.*\)ss\(.*\)" t\(.*\)/ss\2/g' | awk -F '"' '{print $1}')
  echo "$data"
}

function pick_free_yitianjianss_com()
{
    local url="https://free.yitianjianss.com/"
    fetch $url | sed -n '/.png/p' | sed 's/\(.*\)="\(.*\)">/\2/g' > .data_tmp
    while read line ; do fetch "$url$line" > .img_tmp ; zbarimg -q .img_tmp | sed "s/QR-Code://g" ;
    done < .data_tmp
}

function pick_ss_freess_org()
{
    local url="https://ss.freess.org"
    #fetch $url | sed -n "/image fit/p" | sed "s/\(.*\)base64,//g" | awk -F '"' '{print $1}' > .data_tmp
    fetch $url | sed -n "/image fit/p" | sed 's/\(.*\)base64,\(.*\)" \(.*\)/\2/g' > .data_tmp
    while read line ; do echo -n $line | base64 -d > .img_tmp | zbarimg -q .img_tmp | sed "s/QR-Code://g" ; done < .data_tmp
}

function prepare()
{
  log "prepare()" "clean..."
  rm -f $SAVE_FILE
}

function free()
{
  log "free()" "clean..."
  rm -f .data_tmp
  rm -f .img_tmp
}

function check()
{
  log "check()" "requirement checking..."
  local nc=0
  for i in $@; do
      which $i > /dev/null  2>&1
      if [ $? -ne 0 ]; then
	 if [ "$i" == "ua" ]; then
            SELF_UA=1
	    log "check()" "use self ua instead."
         else
	    log "check()" "$i not found!"
	    let nc+=1
	 fi
      fi
  done
  if [ $nc -gt 0 ]; then
     log "check()" "$nc requirements not found!"
     exit 1
  else
     log "check()" "all requirements ok!"
  fi
}

function log()
{
  echo "$(date +'%F %H.%M.%S') --- $1:$2"
}

function rand(){
    local min=$1
    local max=$(($2-$min+1))
    local num=$(($RANDOM+1000000000))
    echo $(($num%$max+$min))
}

function gen_ua()
{
  if [ $SELF_UA == 1 ]; then
      local user_agent=("Mozilla/5.0 (Windows NT 10.0; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2870.18 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.3; Trident/4.0)" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2917.90 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2792.54 Safari/537.36" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.2; Win64; x64; Trident/5.0)" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2818.55 Safari/537.36" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2676.60 Safari/537.36" "Mozilla/5.0 (Windows NT 6.3; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2896.66 Safari/537.36" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 5.1; WOW64; Trident/6.0)" "Mozilla/5.0 (X11; Linux i686; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (X11; Linux i686; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2912.44 Safari/537.36" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Windows NT 6.1; Win64; x64; Trident/7.0; rv:11.0) like Gecko")
      local min=0                                           
      local max=$((${#user_agent[@]}-1))      
      local index=$(rand $min $max)      
      echo ${user_agent[$index]}
  else
      echo $(ua)
  fi
}

app "$#" "$*"
