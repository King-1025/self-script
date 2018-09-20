#!/bin/bash

CMD="am start -n"
NET="king.easycampusnet/.ui.MainActivity"
QQ="com.tencent.mobileqq/.activity.SplashActivity"
BDWP="com.baidu.netdisk/.ui.Navigate"
HUYA="com.duowan.kiwi/.simpleactivity.SplashActivity"
VPN="com.xfx.surfvpn/.LoadingActivity"
NOTE="com.miui.notes/.ui.NotesListActivity"
BROWSER="com.android.browser/.BrowserActivity"
ARGS=

function help()
{
 echo "Usage:app <net|qq|bdwp|huya|vpn|note|browser>."
}

if [ $# -lt 1 ] || [ $# -gt 1 ]
then
  help
  exit 1
fi

if [ $1 == "net" ]
then  
   ARGS=$NET
elif [ $1 == "qq" ]
then
   ARGS=$QQ
elif [ $1 == "bdwp" ]
then
   ARGS=$BDWP
elif [ $1 == "huya" ]
then	
   ARGS=$HUYA
elif [ $1 == "vpn" ]
then
   ARGS=$VPN
elif [ $1 == "note" ]
then
   ARGS=$NOTE
elif [ $1 == "browser" ]
then
   ARGS=$BROWSER
else
  echo "无效选项$1"
  help
  exit 1
fi

$CMD $ARGS
