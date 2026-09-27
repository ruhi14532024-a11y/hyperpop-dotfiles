#!/usr/bin/env bash
# wallpaper.sh — duvar değişiminde tüm temaları günceller:
# bar + rofi + açılış iskeleti + bildirim (matugen) ve kilit (arka plan + renk).
# Tema modu: ~/.cache/hyperpop-theme-mode -> "auto" ya da hazır hex (#rrggbb).
IMG="$1"
[ -f "$IMG" ] || exit 1

mkdir -p ~/.cache
echo "$IMG" > ~/.cache/hyperpop-wallpaper
MODE="$(cat ~/.cache/hyperpop-theme-mode 2>/dev/null || echo auto)"

# kilit arka planı her zaman yeni duvar olsun
python3 -W ignore - "$IMG" <<'EOF' >/dev/null 2>&1
import sys, re
from pathlib import Path
img = sys.argv[1]
conf = Path.home() / '.config' / 'hypr' / 'hyprlock.conf'
src = conf.read_text(encoding='utf-8')
lines = src.split('\n')
in_bg = False
for i, ln in enumerate(lines):
    s = ln.strip()
    if s == 'background {':
        in_bg = True
    elif in_bg and s.startswith('path ='):
        lines[i] = re.sub(r'path = .*', f'path = {img}', ln)
        break
    elif in_bg and s == '}':
        break
conf.write_text('\n'.join(lines), encoding='utf-8')
EOF

if [ "$MODE" != "auto" ]; then
    # hazır tema sabitli: duvar değişse de seçili renk korunur
    matugen color hex "$MODE" -q >/dev/null 2>&1 || true
    matugen -c ~/.config/matugen/lock.toml color hex "$MODE" -q >/dev/null 2>&1 || true
    exit 0
fi

# oto mod: duvarın BASKIN renginden şema üret
# (matugen image bazen küçük canlı detayları seçip alakasız renk veriyor,
#  örn. mavi denizdeki turuncu kayık → turuncu bar.)
HEX=$(python3 -W ignore - "$IMG" <<'EOF'
import sys
from PIL import Image
import colorsys
try:
    im = Image.open(sys.argv[1]).convert('RGB').resize((96, 54))
except Exception:
    print('fallback')
    sys.exit(0)
bins = {}
for r, g, b in im.getdata():
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    if v < 0.12 or (s < 0.08 and (v < 0.2 or v > 0.9)):
        continue
    key = (round(h * 24) % 24, round(s * 8), round(v * 8))
    bins[key] = bins.get(key, 0) + 1
if not bins:
    print('fallback')
    sys.exit(0)
best = max(bins, key=lambda k: bins[k] * (1 + k[1] / 8))
h, s, v = best[0] / 24, min(1.0, best[1] / 8 + 0.15), best[2] / 8
r, g, b = colorsys.hsv_to_rgb(h, s, v)
print('#%02x%02x%02x' % (round(r * 255), round(g * 255), round(b * 255)))
EOF
)

if [ "$HEX" = "fallback" ] || [ -z "$HEX" ]; then
    matugen image "$IMG" -q >/dev/null 2>&1
else
    matugen color hex "$HEX" -q >/dev/null 2>&1
fi
"$HOME/.config/matugen/lock.sh" "$IMG" >/dev/null 2>&1 || true
