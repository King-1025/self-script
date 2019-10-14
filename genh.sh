#!/usr/bin/env bash

#java_compiler="javac"
#java_compile_options="-cp ${java_jar}"

root=code/jni
java_source=$root/layer
java_native_include=$root/include
jni_list=$root/jni.list

java_classes=.jni_class_build

task_step_force=0 #失败时不强制执行
task_all_steps=0
task_current_step=0

function app()
{
   if [ "$1" == "-h" ]; then
      echo "Desc:  生成jni头文件。 by King-1025 (v1.0)"
      echo "Usage: $(basename $0) [java_source] [jni_list] [native_include]"
      echo ""
      exit 0
   fi
   
   if [ "$1" != "" ]; then
      java_source=$1
   fi

   if [ "$2" != "" ]; then
      jni_list=$2
   fi

   if [ "$3" != "" ]; then
      java_native_include=$3
   fi

   echo "jni_list($jni_list):"
   jni_list=$(check_file "${jni_list}" "jni list")
#   echo $(cat $jni_list)
   cat "$jni_list"
   echo ""
   echo "java_source:$java_source"
   echo "java_native_include:$java_native_include"
   echo ""
   update_native_include
}

function update_native_include()
{
  task_all_steps=2
  task_current_step=1
#  java_compiler="remote_tool javac"
#  javah="remote_tool javah"
#  rm -rf ${java_classes}
  assert compile_java_classes "编译源文件"
  assert update_jni_header "更新jni头文件"
}

function compile_java_classes()
{
  local is=1
  echo "=> start to compile java classes..."
  local javac=$(check_tool "javac" "${java_compiler}" "java compile" "javac")
  local all=""
  if [ "$javac" != "" ]; then
     local src=$(check_file "${java_source}" "java source")
     if [ "$src" != "" ]; then
	local origin=$(mktemp -u)
	local target=$(mktemp -u)
	local clean=$(mktemp -u)
        local state=${java_classes}/.status_md5sum
	
	find "$src" -type f -name "*.java" -print > $origin
	all=$(cat $origin)

        handle_source $origin $target $clean $state

        local all=$(cat $origin)
	if [ -e "$clean" ]; then
	   local slen=${#java_source}
           while read line; do
              #rm -rf ${java_classes}/${line:$slen:-5}*.class
              local dm="find ${java_classes} -type f -name \"*.class\" -print | grep -E \"${line:$slen:-5}*.class\" | xargs rm -rf"
              echo $dm && eval $dm
	   done < $clean
	   rm -rf "$clean" > /dev/null 2>&1
	fi
        if [ -e "$target" ]; then
	   local list=$(cat $target)
	   if [ "$list" = "up-to-date" ]; then
	       list=""
               is=0
           fi
	   if [ "$list" != "" ]; then
	      local comm="$javac"
	      echo "$comm" | grep -E "^remote_tool"
	      if [ $? -ne 0 ]; then
                 comm+=" -d ${java_classes} ${java_compile_options} ${list}"
	      else
		 rm -rf ${java_classes} 
                 java_source=$all 
	      fi
	      if [ "$comm" != "" ]; then
                 echo "$comm" && $comm
	         is=$?
	      fi
	   #else
	   #   echo "not found any compileble java source files!"
           fi
 	   rm -rf "$target" > /dev/null 2>&1
        fi
	rm -rf "$origin" > /dev/null 2>&1
     else
	echo "please checkout requirements for compile java classes."
     fi
  fi
  return $is
}

function update_jni_header()
{
  local is=1
  echo "=> start to update jni header..."
  local javah=$(check_tool "javah" "${javah}" "javah" "javah")
  if [ "$javah" != "" ]; then
     local classes=$(check_file "${java_classes}" "java classes")
     local jni_list=$(check_file "${jni_list}" "jni list file")
     if [ "$classes" != "" ]&&[ "$jni_list" != "" ]; then
	mkdir -p ${java_native_include}
	rm -rf ${java_native_include}/*.h
        local comm="$javah"
	echo "$comm" | grep -E "^remote_tool"
	if [ $? -ne 0 ]; then
           comm+=" -force -d ${java_native_include} -cp ${classes} -jni $(cat $jni_list)"
	else
           jni_header_input="${classes}"
	   jni_header_handle="-force -cp ${classes} -jni $(cat $jni_list)"
	fi
	if [ "$comm" != "" ]; then
	   echo "$comm" && $comm
	   is=$?
	fi
     else
	echo "please checkout requirements for update jni header."
     fi
  fi
  return $is
}

function remote_tool()
{
  if [ $# -eq 1 ]; then
     local tag=$1
     local remote="upss -dt -dh -r -e ssh"
     local input=""
     local handle=""
     local output=""
     local build="$(basename $(mktemp -u))"
     local rpt=.tmp/jnih/remote
     local path=/home/test0/ftp/jnih/remote
     case "$tag" in
        "javac")
	    input="${java_source}"
	    handle="javac -d ${build} ${java_source}"
	    output="${java_classes}"
	;;
        "javah")
	    input="${jni_header_input}"
            handle="javah -d ${build} ${jni_header_handle}"
	    output="${java_native_include}"
	;;
     esac
     if [ "$input" != "" ]&&[ "$handle" != "" ]; then
        local tmp=$(mktemp -u)
	local wk=$(basename $tmp)
	tar -czf ${tmp} ${input}	
	if [ -e "$tmp" ]; then
	   sf put $rpt/$wk.tgz $tmp
	   $remote "cd $path;
	            mkdir -p $wk;
		    mv $wk.tgz $wk;
		    cd $wk;
	            tar -xzf $wk.tgz;
		    mkdir -p $build;
		    $handle;
		    tar -czf $path/$wk.tgz $build;
		    cd $path;
                    rm -rf $wk;"
	   if [ "$output" != "" ]; then
	      sf get $tmp $rpt/$wk.tgz
	      mkdir -p ${output}
              tar -xzf ${tmp}
	      mv ${build}/* ${output}/
	      rm -rf $build
	   fi
	   rm -rf $tmp
	   $remote "rm -rf $path/$wk.tgz" 
	fi
      fi
  fi
}

function handle_source()
{
  if [ $# -eq 4 ]; then
   if [ -e "$1" ]; then
     local save=$2
     local clean=$3
     local state=$4
     declare -a target=()
     declare -a origin=($(cat $1))
     local size=${#origin[@]}
     if [ ! -e "$state" ]; then
	target=${origin[@]}
     else
        local check=$(mktemp -u)
	md5sum -c "$state" > "$check" 2>&1
	if [ -e "$check" ]; then
	   local ch=0; local up=0; local ne=0; local de=0
	   sed -i "/^md5sum:/d" "$check"
  	   sed -i "s/: /*/g" "$check"
           for((i=0,j=0;i<$size;i++)); do
             local item=${origin[i]}
  	     local isOk=$(cat "$check" | awk -F "*" -v item="$item" '{if($1 == item)print $2}')
	     local isAdd=0
	     if [ "$isOk" != "" ]; then
  	        if [ "$isOk" != "OK" ]; then
		   isAdd=1
		   printf "\e[1;33m%-5s ===> %s\e[m\n" ":changed" "$item"
		   ((ch++))
		else
		   printf "\e[1;37m%-5s ===> %s\e[m\n" ":up-to-date" "$item"
		   ((up++))
		fi
                local rgx=$(echo "$item" | sed "s/\//\./g")
  		sed -i "/$rgx/d" "$check"
	     else
		isAdd=1
		printf "\e[1;34m%-5s ===> %s\e[m\n"  ":new" "$item"
		((ne++))
  	     fi
             if [ "$isAdd" -eq 1 ]; then
  	        target[j]=$item
  		((j++))
             fi
  	   done
	   declare -a delist=($(cat "$check" | awk -F "*" '{print $1}'))
	   de=${#delist[@]}
           rm -rf "$clean" > /dev/null 2>&1
	   for((i=0;i<$de;i++)); do
	     local item=${delist[i]}
	     echo "$item" >> $clean
	     printf "\e[1;31m%-5s ===> %s\e[m\n"  ":deleted" "$item"
	   done
	   unset i; unset j
  	   rm -rf "$check"
	   printf "\e[1;37m::origin:$size\e[m \e[1;33mchanged:$ch\e[m \e[1;37mup-to-date:$up\e[m \e[1;34mnew:$ne\e[m \e[1;31mdeleted:$de\e[m\n"
	   if [ "$size" = "$up" ]&&[ "${#target[@]}" -eq 0 ]; then
	      target=("up-to-date")
	   fi
        else
	   printf "${state} maybe bad,skip!\n"
	   target=${origin[@]}
	fi
     fi
     if [ $size -gt 0 ]; then
        mkdir -p $(dirname "$state")
        md5sum "${origin[@]}" > "$state"
     fi
     size=${#target[@]}
     rm -rf "$save" > /dev/null 2>&1
     for ((i=0;i<$size;i++)); do
        echo "${target[i]}" >> "$save"
     done
     unset i
   fi
  fi
}

function check_tool()
{
  local tool=""
  if [ $# -eq 4 ]; then
     tool=$1
     if [ "$2" != "" ]; then
	tool=$2
     else
       which $tool > /dev/null 2>&1
       if [ $? -ne 0 ]; then
	  read -p "sorry,not found $3 tool.would you like to try remote $3 tool?(yes/no)" option
          case "$option" in
	     "yes") tool="remote_tool $4" ;;
	     "no") tool="";;
	      * ) exit 0 ;;
          esac
	  unset option
       fi
    fi
  fi
  echo "$tool"
}

function check_file()
{
   local file=""
   if [ $# -eq 2 ]; then
     file=$1
     if [ ! -e "$1" ]; then
	read -p "$2($1) isn't exist! would you like to reset it?(yes/no)" option
        case "$option" in
	     "yes") read -p "please input $2 path:" file;;
	     "no") file="";;
	      * ) exit 0 ;;
        esac
        unset option
     fi
  fi
  echo "$file"
}

function assert()
{
  if [ $# -eq 2 ]; then
     local step=$1
     local tag=$2
     local all_steps=${task_all_steps}
     local current_step=${task_current_step}
     if [ "$all_steps" = "" ]; then all_steps="*"; fi
     if [ "$current_step" = "" ]; then current_step="*"; fi 
     echo "$step(${all_steps}/${current_step})" && $step
     if [ $? -ne 0 ]&&[ ${task_step_force} -ne 1 ]; then
	while true; do
	   read -p "$tag faild! do you want to continue next step?(yes/no)" option
	   case "$option" in
		"yes") break;;
		"no") exit 0;;
		"*") continue;;
	   esac
        done
     fi
     if [ "$current_step" != "*" ]; then
	if [ "$current_step" = "$all_steps" ]; then exit 0; fi
        ((current_step++)) > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	   task_current_step=$current_step
        fi
     fi
     printf "\n"
  else
    echo "assert needs 2 arguments!"
  fi
}

app $*
