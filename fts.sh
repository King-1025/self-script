#!/usr/bin/env bash

declare -a FONTS=(
    'AlBayan'
    'AlBayanBold'
    'Andale Mono'
    'AndaleMono'
    'Anonymice Powerline Bold Italic'
    'Anonymice Powerline Bold'
    'Anonymice Powerline Italic'
    'Anonymice Powerline'
    'Apple Braille Outline 6 Dot'
    'Apple Braille Outline 8 Dot'
    'Apple Braille Pinpoint 6 Dot'
    'Apple Braille Pinpoint 8 Dot'
    'Apple Braille'
    'Apple Chancery'
    'Apple Color Emoji'
    'Apple LiGothic Medium'
    'Apple LiSung Light'
    'Apple Symbols'
    'AppleGothic'
    'AppleMyungjo'
    'Arial Black'
    'Arial Bold Italic'
    'Arial Bold'
    'Arial Italic'
    'Arial Narrow Bold Italic'
    'Arial Narrow Bold'
    'Arial Narrow Italic'
    'Arial Narrow'
    'Arial Rounded Bold'
    'Arial Unicode'
    'Arial'
    'Ayuthaya'
    'BPmono'
    'BPmonoBold'
    'BPmonoBoldStencil'
    'BPmonoItalics'
    'Baghdad'
    'BiauKai'
    'BigCaslon'
    'Brush Script'
    'Century_Schoolbok'
    'Chalkboard'
    'Chalkduster'
    'Comic Sans MS Bold'
    'Comic Sans MS'
    'ComicSans'
    'Consolas'
    'Courier New Bold Italic'
    'Courier New Bold'
    'Courier New Italic'
    'Courier New'
    'Courier_New'
    'Cousine-Bold'
    'Cousine-BoldItalic'
    'Cousine-Italic'
    'Cousine-Regular'
    'DIN Alternate Bold'
    'DIN Condensed Bold'
    'DecoTypeNaskh'
    'DejaVu Sans Mono Bold Oblique for Powerline'
    'DejaVu Sans Mono Bold for Powerline'
    'DejaVu Sans Mono Oblique for Powerline'
    'DejaVu Sans Mono for Powerline'
    'DejaVuSansMono-Bold'
    'DejaVuSansMono-BoldOblique'
    'DejaVuSansMono-Oblique'
    'DejaVuSansMono'
    'DevanagariMT'
    'DevanagariMTBold'
    'Droid Sans Mono for Powerline'
    'DroidSans-Bold'
    'DroidSans'
    'DroidSansFallback'
    'DroidSansMono'
    'FantasqueSansMono-Bold'
    'FantasqueSansMono-BoldItalic'
    'FantasqueSansMono-RegItalic'
    'FantasqueSansMono-Regular'
    'FiraMono-Bold'
    'FiraMono-Regular'
    'Geeza Pro Bold'
    'Geeza Pro'
    'Georgia Bold Italic'
    'Georgia Bold'
    'Georgia Italic'
    'Georgia'
    'GujaratiMT'
    'GujaratiMTBold'
    'Gungseouche'
    'Gurmukhi'
    'Hack-Bold'
    'Hack-BoldOblique'
    'Hack-Regular'
    'Hack-RegularOblique'
    'HeadlineA'
    'Hei'
    'Helvetica'
    'Herculanum'
    'Hoefler Text Ornaments'
    'Impact'
    'InaiMathi'
    'Inconsolata for Powerline'
    'Inconsolata-dz for Powerline'
    'Inconsolata-g-Powerline'
    'Inconsolata'
    'Isonorm MN'
    'Jan Fromm - CamingoCode Bold Italic'
    'Jan Fromm - CamingoCode Bold'
    'Jan Fromm - CamingoCode Italic'
    'Jan Fromm - CamingoCode Regular'
    'Kai'
    'Kailasa'
    'Keyboard'
    'Khmer Sangam MN'
    'Kokonor'
    'Krungthep'
    'KufiStandardGK'
    'Lao Sangam MN'
    'LastResort'
    'LetterGothic'
    'Literation Mono Powerline Bold Italic'
    'Literation Mono Powerline Bold'
    'Literation Mono Powerline Italic'
    'Literation Mono Powerline'
    'Lucida_Grande'
    'Menlo-Regular'
    'Meslo LG L DZ Regular for Powerline'
    'Meslo LG L Regular for Powerline'
    'Meslo LG M DZ Regular for Powerline'
    'Meslo LG M Regular for Powerline'
    'Meslo LG S DZ Regular for Powerline'
    'Meslo LG S Regular for Powerline'
    'Microsoft Sans Serif'
    'Monoisome-Regular'
    'MshtakanBold'
    'MshtakanBoldOblique'
    'MshtakanOblique'
    'MshtakanRegular'
    'Myanmar Sangam MN'
    'NISC18030'
    'Nadeem'
    'Osaka'
    'OsakaMono'
    'PCmyoungjo'
    'PF Din Mono Bold Italic'
    'PF Din Mono Bold'
    'PF Din Mono ExtraThin Italic'
    'PF Din Mono ExtraThin'
    'PF Din Mono Italic'
    'PF Din Mono Light Italic'
    'PF Din Mono Light'
    'PF Din Mono Medium Italic'
    'PF Din Mono Medium'
    'PF Din Mono Thin Italic'
    'PF Din Mono Thin'
    'PF Din Mono'
    'PTM55F'
    'PTM75F'
    'Pilgiche'
    'PlantagenetCherokee'
    'PragmataPro'
    'ProggyClean'
    'ProggyCleanCE'
    'ProggySmall'
    'ProggySquare'
    'ProggyTinySZ'
    'README'
    'Sathu'
    'Sauce Code Powerline Black'
    'Sauce Code Powerline Bold'
    'Sauce Code Powerline ExtraLight'
    'Sauce Code Powerline Light'
    'Sauce Code Powerline Medium'
    'Sauce Code Powerline Regular'
    'Sauce Code Powerline Semibold'
    'Silom'
    'Skia'
    'Symbol'
    'Tahoma Bold'
    'Tahoma'
    'Times New Roman Bold Italic'
    'Times New Roman Bold'
    'Times New Roman Italic'
    'Times New Roman'
    'Trebuchet MS Bold Italic'
    'Trebuchet MS Bold'
    'Trebuchet MS Italic'
    'Trebuchet MS'
    'Ubuntu Mono derivative Powerline Bold Italic'
    'Ubuntu Mono derivative Powerline Bold'
    'Ubuntu Mono derivative Powerline Italic'
    'Ubuntu Mono derivative Powerline'
    'Ubuntu-B'
    'Ubuntu-BI'
    'Ubuntu-C'
    'Ubuntu-L'
    'Ubuntu-LI'
    'Ubuntu-M'
    'Ubuntu-MI'
    'Ubuntu-R'
    'Ubuntu-RI'
    'UbuntuMono-B'
    'UbuntuMono-BI'
    'UbuntuMono-R'
    'UbuntuMono-RI'
    'Vera-Bold-Italic'
    'Vera-Bold'
    'Vera-Italic'
    'Vera'
    'VeraMono-Bold-Italic'
    'VeraMono-Bold'
    'VeraMono-Italic'
    'VeraMono'
    'VeraSerif-Bold'
    'VeraSerif'
    'Verdana Bold Italic'
    'Verdana Bold'
    'Verdana Italic'
    'Verdana'
    'Webdings'
    'Wingdings 2'
    'Wingdings 3'
    'Wingdings'
    'ZapfDingbats'
    'Zapfino'
    'arial-monospaced-mt'
    'iosevka-bold'
    'iosevka-bolditalic'
    'iosevka-italic'
    'iosevka-regular'
    'iosevkacc-bold'
    'iosevkacc-bolditalic'
    'iosevkacc-italic'
    'iosevkacc-regular'
    'monaco'
    'monof55'
    'monof56'
    'mplus-1mn-bold'
    'mplus-1mn-light'
    'mplus-1mn-medium'
    'mplus-1mn-regular'
    'mplus-1mn-thin'
)
FONTS_SIZE=${#FONTS[@]}

function display_options()
{
  echo -e "\nFonts:"
  local number=1
  for ft in "${FONTS[@]}"; do
    echo -e "\t($number) $ft"
    ((number++))
  done
  echo ""
}

ask_user()
{
  while true; do  
    read -p "do you want to see menu ?(yes/no) " INTENT 
    if [ "$INTENT" == "yes" ]; then
      display_options
      break
    elif [ "$INTENT" == "no" ];then
      echo -e "\nNotice:font range is [1,$FONTS_SIZE]\n"
      break
    fi                                                       
  done
}


function menu()
{
#  set -x
  echo "=========FONTS========"
  ask_user
  read -p "Enter your option:" OPTION
  printf %d $OPTION > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    if [ $OPTION -ge 1 ]&&[ $OPTION -le $FONTS_SIZE ]; then
       ((OPTION--))
#       echo OPTION:$OPTION
       local value=$(echo "${FONTS[OPTION]}" | sed "s/ /%20/g")
       local font_url="https://github.com/King-1025/fonts/raw/master/${value}.ttf"
       local tmp=$(mktemp -u)
       echo -e "\nDownload $font_url...\n"
       curl -sL -o "$tmp" "$font_url" 
       if [ $? -eq 0 ]&&[ -e $tmp ]; then
         cp -fr "$tmp" "$HOME/.termux/font.ttf";
         termux-reload-settings
         if [ $? -eq 0 ]; then
           echo "${FONTS[OPTION]}"
           echo "Enjoy yourself!"
         fi
       fi
       rm -rf $tmp > /dev/null 2>&1
    fi
  fi
}

menu
