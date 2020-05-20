#!/usr/bin/env bash

EXEC="am start"

function app()
{
   local type=$1
   shift
   case "$type" in
     "br"|"browser") browser $*;;
     "fm"|"file_manager") file_manager $*;;
     "ap"|"app") open_app $*;;
     "ga"|"gallery") gallery $*;;
     "ot"|"other") android $*;;
     *) echo "support: browser, file_manager, app, gallery, other";;
   esac
}

function gallery()
{
   local action=$1
   local path=$2
   local comm=""
   case "$action" in
     "oppo") 
	 local package="com.coloros.gallery3d"
         comm="$EXEC $package"
     ;;
     *) echo support: oppo && exit 0;;
   esac
   run_command "$comm"
}

function open_app()
{
   local action=$1
   local option="-n"
   local comp=""
   case "$action" in
     "qq") comp="com.tencent.mobileqq/.activity.SplashActivity";;
     "bdwp") comp="com.baidu.netdisk/.ui.Navigate";;
     "net") comp="king.easycampusnet/.ui.MainActivity";;
     "huya") comp="com.duowan.kiwi/.simpleactivity.SplashActivity";;
     "vpn") comp="com.xfx.surfvpn/.LoadingActivity";;
     "note") comp="com.miui.notes/.ui.NotesListActivity";;
     "browser") comp="com.android.browser/.BrowserActivity";;
     *) echo "support: net, qq, bdwp, huya, vpn, note, browser" && exit 0 ;;
   esac
   local comm="$EXEC $option $comp"
   run_command "$comm"
}

function file_manager()
{
   local action=$1
   local path=$2
   local comm=""
   case "$action" in
     "es")
	 if [ "$path" == "" ]; then
	    path="$OO"
	 fi
	 if [ -e "$path" ]; then
	    if [ -d "$path" ]; then
   	       local package="com.estrongs.android.pop"
               local option="-a org.openintents.action.VIEW_DIRECTORY -c android.intent.category.DEFAULT"
	       local ff=$(get_file $path)
	       if [ "$ff" != "" ]; then
                  comm="$EXEC $option -d $ff $package"
	       fi
	    else
	       echo "not dir! $path" && exit 1
            fi
	 else
	    echo "not exist! $path" && exit 1
	 fi
     ;;
     "oppo") 
	 local package="com.coloros.filemanager"
	 local option="-a oppo.filemanager.intent.action.BROWSER_FILE -c android.intent.category.DEFAULT"
	 comm="$EXEC $option $package"
     ;;
     *) echo "support: es, oppo";;
   esac
   run_command "$comm"
}

function browser()
{
   local action=$1
   local data=$2
   local package=""
   local option="-a android.intent.action.VIEW -c android.intent.category.DEFAULT -c android.intent.category.BROWSABLE"
   case "$action" in
	"via") package="mark.via";;
	"oppo") package="com.android.browser";;
	"chrome") package="com.android.chrome";;
	"firefox") package="org.mozilla.firefox";;
	*) echo "support: via, oppo, chrome, firefox"; exit 0;;
   esac
   if [ "$package" != "" ]; then
      local comm=""
      if [ "$data" != "" ]; then
	 if [ "$data" == "-f" ]; then
	    local ff=$(get_file $3)
	    if [ "$ff" != "" ]; then
	       case "$action" in
		  "via"|"firefox") comm="$EXEC $option -t text/plain -d $ff $package";;
	          *) echo "'-f' not support $action";;
	       esac
	    else
	       echo "$3 not exist!"
	    fi
	 else
	   local data=$(get_url $data)
	   if [ "$data" != "" ]; then
   	      comm="$EXEC $option -d $data $package"
	   fi
	 fi
      else
	 comm="$EXEC $package"
      fi
   fi
   run_command "$comm"
}

function run_command()
{
   local comm=$1
   if [ "$comm" != "" ]; then 
      if [ "$DEBUG" == "1" ]; then echo -e "$comm\n"; fi
      eval $comm
   fi
}

function get_file()
{
   if [ $# -eq 1 ]; then
      local path=$1
      if [ -e $path ]; then
         if [ ${path:0:1} == "/" ]; then
            echo "file://$path"
         else
            echo "file://$PWD/$path"
         fi
      fi
   fi
}

function get_url()
{
   if [ $# -eq 1 ]; then
      local url=$1
      if [ ${url:0:7} != "http://" ] && [ ${url:0:8} != "https://" ]; then
         echo "http://$url"
      else
	 echo "$url"
      fi
   fi
}

app $*
