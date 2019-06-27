#!/data/data/com.termux/files/usr/bin/env bash

CMD="am start"
BASE_OPTION="-a android.intent.action.VIEW -c android.intent.category.DEFAULT"

INSTALL_OPTION="-t application/vnd.android.package-archive"
VIEW_OPTION="-t text/html"
TXT_OPTION="-t text/plain"
PDF_OPTION="-t application/pdf"
DOC_OPTION="-t application/msword"

URI=

function help()
{
  echo "Usage:android <install|view [-f]|doc> URI."
}

if [ $# -lt 2 ] || [ $# -gt 3 ]
then
  help
  exit 1
fi

if [ $1 == "install" ]
then
   OPTION=$INSTALL_OPTION
   if [ ${2:0:1} == "/" ]
   then
      URI="file://$2"
   else
      URI="file://$PWD/$2"
   fi
elif [ $1 == "view" ]
then
   OPTION=$VIEW_OPTION
   if [ $# != 3 ]
   then
      if [ ${2:0:7} != "http://" ] && [ ${2:0:8} != "https://" ]
      then
         URI="http://$2"
      else
	 URI="$2"
      fi
   else
      if [ $2 == "-f" ]
      then
        if [ ${3:0:1} == "/" ]
        then
          URI="file://$3"
        else
          URI="file://$PWD/$3"
	fi
      else
	echo "无效选项$2"
	help
	exit 1
      fi
   fi
elif [ $1 == "doc" ]
then
   OPTION=$DOC_OPTION
   if [ ${2:0:1} == "/" ]
   then
      URI="file://$2"
   else
      URI="file://$PWD/$2"
   fi
elif [ $1 == "txt" ]
then
   OPTION=$TXT_OPTION
   if [ ${2:0:1} == "/" ]
   then
      URI="file://$2"
   else
      URI="file://$PWD/$2"
   fi
elif [ $1 == "pdf" ]
then
   OPTION=$PDF_OPTION
   if [ ${2:0:1} == "/" ]
   then
      URI="file://$2"
   else
      URI="file://$PWD/$2"
   fi
else
   echo "无效选项$1"
   help
   exit 1
fi

$CMD $BASE_OPTION $OPTION -d "$URI"
