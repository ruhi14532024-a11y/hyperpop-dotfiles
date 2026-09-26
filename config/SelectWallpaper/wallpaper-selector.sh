#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

WALLPAPER_DIR="$HOME/Image/Fondo"

CACHE_ROOT="$SCRIPT_DIR/cached_imgs"
#WALLPAPER_ROOT="$SCRIPT_DIR/wallpapers"
WALLPAPER_ROOT="$WALLPAPER_DIR"
mkdir -p "$WALLPAPER_ROOT" "$CACHE_ROOT"

# begin swww if isnt 
if ! pgrep -x awww-daemon >/dev/null; then
    awww-daemon &
    sleep 0.5
fi

# generate min
cacheImg() {
    resolution=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=width,height -of csv=p=0 "$1")
    width_=$(echo "${resolution}" | awk -F',' '{print $1}')
    height_=$(echo "${resolution}" | awk -F',' '{print $2}')

    if [ "${width_}" -lt "${height_}" ]; then
        ffmpeg -i "$1" -loglevel quiet -vf "scale=600:-1, crop=600:600:0:(ih-600)/2" "$2"
    else
        ffmpeg -i "$1" -loglevel quiet -vf "scale=-1:600, crop=600:600:(iw-600)/2:0" "$2"
    fi
    echo "$2"
}

# get name withouth extension
getFileName() {
    basename "$1" | sed 's/\.[^.]*$//'
}

# wallpaper find
mapfile -t originPath < <(find "$WALLPAPER_ROOT" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) )

mapfile -t cachedPath < <(find "$CACHE_ROOT" -maxdepth 1 -type f)

declare -A bgresult
declare -A cachedresult
bgnames=()


for path in "${originPath[@]}"; do
    filename=$(getFileName "$path")
    bgresult["$filename"]="$path"
    bgnames+=("$filename")
done


for path in "${cachedPath[@]}"; do
    filename=$(getFileName "$path")
    cachedresult["$filename"]="$path"
done

for fName in "${bgnames[@]}"; do
    if [[ ! -v cachedresult[$fName] ]]; then
        cachedresult[$fName]=$(cacheImg "${bgresult[$fName]}" "$CACHE_ROOT/${fName}.png")
    fi
done

# Construir lista para rofi con iconos
strrr=""
for fName in "${bgnames[@]}"; do
    strrr+="$fName\0icon\x1f${cachedresult[$fName]}\n"
done




# Seleccionar con rofi (modo galería)
selected=$(echo -en "$strrr" | rofi -dmenu -p "Selecciona fondo" -theme "$SCRIPT_DIR/wallpapers.rasi")
if [ -n "$selected" ]; then
    WALL="${bgresult[$selected]}"
    
    # 1. Cambiar wallpaper con animación

    # 2. Matugen ile bar renklerini üret (baskın renk; waybar otomatik yenilenir).
    #    NOT: pywal/update_wall.py style.css'i eski tasarımla eziyordu, kaldırıldı.
    ~/.config/matugen/wallpaper.sh "$WALL" >/dev/null 2>&1 || true
    awww img "$WALL" --transition-type wipe --transition-fps 60 --transition-duration 1
    # 4. Bar renkleri matugen post_hook ile yerinde yenilenir (SIGUSR2);
    #    yeniden başlatma yok — çift bar çakışması yapıyordu.
fi

# Cambiar fondo si se seleccionó algo
# [ -n "$selected" ] && swww img "${bgresult[$selected]}" --transition-type random --transition-fps 60 --transition-duration 1
