#!/usr/bin/env bash

DIR="$HOME/Image/Hyprshot"
mkdir -p "$DIR"
TIME=$(date +"%Y-%m-%d-%H%M%S")

case "$1" in
    region)
        grim -g "$(slurp)" - | tee "$DIR/${TIME}_region.png" | wl-copy
        notify-send "Screenshot" "Bölge kopyalandı ve kaydedildi" -i "$DIR/${TIME}_region.png"
        ;;
    window)
        grim -g "$(hyprctl clients -j | jq -r '.[] | select(.focusHistoryID == -1) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | head -1)" - | tee "$DIR/${TIME}_window.png" | wl-copy
        notify-send "Screenshot" "Pencere kopyalandı ve kaydedildi" -i "$DIR/${TIME}_window.png"
        ;;
    screen)
        grim - | tee "$DIR/${TIME}_screen.png" | wl-copy
        notify-send "Screenshot" "Tam ekran kopyalandı ve kaydedildi" -i "$DIR/${TIME}_screen.png"
        ;;
    *)
        echo "Kullanım: $0 [region|window|screen]"
        exit 1
        ;;
esac
