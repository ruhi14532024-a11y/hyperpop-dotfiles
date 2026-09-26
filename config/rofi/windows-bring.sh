#!/usr/bin/env bash
# windows-bring.sh — rofi script-mode
# Seçilen pencereye GİTMEZ, onu bulunduğun çalışma alanına GETİRİR.

set -u

# --- seçim yapıldıysa: pencereyi buraya getir ---
if [ -n "${ROFI_INFO:-}" ]; then
    ADDR="$ROFI_INFO"
    WS="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty')"
    [ -z "$WS" ] && exit 1
    hyprctl dispatch movetoworkspace "$WS,address:$ADDR" >/dev/null 2>&1
    hyprctl dispatch focuswindow "address:$ADDR" >/dev/null 2>&1
    exit 0
fi

# --- liste modu ---
printf '\0prompt\x1fPencere getir\n'

CUR_WS="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty')"
CLIENTS="$(hyprctl clients -j 2>/dev/null)"
[ -z "$CLIENTS" ] && { echo "Pencere yok"; exit 0; }

COUNT="$(echo "$CLIENTS" | jq 'length')"
[ "$COUNT" = "0" ] && { echo "Pencere yok"; exit 0; }

echo "$CLIENTS" | jq -r --arg cur "$CUR_WS" '
  sort_by(.focusHistoryID) | .[] |
  (.address) as $addr |
  (.class // "?") as $cls |
  (.title // "?") as $ttl |
  ((.workspace.id // -1) | tostring) as $ws |
  (if $ws == $cur then "●" else "○" end) as $mark |
  (if $ws == $cur then "burada" else ("ws " + $ws) end) as $where |
  "\($mark) \($cls) — \($ttl | .[0:80]) [\($where)]\u0000info\u001f\($addr)\u001ficon\u001f\($cls)"
'
