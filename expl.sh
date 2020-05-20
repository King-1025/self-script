#!/usr/bin/env bash

#F_1901=29
#declare -x D_1901=(20 50 79 109 138 167 197 226 256 285 315 345)
#declare -x N_1901=(12 1 2 3 4 5 6 7 8 9 10 11)

ROOT=$HOME
DATA=$ROOT/.expl_data

function app()
{
  if [ "$1" = "all_days" ]; then
     shift 1
     get_year_days $@
     echo $ALL_DAYS
  else
     if [ ! -e $DATA ]; then
	echo $DATA not exist!
        exit 1
     fi
     format $@
  fi
}

function format()
{
    if [ $# -eq 3 ]; then
       if [ -e $DATA ]; then
          local record=$(sed -n "/^$1/p" $DATA)
          declare -x hs=($(echo $record | awk -F "|" '{print $1}'))
          declare -x td=()
          local solar=""

          local run=$(check_run "$record")

          transfer $@
          td=(${TRANS_DATA[@]})
          solar=$(check_solar "$record" $ALL_DAYS)

#         echo ${hs[0]} ${td[1]} ${td[2]} ${hs[1]} ${hs[2]} $solar 
   	  echo "$(to_last ${td[4]} ${td[5]})"
          echo "$(to_zh_year ${hs[0]}) $(to_zh_month ${td[1]}) $(to_zh_day ${td[2]}) $(to_zh_month_type ${td[3]}) ${hs[1]} ${hs[2]} $(to_zh_leap ${td[-1]}) $run $solar"
       fi
    fi
}

function to_last()
{
   if [ $# -eq 2 ]; then
      local f=$(echo "" | awk -v a=$1 -v b=$2 '{printf("%.2f", b*100/a)}')
      local y=$(($1-$2))
      echo "今年共$1天，主人已度过$f%，还剩$y天。"
   fi
}

function to_zh_leap()
{
   if [ $# -eq 1 ]; then
     if [ $1 -eq 1 ]; then
        echo "闰年(366天)"
     else
        echo "平年(365天)"
     fi
   fi
}

function to_zh_month_type()
{
   if [ $# -eq 1 ]; then
      if [ $1 -eq 29 ]; then
         echo "小月(29天)"
      elif [ $1 -eq 30 ]; then
         echo "大月(30天)"
      else
         echo "岁余($1天)"	
      fi
   fi
}

function to_zh_year()
{
   if [ $# -eq 1 ]; then
     echo $1 | sed "s/0/零/g" | \
               sed "s/1/一/g" | \
               sed "s/2/二/g" | \
               sed "s/3/三/g" | \
               sed "s/4/四/g" | \
               sed "s/5/五/g" | \
               sed "s/6/六/g" | \
               sed "s/7/七/g" | \
               sed "s/8/八/g" | \
               sed "s/9/九/g" | \
               sed "s/$/年/g"
   fi
}

function to_zh_month()
{
   if [ $# -eq 1 ]; then
     if [ $1 -ge 1 ] && [ $1 -le 12 ]; then
      echo $1 | sed "s/^1$/正月/g" | \
	        sed "s/^2$/二月/g" | \
	        sed "s/3/三月/g" | \
	        sed "s/4/四月/g" | \
	        sed "s/5/五月/g" | \
	        sed "s/6/六月/g" | \
	        sed "s/7/七月/g" | \
	        sed "s/8/八月/g" | \
	        sed "s/9/九月/g" | \
	        sed "s/10/十月/g" | \
	        sed "s/11/冬月/g" | \
	        sed "s/12/腊月/g"
    fi
   fi
}

function to_zh_day()
{
   if [ $# -eq 1 ]; then
    if [ $1 -ge 1 ] && [ $1 -le 31 ]; then
     echo $1 | sed "s/^1$/初一/g" | \
               sed "s/^2$/初二/g" | \
               sed "s/^3$/初三/g" | \
               sed "s/^4$/初四/g" | \
               sed "s/^5$/初五/g" | \
               sed "s/^6$/初六/g" | \
               sed "s/^7$/初七/g" | \
               sed "s/^8$/初八/g" | \
               sed "s/^9$/初九/g" | \
               sed "s/^10$/初十/g" | \
               sed "s/^1/十/g" | \
               sed "s/^2/廿/g" | \
               sed "s/^3/三十/g" | \
	       sed "s/0$//g" | \
               sed "s/1$/一/g" | \
               sed "s/2$/二/g" | \
               sed "s/3$/三/g" | \
               sed "s/4$/四/g" | \
               sed "s/5$/五/g" | \
               sed "s/6$/六/g" | \
               sed "s/7$/七/g" | \
               sed "s/8$/八/g" | \
               sed "s/9$/九/g"
    fi
   fi

}

function check_run()
{
   if [ $# -eq 1 ]; then
     local rstr=$(echo $1 | awk -F "|" '{print $6}')
     if [ "$rstr" != "" ]; then
	echo "闰月($rstr)"
     fi
   fi
}

function check_solar()
{
   if [ $# -eq 2 ]; then
#     set -x
     local record=$1
     local days=$2
     declare -x label=(小寒 大寒 立春 雨水 惊蛰 春分 清明 谷雨 立夏 小满 芒种 夏至 小暑 大暑 立秋 处暑 白露 秋分 寒露 霜降 立冬 小雪 大雪 冬至)
     declare -x solar=($(echo $record | awk -F "|" '{print $5}'))
     for ((i=0; i < ${#solar[@]}; i++)); do
        if [ $days -eq ${solar[i]} ]; then
           echo ${label[i]} 
	   break
	fi
     done
#     set +x
   fi
}

function transfer()
{
  if [ $# -eq 3 ]; then
     local m=0
     local r=0
     local c=0
     local all=""
     local year=$1
     local record=$(sed -n "/^$year/p" $DATA)

     if [ "$record" = "" ]; then
	echo not found record of $year in $DATA!
        exit 1
     fi
     local F=$(echo $record | awk -F "|" '{print $2}')
     declare -x D=($(echo $record | awk -F "|" '{print $3}'))
     declare -x N=($(echo $record | awk -F "|" '{print $4}'))

     get_year_days $@
     all=$ALL_DAYS
     if [ "$all" = "" ]; then
	echo all_days is null!
        exit 1
     fi
#     set -x

#     set -x
     local is_leap=$(check_leap_year $year)
     local ay=365
     if [ $is_leap -eq 1 ]; then
	ay=366
     fi
 #    set +x

     if [ $all -lt ${D[0]} ]; then
        let m=${N[0]}-1
	if [ $m -eq 0 ]; then
           m=12
	fi
        let r=$F-${D[0]}+$all+1
	c=$F
     elif [ $all -ge ${D[-1]} ]; then
        let m=${N[-1]}-0
        let r=$all-${D[-1]}+1
    	let c=$ay-${D[-1]}+1
     else
        local len=${#D[@]}
        for ((i=1; i < $len; i++)); do
          let f=${D[i]}-$all
          if [ $f -gt 0 ] && [ $f -le 30 ]; then
             let s=${D[i]}-${D[i-1]}
             let m=${N[i-1]}-0
             let r=$s-$f+1
	     c=$s
	     break
          fi
        done
     fi
     TRANS_DATA=($year $m $r $c $ay $all $is_leap)
 #    set +x
  fi
}

function check_leap_year()
{
    if [ $# -eq 1 ]; then
       local y=$1
       let r=y%100
       local s=0
       if [ $r -eq 0 ]; then
         let r=y%400
	 if [ $r -eq 0 ]; then
	    s=1
	 fi
       else
	 let r=y%4
	 if [ $r -eq 0 ]; then
            s=1
	 fi
       fi
       echo $s
    else
      echo It needs 1 arguments for check_leap_year!
      exit 1
    fi
}

function check_day()
{
   if [ $# -ge 2 ]; then
      local day=$1
      if [ $day -lt 1 ] || [ $day -gt 31 ]; then
	 echo day expect range [1, 31].
         exit 1
      fi 
      local month=$2
      if [ $month -lt 1 ] || [ $month -gt 12 ]; then
	 echo month expect range [1, 12].
         exit 1
      fi
      if [ $month -ne 2 ]; then
         echo ,4,6,9,11, | grep -qE ",$month,"
	 if [ $? -eq 0 ]; then
           if [ $day -gt 30 ]; then
              echo day expect range [1, 30].
	      exit 1
           fi
	 fi
      else
	 local is_leap=$3
	 if [ "$is_leap" = "" ]; then
            echo is_leap is null! don not check day!
            exit 1
	 fi
         if [ $is_leap -eq 1 ]; then
	    if [ $day -gt 29 ]; then
               echo day expect range [1, 29].
	       exit 1
	    fi
         else
	    if [ $day -gt 28 ]; then
               echo day expect range [1, 28].
	       exit 1
	    fi
         fi
      fi
   else
      echo it needs 2 arguments for check_day at least!
      exit 1
   fi
}

function get_month_days()
{
   if [ $# -ge 1 ]; then
      local month=$1
      if [ $month -ge 1 ] && [ $month -le 12 ]; then
	 if [ $month -eq 2 ]; then
	    local is_leap=$2
	    if [ "$is_leap" = "" ]; then
	       echo is_leap is null in get_month_days!
               exit 1
	    fi
            if [ $is_leap -eq 1 ]; then
               return 29
            else
               return 28
	    fi
	 fi
	 echo ,1,3,5,7,8,10,12, | grep -qE ",$month,"
	 if [ $? -eq 0 ]; then
            return 31
	 fi
	 echo ,4,6,9,11, | grep -qE ",$month,"
	 if [ $? -eq 0 ]; then
            return 30
	 fi
      else
	echo month illegal! $month
	exit 1
      fi
   else
      echo it needs 3 arguments for get_month_days at least!
      exit 1
   fi
}

function get_year_days()
{
   if [ $# -eq 3 ]; then
      local year=$1
      if [ $year -ge 1901 ] && [ $year -le 2100 ]; then
	 local is_leap=$(check_leap_year $year)
	 local month=$2
         local day=$3
         local sum=0
         check_day $day $month $is_leap
         let sum+=$day 
         for ((i=($month - 1); i > 0; i--)); do
            get_month_days $i $is_leap
	    let sum+=$?
         done
         ALL_DAYS=$sum
      else
	echo year expect range [1901, 2100].
	exit 1
      fi
   else
      echo it needs 3 arguments for get_year_days!
      exit 1
   fi
}

app $*
