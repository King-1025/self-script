#!/usr/bin/env bash

#香港天文台数据源
SITE="https://www.hko.gov.hk"

#更新农历日历数据，需要expl.sh支持
COMMAND_ALL_DAYS="expl all_days"

function app()
{  
  if [ $# -eq 3 ]; then
     local s=$1
     local e=$2
     local o=$3
     local tmp=$(mktemp -u)
     rm -rf $o 
     local count=1
     let all=$e-$s+1
     echo "# 年份,天干地支,生肖|头月长|月位置|月份|节气位置|闰月" > $o
     for ((i=$s; i <= $e; i++ )); do
       local url="$SITE/tc/gts/time/calendar/text/files/T${i}c.txt"
       echo -n "[$count/$all] "
       fetch "$url" "$tmp"
       if [ $? -eq 0 ]; then
          pick "$tmp" | tee -a $o
       fi
       echo ""
       ((count++))
     done
     rm -rf $tmp
  fi
}

function fetch()
{
  if [ $# -eq 2 ]; then
     local tmp=$(mktemp -u)
     echo -n "fetch $1..."
     curl -sL $1 -o $tmp
     if [ $? -eq 0 ] && [ -e $tmp ]; then
        echo oK!
	iconv -s -f "BIG5" -t "UTF-8" $tmp > $2
	rm -rf $tmp
	if [ $? -eq 0 ] && [ -e $2 ]; then
	   dos2unix -q $2
           return 0
	else
	   return 1
        fi
     else
        echo Failed!
	return 1
     fi
  fi
}

function fliter_fk()
{
   if [ $# -eq 1 ]; then
      local old="null"
      while read line; do
         local ktr=$(echo $line | sed -n "/.月 /p")
         if [ "$ktr" != "" ]; then
	     if [ "$old" != "null" ]; then
                echo $old | awk '{print $2}' | \
			   sed "s/廿九/29/g" | \
   			   sed "s/三十/30/g"
	     else
		echo 0
	     fi
	     break
	 fi
	 old=$line
      done < $1
   fi
}

function fliter_nstr()
{
   if [ $# -eq 1 ]; then
      local nstr=$(sed -n "/.月 /p" $1 | awk '{print $2}')
      nstr=$(echo $nstr | sed "s/十二/12/g" | sed "s/十一/11/g" | \
	       sed "s/正/1/g" | \
               sed "s/二/2/g" | \
	       sed "s/三/3/g" | \
	       sed "s/四/4/g" | \
	       sed "s/五/5/g" | \
	       sed "s/六/6/g" | \
	       sed "s/七/7/g" | \
	       sed "s/八/8/g" | \
	       sed "s/九/9/g" | \
	       sed "s/十/10/g"| \
	       sed "s/閏//g"  | sed "s/月//g")
      echo $nstr
   fi
}

function fliter_hstr()
{
   if [ $# -eq 1 ]; then
      local hstr=$(head -1 $1 | sed "s/(/-/g" | sed "s/)/-/g" | awk -F "-" '{print $1" "$2" "$3}')
      echo $hstr
   fi
}

function fliter_dstr()
{
   if [ $# -eq 1 ]; then
   #set -x
       declare -x darry=($(sed -n "/.月 /p" $1 | awk '{print $1}' | awk -F "年|月|日" '{print $1"-"$2"-"$3}'))
       for ((i=0; i < ${#darry[@]}; i++));do
	   declare -x args=($(echo ${darry[i]} | sed "s/-/ /g"))
	   $COMMAND_ALL_DAYS ${args[0]} \
    		             $(echo ${args[1]} | sed "s/^0//g") \
         		     $(echo ${args[2]} | sed "s/^0//g") 
       done
   #set +x
  fi
}

function fliter_solar()
{
   if [ $# -eq 1 ]; then
#      set -x
      declare -x sl=($(sed -n "/^[1-9].*年.*月.*日 /p" $1 | awk '{ if(NF >= 4){ print $1"-"$4 } }'))
      local len=${#sl[@]}
      for ((i=0; i < $len; i++)); do
         local item=${sl[i]}
	 declare -x args=($(echo $item | awk -F "-" '{print $1}' | awk -F "年|月|日" '{print $1" "$2" "$3}'))
	 $COMMAND_ALL_DAYS ${args[0]} \
    		             $(echo ${args[1]} | sed "s/^0//g") \
         		     $(echo ${args[2]} | sed "s/^0//g") 
#         echo $item | awk -F "-" '{print $2}'
      done
 #     set +x
   fi
}

function fliter_run()
{
   if [ $# -eq 1 ]; then
      sed -n "/閏/p" $1 | awk '{print $2}' | sed "s/閏//g"
   fi
}

function pick()
{
  if [ $# -eq 1 ]; then
     local file=$1
     if [ -e $file ]; then
	local fk=$(fliter_fk $file)
	declare -x hstr=($(fliter_hstr $file))
	declare -x dstr=($(fliter_dstr $file))
	declare -x nstr=($(fliter_nstr $file))
	declare -x solar=($(fliter_solar $file))
        declare -x rstr=($(fliter_run $file))
        echo "${hstr[@]}|$fk|${dstr[@]}|${nstr[@]}|${solar[@]}|${rstr[@]}"
#        echo ${solar[@]}
     fi
  fi
}

#pick $*
#pick_feature $*
app $*
