#!/usr/bin/env bash
# Super+D — toggle launcher
# Açılışta parçalar birleşir, kapanışta dağılır.

FX="$HOME/.config/rofi/rofi-fx"
MONFILE="/tmp/rofi-fx-mon"

# Odaklı monitörün sol-üst köşesi (rofi hep buraya açılır)
focused_mon() {
    local id
    id="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.monitorID // 0')"
    hyprctl monitors -j 2>/dev/null | jq -r --argjson id "$id" \
        '.[] | select(.id==$id) | "\(.x),\(.y)"' | head -n1
}

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

MODE="${1:-drun}"
# eski dahili window modu yerine getirme scripti
[ "$MODE" = "window" ] && MODE="bring"

case "$MODE" in
  powermenu|power) exec rofi -show p -modi p:"$HOME/.config/rofi/powermenu.sh" -theme ~/.config/rofi/theme.rasi ;;
  *)
    # açılış: monitörü kaydet, parçalar birleşir, gerçek rofi belirir
    pkill -x rofi-fx 2>/dev/null
    MON="$(focused_mon)"
    [ -n "$MON" ] && echo "$MON" > "$MONFILE"
    "$FX" assemble "$MON" >/dev/null 2>&1 &
    sleep 0.22
    exec rofi -show "$MODE" -theme ~/.config/rofi/theme.rasi \
        -p " Uygulamalar" -matching fuzzy -sort -sorting-method fzf -i \
        -mesg "ESC kapat  •  ↵ aç  •  Ctrl+Tab mod değiştir" ;;
esac
