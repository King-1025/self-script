#!/usr/bin/env bash

#set -x

sysdir=$KALI_HOME
basedir=/root/ME
java_home=/opt/jdk1.8.0_181 
classpath=.:$java_home/lib:$java_hone/jre/lib
gradle_home=/opt/gradle-5.0-rc-4
android_home=/opt/android-sdk-linux
path=/bin:/usr/bin:/sbin:/usr/sbin:$java_home/bin:$java_home/jre/bin:$gradle_home/bin
extra="-b $SD_0/AppProjects:/root/AIDE"

ld_preload=$LD_PRELOAD

unset LD_PRELOAD

#set -x
xp=./
if [ "$1" = "-p" ]; then
   xp=$2
   echo "shadow path:$xp"
   shift 2
fi
#set +x

proot --link2symlink -0 -r $sysdir -b /dev -b /proc -b /sys -b $xp:$basedir $extra -w $basedir /usr/bin/env -i HOME=$basedir USER=root TERM="xterm-256color" LANG=en_US.UTF-8 JAVA_HOME=$java_home CLASSPATH=$classpath GRADLE_HOME=$gradle_home ANDROID_HOME=$android_home PATH=$path $@

export LD_PRELOAD=$ld_preload
