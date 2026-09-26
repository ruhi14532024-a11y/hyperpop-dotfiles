#!/usr/bin/env bash
# lock.sh — kilit duvar kağıdının baskın renginden kilit renklerini üretir.
# Kullanım: lock.sh [duvar]  (varsayılan: gece şehir)
IMG="${1:-$HOME/Image/Fondo/gece-sehir-simsek.jpg}"
[ -f "$IMG" ] || exit 1

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
    matugen -c ~/.config/matugen/lock.toml image "$IMG" --prefer saturation -q >/dev/null 2>&1
else
    matugen -c ~/.config/matugen/lock.toml color hex "$HEX" -q >/dev/null 2>&1
fi
