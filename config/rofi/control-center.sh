#!/usr/bin/env bash
# control-center.sh — HyperPop ayar arayüzü (Super+C)
# Bar konumu / tema / rofi konumu değiştirir.
THEME="$HOME/.config/rofi/theme.rasi"
WBCONF="$HOME/.config/waybar/config.jsonc"
MODEFILE="$HOME/.cache/hyperpop-theme-mode"
WALLFILE="$HOME/.cache/hyperpop-wallpaper"

menu() { # $1=başlık, rest=seçenekler (pango markup destekli)
    local prompt="$1"; shift
    printf '%s\n' "$@" | rofi -dmenu -p "$prompt" -theme "$THEME" -l 6 -markup-rows
}

clean() { sed 's/<[^>]*>//g'; }

cur_wall() {
    if [ -f "$WALLFILE" ]; then cat "$WALLFILE"
    else ls ~/Image/Fondo/*.jpg ~/Image/Fondo/*.png 2>/dev/null | head -n1; fi
}

apply_theme() { # $1 = auto ya da #hex
    echo "$1" > "$MODEFILE"
    local wall
    wall="$(cur_wall)"
    [ -n "$wall" ] && "$HOME/.config/matugen/wallpaper.sh" "$wall" >/dev/null 2>&1
}

case "$(menu "Ayarlar" " Bar Konumu" " Tema" " Rofi Konumu" | clean)" in
  *"Bar Konumu"*)
    pos="$(grep -o '"position": *"[^"]*"' "$WBCONF" | cut -d'"' -f4)"
    case "$pos" in top) ptr="Üst";; bottom) ptr="Alt";; left) ptr="Sol";; right) ptr="Sağ";; *) ptr="$pos";; esac
    pick="$(menu "Bar: $ptr" "⬆ Üst" "⬇ Alt" | clean)"
    case "$pick" in
      *"Üst") new="top"; lbl="üst";;
      *"Alt") new="bottom"; lbl="alt";;
      *) exit 0;;
    esac
    python3 - "$WBCONF" "$new" <<'EOF'
import json, sys
p, new = sys.argv[1], sys.argv[2]
d = json.load(open(p, encoding='utf-8'))
d['position'] = new
json.dump(d, open(p, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
EOF
    pkill -x waybar; sleep 0.5; (waybar >/dev/null 2>&1 &)
    notify-send "HyperPop" "Bar konumu: $lbl" -t 2500
    ;;
  *"Tema"*)
    mode="$(cat "$MODEFILE" 2>/dev/null || echo auto)"
    pick="$(menu "Tema: $mode" \
      " Otomatik (duvar)" \
      "<span color='#e8a04c'>●</span> Amber" \
      "<span color='#4fd1c5'>●</span> Turkuaz" \
      "<span color='#a37be8'>●</span> Mor" \
      "<span color='#7bc98a'>●</span> Yeşil" \
      "<span color='#6aa8ff'>●</span> Mavi" \
      "<span color='#f472b6'>●</span> Pembe" | clean)"
    case "$pick" in
      *"Otomatik"*) apply_theme auto; lbl="otomatik";;
      *"Amber"*)   apply_theme "#e8a04c"; lbl="amber";;
      *"Turkuaz"*) apply_theme "#4fd1c5"; lbl="turkuaz";;
      *"Mor"*)     apply_theme "#a37be8"; lbl="mor";;
      *"Yeşil"*|*"Yesil"*) apply_theme "#7bc98a"; lbl="yeşil";;
      *"Mavi"*)    apply_theme "#6aa8ff"; lbl="mavi";;
      *"Pembe"*)   apply_theme "#f472b6"; lbl="pembe";;
      *) exit 0;;
    esac
    notify-send "HyperPop" "Tema: $lbl" -t 2500
    ;;
  *"Rofi Konumu"*)
    loc="$(grep -o 'location: *[a-z]*' "$THEME" | awk '{print $2}')"
    [ "$loc" = "center" ] && lr="Orta" || lr="Üst"
    pick="$(menu "Rofi: $lr" "◉ Orta" "⬆ Üst" | clean)"
    case "$pick" in
      *"Orta") new="center"; lbl="orta";;
      *"Üst")  new="north"; lbl="üst";;
      *) exit 0;;
    esac
    python3 - "$THEME" "$new" <<'EOF'
import re, sys
p, new = sys.argv[1], sys.argv[2]
src = open(p, encoding='utf-8').read()
src = re.sub(r'(window \{\s*location: )\w+', r'\g<1>' + new, src, count=1)
if 'y-offset' in src.split('window {', 1)[1].split('}', 1)[0]:
    src = re.sub(r'y-offset:\s*[^;]+;', 'y-offset: %s;' % ('100px' if new == 'north' else '0px'), src, count=1)
elif new == 'north':
    src = src.replace('    anchor: center;', '    anchor: center;\n    y-offset: 100px;', 1)
open(p, 'w', encoding='utf-8').write(src)
EOF
    notify-send "HyperPop" "Rofi konumu: $lbl" -t 2500
    ;;
esac
