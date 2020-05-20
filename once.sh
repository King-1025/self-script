#!/usr/bin/env bash

#set -x

sysdir=$KALI_HOME
basedir=/root/ME
java_home=/usr/lib/jvm/java-1.8.0-openjdk-arm64
classpath=.:$java_home/lib:$java_hone/jre/lib
gradle_home=/opt/gradle-5.0-rc-4
android_home=/opt/android-sdk
qemu_home=/opt/qemu
self=/root/self
path=/bin:/usr/bin:/sbin:/usr/sbin:$java_home/bin:$java_home/jre/bin:$gradle_home/bin:$qemu_home/bin:/usr/local/bin:$self/bin:/root/.cargo/bin
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

proot --link2symlink -0 -r $sysdir $(sed -n "/^-b/p" $HOME/.kali_dev) -b /proc -b /sys -b $HOME:/termux -b $xp:$basedir $extra -w $basedir /usr/bin/env -i HOME=/root USER=root TERM="xterm-256color" LANG=en_US.UTF-8 JAVA_HOME=$java_home CLASSPATH=$classpath GRADLE_HOME=$gradle_home ANDROID_SDK_ROOT=$android_home SELF=$self GLIVE_EXEC="./script/gff json" PATH=$path $@

export LD_PRELOAD=$ld_preload
