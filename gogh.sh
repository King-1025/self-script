#!/usr/bin/env bash

declare -a THEMES=(
    '3024-day.sh'
    '3024-night.sh'
    'aci.sh'
    'aco.sh'
    'adventuretime.sh'
    'afterglow.sh'
    'alien-blood.sh'
    'argonaut.sh'
    'arthur.sh'
    'atom.sh'
    'azu.sh'
    'belafonte-day.sh'
    'belafonte-night.sh'
    'bim.sh'
    'birds-of-paradise.sh'
    'blazer.sh'
    'borland.sh'
    'broadcast.sh'
    'brogrammer.sh'
    'c64.sh'
    'cai.sh'
    'chalk.sh'
    'chalkboard.sh'
    'ciapre.sh'
    'clone-of-ubuntu.sh'
    'clrs.sh'
    'cobalt-neon.sh'
    'cobalt2.sh'
    'crayon-pony-fish.sh'
    'dark-pastel.sh'
    'darkside.sh'
    'desert.sh'
    'dimmed-monokai.sh'
    'dracula.sh'
    'earthsong.sh'
    'elemental.sh'
    'elementary.sh'
    'elic.sh'
    'elio.sh'
    'espresso-libre.sh'
    'espresso.sh'
    'fishtank.sh'
    'flat.sh'
    'flatland.sh'
    'foxnightly.sh'
    'freya.sh'
    'frontend-delight.sh'
    'frontend-fun-forrest.sh'
    'frontend-galaxy.sh'
    'github.sh'
    'gooey.sh'
    'grape.sh'
    'grass.sh'
    'gruvbox-dark.sh'
    'gruvbox.sh'
    'hardcore.sh'
    'harper.sh'
    'hemisu-dark.sh'
    'hemisu-light.sh'
    'highway.sh'
    'hipster-green.sh'
    'homebrew.sh'
    'hurtado.sh'
    'hybrid.sh'
    'ic-green-ppl.sh'
    'ic-orange-ppl.sh'
    'idle-toes.sh'
    'ir-black.sh'
    'jackie-brown.sh'
    'japanesque.sh'
    'jellybeans.sh'
    'jup.sh'
    'kibble.sh'
    'later-this-evening.sh'
    'lavandula.sh'
    'liquid-carbon-transparent.sh'
    'liquid-carbon.sh'
    'man-page.sh'
    'mar.sh'
    'material.sh'
    'mathias.sh'
    'medallion.sh'
    'misterioso.sh'
    'miu.sh'
    'molokai.sh'
    'mona-lisa.sh'
    'monokai-dark.sh'
    'monokai-soda.sh'
    'n0tch2k.sh'
    'neopolitan.sh'
    'nep.sh'
    'neutron.sh'
    'nightlion-v1.sh'
    'nightlion-v2.sh'
    'nighty.sh'
    'nord-light.sh'
    'nord.sh'
    'novel.sh'
    'obsidian.sh'
    'ocean-dark.sh'
    'ocean.sh'
    'oceanic-next.sh'
    'ollie.sh'
    'one-dark.sh'
    'one-half-black.sh'
    'one-light.sh'
    'pali.sh'
    'paraiso-dark.sh'
    'paul-millr.sh'
    'pencil-dark.sh'
    'pencil-light.sh'
    'peppermint.sh'
    'pnevma.sh'
    'pro.sh'
    'red-alert.sh'
    'red-sands.sh'
    'rippedcasts.sh'
    'royal.sh'
    'sat.sh'
    'sea-shells.sh'
    'seafoam-pastel.sh'
    'seti.sh'
    'shaman.sh'
    'shel.sh'
    'slate.sh'
    'smyck.sh'
    'snazzy.sh'
    'soft-server.sh'
    'solarized-darcula.sh'
    'solarized-dark-higher-contrast.sh'
    'solarized-dark.sh'
    'solarized-light.sh'
    'spacedust.sh'
    'spacegray-eighties-dull.sh'
    'spacegray-eighties.sh'
    'spacegray.sh'
    'spring.sh'
    'square.sh'
    'srcery.sh'
    'sundried.sh'
    'symphonic.sh'
    'teerb.sh'
    'terminal-basic.sh'
    'terminix-dark.sh'
    'thayer-bright.sh'
    'tin.sh'
    'tomorrow-night-blue.sh'
    'tomorrow-night-bright.sh'
    'tomorrow-night-eighties.sh'
    'tomorrow-night.sh'
    'tomorrow.sh'
    'toy-chest.sh'
    'treehouse.sh'
    'twilight.sh'
    'ura.sh'
    'urple.sh'
    'vag.sh'
    'vaughn.sh'
    'vibrant-ink.sh'
    'warm-neon.sh'
    'wez.sh'
    'wild-cherry.sh'
    'wombat.sh'
    'wryan.sh'
    'zenburn.sh'
)

capitalize() {
    local ARGUMENT=$1
    local RES=""
    local STR=""
    local RES_NO_TRAIL_SPACE=""

    for CHAR in $ARGUMENT
    do
        STR=$(echo "${CHAR:0:1}" | tr "[:lower:]" "[:upper:]")"${CHAR:1} "
        RES="${RES}${STR}"
        RES_NO_TRAIL_SPACE="$(echo -e "${RES}" | sed -e 's/[[:space:]]*$//')"
    done

    echo "${RES_NO_TRAIL_SPACE}"
}

curlsource() {
    local F=$(mktemp -t curlsource)
    curl -o "$F" -s -L "$1"
    source "$F"
    rm -f "$F"
}

set_gogh() {
    string=$1
    string_r="${string%???}"
    string_s=${string_r//\./_}
    result=$(capitalize "${string_s}")
    url="https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/$1"
    IS_TERMUX="no"
    check_termux
    if [ $? -eq 0 ]; then
       IS_TERMUX="yes"
    fi
    if [ "$(uname)" = "Darwin" ]; then
        # OSX ships with curl
        # Note: sourcing directly from curl does not work
        export {PROFILE_NAME,PROFILE_SLUG}="$result" && curlsource "${url}"
    elif [ "$IS_TERMUX" = "yes" ]; then
        # for android termux
        export {PROFILE_NAME,PROFILE_SLUG}="$result" && for_termux "${url}"
    else
        export {PROFILE_NAME,PROFILE_SLUG}="$result" && bash <(wget -O - "${url}")
    fi
}

remove_file_extension (){
    echo "${1%.*}"
}

check_termux(){
   hash termux-reload-settings
   return $?
}

for_termux (){
  if [ $# -ne 1 ]; then
     echo "function for_termux only needs one argument!"
     exit 0
  fi
  local theme=$(mktemp)
  curl -s -L -o $theme $1
  declare -a colors=($(sed -n '/"#......"/p' $theme | sed 's/.*"\(.*\)".*/\1/g'))
  local size=${#colors[@]}
  if [ $size -lt 18 ]; then
     echo "search color error! size:$size"
     echo "url:$1"
     exit 1
  fi
  local bgidx=16
  local fgidx=17
  local path=$HOME/.termux
  local config=$path/colors.properties
  if [ ! -e "$path" ]; then
     mkdir -p $path
  fi
  echo "# Theme:$PROFILE_NAME" > $config
  echo "# Author:King-1025" >> $config
  echo "# Date:$(date '+%Y-%M-%d %M:%H:%S')" >> $config
  for ((i=0;i<${size};i++));do
      if [ $i -eq $bgidx ]; then
	 echo "background=${colors[i]}" >> $config
	 continue
      fi
      if [ $i -eq $fgidx ]; then
	 echo "foreground=${colors[i]}" >> $config
         echo "cursor=${colors[i]}" >> $config
	 break
      fi
      echo "color$i=${colors[i]}" >> $config
  done
  termux-reload-settings
  if [ $? -eq 0 ]; then
     echo "Hi,enjoy youself!"
  else
     echo "Sorry,faild to update theme.Please check termux-reload-settings"
  fi
  rm -rf $theme > /dev/null 2>&1
}

### Get length of an array
ARRAYLENGTH=${#THEMES[@]}
NUM=1

# |
# | ::::::: Print Colors
# |
label="Gogh-King"
echo -e "
$label\n
\033[0;30m█████\\033[0m\033[0;31m█████\\033[0m\033[0;32m█████\\033[0m\033[0;33m█████\\033[0m\033[0;34m█████\\033[0m\033[0;35m█████\\033[0m\033[0;36m█████\\033[0m\033[0;37m█████\\033[0m
\033[0m\033[1;30m█████\\033[0m\033[1;31m█████\\033[0m\033[1;32m█████\\033[0m\033[1;33m█████\\033[0m\033[1;34m█████\\033[0m\033[1;35m█████\\033[0m\033[1;36m█████\\033[0m\033[1;37m█████\\033[0m"

# |
# | ::::::: Print Themes
# |
display_options(){
echo -e "\nThemes:\n"

for TH in "${THEMES[@]}"; do

    KEY=$(printf "%02d" $NUM)
    FILENAME=${TH::$((${#TH}-3))}
    FILENAME_SPACE=${FILENAME//-/ }

    echo -e "    (\\033[0m\033[0;34m $KEY \\033[0m\033[0m) $(capitalize "${FILENAME_SPACE}")"

    ((NUM++))

done
}
ask_user(){
while true; do
read -p "do you want to see menu ?(yes/no) " INTENT
if [ "$INTENT" == "yes" ]; then
  display_options
  break
elif [ "$INTENT" == "no" ];then
  echo -e "\nNotice:theme range is [01,02,03...${#THEMES[@]}]\n"
  break
fi
done
}
# |
# | ::::::: Select Option
# |
ask_user
echo -e "\nUsage : Enter Desired Themes Numbers (\\033[0m\033[0;34mOPTIONS\\033[0m\033[0m) Separated By A Blank Space"
echo -e "        Press \033[0;34mENTER\\033[0m without options to Exit\n"
read -p 'Enter OPTION(S) : ' -a OPTION


# |
# | ::::::: Apply Theme
# |
option_size=${#OPTION[@]}
for ((index=0;index<${option_size};index++)); do
    OP=${OPTION[index]}
    if [[ OP -le ARRAYLENGTH && OP -gt 0 ]]; then

        FILENAME=$(remove_file_extension "${THEMES[((OP-1))]}")
        FILENAME_SPACE="${FILENAME//-/ }"
	echo -e "\nTheme($index:$OP): $(capitalize "${FILENAME_SPACE}")\n\033[0;30m•\\033[0m\033[0;31m•\\033[0m\033[0;32m•\\033[0m\033[0;33m•\\033[0m\033[0;34m•\\033[0m\033[0;35m•\\033[0m\033[0;36m•\\033[0m\033[0;37m•\\033[0m \033[0;37m•\\033[0m\033[0;36m•\\033[0m\033[0;35m•\\033[0m\033[0;34m•\\033[0m\033[0;33m•\\033[0m\033[0;32m•\\033[0m\033[0;31m•\\033[0m\033[0;30m•\\033[0m\n"

        SET_THEME="${THEMES[((OP-1))]}"
        set_gogh "${SET_THEME}"
	if [ "$IS_TERMUX" = "yes" ]; then
	 if [ $index -lt $(($option_size-1)) ] ; then
	   echo "Please wait a while.Then update next Theme. "
	   sleep 3
	 fi
        fi
    else
        echo -e "\\033[0m\033[0;31m ~ INVALID OPTION! ~\\033[0m\033[0m"
        exit 1
    fi

done
