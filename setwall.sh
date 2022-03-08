#!/usr/bin/bash

# Solo para Deepin Linux, para otros SO modificar a gusto
# Only tested in Deepin Linux, for other OS modify to taste

# VARIABLES
# ===============================================
proxy="tu_proxy:port" # En caso de usar proxy especificarlo aquí
wallpaperFolder=$HOME/Pictures/setwall  # Wallpaper folder
customWallpaper=$HOME/.config/deepin/dde-daemon/appearance/custom-wallpapers # Wallpaper de Deepin
#grep -o 'src="[^"]*"' $wallpaperFolder/.bing | grep -o '/.*.jpg'| cut -f1 -d "&"
#echo $(grep -o 'src="[^"]*"' $wallpaperFolder/.bing | grep -o '/.*.jpg' |cut -f1 -d "&")

# Get the path to the script and save in variable
script=$(readlink -f $0); dirBase=$(dirname $script)

urlBase="http://www.bing.com"
urlRss="$urlBase/HPImageArchive.aspx?format=rss&idx=0&n=1&mkt=en-US"
dateFile="$wallpaperFolder/.dateFile"           # file to save the download date

# Set proxy
export http_proxy=$proxy && export https_proxy=$proxy

# Create folder "$WallpaperFolder". If the "$customWallpaper" folder exists remove 
# and create symbolic link pointing to "$wallpaperFolder"
mkdir -p $wallpaperFolder
if [[ -f "$customWallpaper" ]]; then rm -r $customWallpaper && ln -s $wallpaperFolder $customWallpaper; fi

# Download file with data, if the download is not executed, stop the script
functionWgetBing(){
  wget -T 5 -t 1 --no-check-certificate $urlRss -O $wallpaperFolder/.bing
  if [[ $? -gt 0 ]]; then
    echo "Descargando .bind ........... ERR"; code=1
  else
    echo "Descargando .bing ........... OK"; code=0
  fi
}

# Check the MD5 hash, if the hash coincides, stop script
functionMd5Bing(){
  md5sum -c $wallpaperFolder/.bing.md5 > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then 
    echo "Comprobando el hash MD5 del archivo .bing ..... ERR ARCHIVO VIEJO" ;code=1
  else
    # Extract url and name of picture and save in variable
    imgUrl=$(grep -o 'src="[^"]*"' $wallpaperFolder/.bing | grep -o '/.*.jpg' |cut -f1 -d "&")
    imgName=$(echo $imgUrl | grep -o '[^=OHR.][^=]*.jpg')
    imgName=$(echo $imgName | cut -f1 -d " ")
    echo "Comprobando el hash MD5 del archivo .bing ..... OK ARCHIVO NUEVO"; code=0
  fi
}

# Download picture, if the download is not executed, stop the script
functionWgetImg(){
  wget -T 5 -t 1 --retry-connrefused "$urlBase$imgUrl" -O $wallpaperFolder/$imgName
  if [[ $? -gt 0 ]]; then 
    echo "Descargando imagen .......... ERR"; code=1
  else
    echo "Descargando imagen .......... OK"; code=0
  fi
}

# Delete old picture set as wallpaper
functionDelOldWallpaper(){
  OldWallpaper=$(cat $dateFile)
  md5sum $wallpaperFolder/.bing > $wallpaperFolder/.bing.md5
  rm $customWallpaper/$OldWallpaper.jpg
}

# Set picture as wallpaper, delete old wallpaper and create hash MD5 of new wallpaper
functionSetWallpaper(){
echo $DESKTOP_SESSION
videoPort=$(xrandr |grep primary |cut -d " " -f 1)
echo "[WorkspaceBackground]
1=file://$wallpaperFolder/$imgName
1@$videoPort=file://$wallpaperFolder/$imgName
2@$videoPort=file:///$wallpaperFolder/$imgName" > /home/$USER/.config/deepinwmrc
}

# functionWgetBing
# functionMd5Bing
# functionWgetImg
# functionDelOldWallpaper
# functionSetWallpaper

# BUCLE para ejecutar cada 1 hora
# ===============================================
i=0
while [ $i -ge 0 ]
do
functionWgetBing
if [[ $code -eq 0 ]]; then
  functionMd5Bing
  if [[ $code -eq 0 ]]; then
    functionWgetImg
    if [[ $code -eq 0 ]]; then
      functionDelOldWallpaper
      functionSetWallpaper
    elif [[ $code -eq 1 ]]; then
      echo "No se pudo descargar la imagen"
    fi
  elif [[ $code -eq 1 ]]; then
    echo "El archivo .bing descargado es el mismo"
  fi
elif [[ $code -eq 1 ]]; then
  echo "No se pudo descargar .bing"
fi

  ((i++))
  sleep 3600
done

exit 0
