#!/usr/bin/env bash
# HyperPop Dotfiles — installer (Arch/CachyOS + Hyprland)
# Kullanım: ./install.sh
set -u

REPO="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M)"
NEED_SUDO=false

info()  { echo -e "\033[1;36m==>\033[0m $*"; }
warn()  { echo -e "\033[1;33mUYARI:\033[0m $*"; }
hata()  { echo -e "\033[1;31mHATA:\033[0m $*"; }

# 1) bağımlılıklar -------------------------------------------------------
# "paket:komut" — komut yoksa paket adından kontrol edilir
DEPS=(hyprland:Hyprland waybar:waybar rofi:rofi kitty:kitty awww:awww-daemon
      matugen:matugen jq:jq ffmpeg:ffmpeg grim:grim slurp:slurp
      brightnessctl:brightnessctl playerctl:playerctl wireplumber:wpctl
      network-manager-applet:nm-applet swaync:swaync hyprlock:hyprlock
      dolphin:dolphin gtk-layer-shell: gtk3: gcc:gcc pkg-config:pkg-config)
MISSING=()
for pair in "${DEPS[@]}"; do
    pkg="${pair%%:*}"; bin="${pair##*:}"
    if [ -n "$bin" ]; then
        command -v "$bin" >/dev/null 2>&1 || pacman -Q "$pkg" >/dev/null 2>&1 || MISSING+=("$pkg")
    else
        pacman -Q "$pkg" >/dev/null 2>&1 || MISSING+=("$pkg")
    fi
done
python3 -c "import PIL" >/dev/null 2>&1 || MISSING+=("python-pillow")
if [ "${#MISSING[@]}" -gt 0 ]; then
    warn "Eksik paketler: ${MISSING[*]}"
    read -rp "sudo pacman -S ile kurulsun mu? [e/H] " yn
    if [[ "$yn" =~ ^[eEyY]$ ]]; then
        sudo pacman -S --needed "${MISSING[@]}" || hata "kurulum başarısız, devam ediliyor..."
    else
        warn "Eksikler kurulmadan devam ediliyor (bazı özellikler çalışmayabilir)."
    fi
fi

# 2) yedek ----------------------------------------------------------------
info "Mevcut ayarlar yedekleniyor: $BACKUP"
mkdir -p "$BACKUP"
for d in hypr rofi waybar matugen SelectWallpaper; do
    [ -d "$HOME/.config/$d" ] && cp -r "$HOME/.config/$d" "$BACKUP/" 2>/dev/null
done

# 3) dosyaları kopyala ------------------------------------------------------
info "Configler kopyalanıyor..."
mkdir -p ~/.config ~/.local/bin ~/.local/share/fonts ~/Image
cp -r "$REPO/config/hypr" "$REPO/config/rofi" "$REPO/config/waybar" \
    "$REPO/config/matugen" "$REPO/config/SelectWallpaper" ~/.config/
mkdir -p ~/Image/Fondo
cp -n "$REPO/wallpapers/"*.jpg "$REPO/wallpapers/"*.png ~/Image/Fondo/ 2>/dev/null

# 4) ev dizini yollarını düzelt (/home/suleyman -> $HOME) -------------------
info "Kullanıcı yolları düzeltiliyor..."
grep -rl "/home/suleyman" ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprlock.conf \
    ~/.config/rofi/config.rasi ~/.config/rofi/theme.rasi \
    ~/.config/matugen/config.toml ~/.config/matugen/lock.toml 2>/dev/null \
    | while read -r f; do sed -i "s#/home/suleyman#$HOME#g" "$f"; done

# 5) çalıştırılabilir izinler -------------------------------------------------
chmod +x ~/.config/rofi/launch.sh ~/.config/rofi/windows-bring.sh \
         ~/.config/matugen/wallpaper.sh ~/.config/matugen/lock.sh \
         ~/.config/SelectWallpaper/wallpaper-selector.sh \
         ~/.config/hypr/Scripts/*.sh 2>/dev/null

# 6) Monocraft fontu (Minecraft) ----------------------------------------------
if ! fc-list | grep -qi monocraft; then
    info "Monocraft fontu indiriliyor..."
    mkdir -p ~/.local/share/fonts/Monocraft
    curl -sL --max-time 90 \
        "https://github.com/IdreesInc/Monocraft/releases/download/v4.2.1/Monocraft.ttc" \
        -o ~/.local/share/fonts/Monocraft/Monocraft.ttc \
        && fc-cache -f ~/.local/share/fonts/Monocraft >/dev/null 2>&1 \
        && info "Monocraft kuruldu." || warn "Font indirilemedi, elle kur: github.com/IdreesInc/Monocraft"
else
    info "Monocraft zaten kurulu."
fi

# 7) rofi-fx açılış animasyonu --------------------------------------------------
if command -v gcc >/dev/null && pkg-config --exists gtk+-3.0 gtk-layer-shell-0 2>/dev/null; then
    info "rofi-fx derleniyor..."
    gcc -O2 ~/.config/rofi/rofi-fx.c -o ~/.config/rofi/rofi-fx \
        $(pkg-config --cflags --libs gtk+-3.0 gtk-layer-shell-0) -lm \
        && info "rofi-fx hazır." || warn "Derleme başarısız, hazır binary kullanılıyor."
else
    warn "Derleme araçları yok, hazır rofi-fx binary kullanılıyor."
fi
chmod +x ~/.config/rofi/rofi-fx

# 8) duvar kağıdı + tema üretimi --------------------------------------------------
WALL="$(ls ~/Image/Fondo/*.jpg ~/Image/Fondo/*.png 2>/dev/null | head -n1)"
if [ -n "$WALL" ]; then
    info "Duvar kağıdı uygulanıyor: $(basename "$WALL")"
    pgrep -x awww-daemon >/dev/null || (awww-daemon >/dev/null 2>&1 &)
    sleep 0.5
    ~/.config/matugen/wallpaper.sh "$WALL" >/dev/null 2>&1 || true
    awww img "$WALL" >/dev/null 2>&1 || true
fi

# 9) doğrula ----------------------------------------------------------------------
info "Doğrulanıyor..."
hyprland -c ~/.config/hypr/hyprland.lua --verify-config 2>&1 | tail -n 2
rofi -config ~/.config/rofi/config.rasi -dump-theme >/dev/null 2>&1 \
    && info "rofi teması OK." || warn "rofi temasında sorun var."

if pgrep -x Hyprland >/dev/null || pgrep -x hyprland >/dev/null; then
    read -rp "Hyprland çalışıyor. Yeni ayarlarla reload yapılsın mı? [e/H] " yn
    [[ "$yn" =~ ^[eEyY]$ ]] && hyprctl reload && info "Reload yapıldı."
fi

info "Bitti! Super+D: launcher, Super+W: duvar kağıdı, Super+L: kilit."
info "Eski ayarların yedeği: $BACKUP"
