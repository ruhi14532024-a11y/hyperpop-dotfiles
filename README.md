# 🌀 HyperPop Dotfiles

A glassy, Minecraft-fonted Hyprland setup that repaints itself from your wallpaper. Press `Super+D` and watch the UI pieces fly together.

> **Origin:** This config is a renewed version of [VicMeGa/Hypr-Dotfiles](https://github.com/VicMeGa/Hypr-Dotfiles) — rebuilt with a Lua config, matugen theming and a custom rofi. Thanks VicMeGa!

## 📸 Screenshots

![Desktop](screenshots/desktop.png)
![Rofi launcher](screenshots/rofi.png)
![Lockscreen](screenshots/lockscreen.png)

## ✨ What's inside?

- **Hyprland (Lua config)** — 0.56 compatible, **0.57 ready** (legacy `.conf` era is over, this repo already uses Lua)
- **Rofi launcher (`Super+D`)** — open animation where pieces fly in and assemble (`rofi-fx`, written in C), pill mode switcher, window picker that brings the window to your workspace
- **Matugen theming** — when the wallpaper changes, the **bar + rofi + open animation + lockscreen** all repaint together (dominant-color algorithm, no orange-boat trap)
- **Waybar** — single glass strip, Monocraft font, wallpaper-matched colors
- **Hyprlock** — Monocraft clock (24-hour), glass card, wallpaper-matched colors
- **Wallpapers** — 14 bundled landscapes (`wallpapers/`), pick from gallery with `Super+W`
- **Fonts** — Monocraft (Minecraft) + Nerd icon fallback

## 📦 Requirements (Arch/CachyOS)

`hyprland waybar rofi kitty awww matugen jq python-pillow ffmpeg grim slurp brightnessctl playerctl wireplumber nm-applet swaync hyprlock dolphin gtk-layer-shell gcc pkg-config gtk3`

The installer asks before installing anything missing via `pacman`.

## 🚀 Installation

```bash
git clone https://github.com/ruhi14532024-a11y/hyperpop-dotfiles.git
cd hyperpop-dotfiles
./install.sh
```

The installer:

1. Offers to install missing packages
2. Backs up your current `~/.config/{hypr,rofi,waybar,matugen,SelectWallpaper}` to `~/.config-backup-DATE`
3. Copies configs and wallpapers, rewrites `/home/suleyman` paths to your home
4. Downloads the Monocraft font, compiles the `rofi-fx` animation (falls back to prebuilt binary)
5. Applies the first wallpaper, generates all themes, verifies everything

Then log out and back in (or `hyprctl reload`).

## ⌨️ Keybinds (highlights)

| Key | Action |
|---|---|
| `Super+D` | App launcher (rofi) |
| `Super+W` | Wallpaper gallery |
| `Super+L` | Lock screen |
| `Super+Q` | Terminal |
| `Super+E` | File manager |
| `Super+1..9` | Workspaces |
| `Super+S` | Scratchpad |
| `Print` | Region screenshot |

## 🗂️ Structure

```
├── install.sh              # installer
├── wallpapers/             # 14 landscapes + logos
├── screenshots/            # screenshots
└── config/
    ├── hypr/               # hyprland.lua, hyprlock.conf, Scripts/
    ├── rofi/               # theme, launcher, rofi-fx (C + binary)
    ├── waybar/             # config.jsonc + matugen-driven style.css
    ├── swaync/             # notification center (matugen-aware)
    ├── matugen/            # config + templates + wallpaper.sh/lock.sh
    └── SelectWallpaper/    # Super+W gallery script
```

Generated files (`matugen.css`, `hyprlock-colors.conf`, `fx-colors`…) are not in the repo — the installer generates them from the first wallpaper.

## ↩️ Rollback

The installer backs up your old setup: copy back whatever you need from `~/.config-backup-*`. For Hyprland trouble, deleting `hyprland.lua` + `hyprctl reload` is enough to fall back.

---

---

# 🌀 HyperPop Dotfiles (Türkçe)

Duvar kağıdından kendini boyayan, cam efektli, Minecraft fontlu bir Hyprland kurulumu. `Super+D`'ye basınca arayüz parçaları uçup birleşiyor.

> **Köken:** Bu config, [VicMeGa/Hypr-Dotfiles](https://github.com/VicMeGa/Hypr-Dotfiles) kurulumunun baştan yenilenmiş hâlidir — Lua config, matugen temalama ve özel rofi ile elden geçirildi. Teşekkürler VicMeGa!

## 📸 Ekran görüntüleri

![Masaüstü](screenshots/desktop.png)
![Rofi launcher](screenshots/rofi.png)
![Kilit ekranı](screenshots/lockscreen.png)

## ✨ Neler var?

- **Hyprland (Lua config)** — 0.56 uyumlu, **0.57 hazır** (legacy `.conf` dönemi bitti, bu repo zaten Lua kullanıyor)
- **Rofi launcher (`Super+D`)** — parçaların uçup birleştiği açılış animasyonu (`rofi-fx`, C ile yazıldı), hap mod değiştirici, pencereyi bulunduğun alana getiren pencere seçici
- **Matugen temalama** — duvar kağıdı değişince **bar + rofi + açılış animasyonu + kilit ekranı** hep birlikte yeniden boyanıyor (baskın renk algoritmasıyla; turuncu kayık tuzağına düşmez)
- **Waybar** — tek cam şerit, Monocraft font, duvar uyumlu renkler
- **Hyprlock** — Monocraft saat (24 saat), cam kart, duvar uyumlu renkler
- **Duvar kağıtları** — 14 hazır manzara (`wallpapers/`), `Super+W` ile galeriden seç
- **Font** — Monocraft (Minecraft) + Nerd ikon fallback

## 📦 Gereksinimler (Arch/CachyOS)

`hyprland waybar rofi kitty awww matugen jq python-pillow ffmpeg grim slurp brightnessctl playerctl wireplumber nm-applet swaync hyprlock dolphin gtk-layer-shell gcc pkg-config gtk3`

Kurucu eksikleri sorup `pacman` ile kurmayı teklif eder.

## 🚀 Kurulum

```bash
git clone https://github.com/ruhi14532024-a11y/hyperpop-dotfiles.git
cd hyperpop-dotfiles
./install.sh
```

Kurucu şunları yapar:

1. Eksik paketleri sorup kurar
2. Mevcut `~/.config/{hypr,rofi,waybar,matugen,SelectWallpaper}` ayarlarını `~/.config-backup-TARİH` altına yedekler
3. Configleri ve duvar kağıtlarını yerine kopyalar, `/home/suleyman` yollarını senin ev dizinine çevirir
4. Monocraft fontunu indirir, `rofi-fx` animasyon programını derler (olmazsa hazır binary kullanır)
5. İlk duvar kağıdını uygulayıp tüm temaları üretir, ayarları doğrular

Sonra çıkış yapıp tekrar gir (veya `hyprctl reload`).

## ⌨️ Kısayollar (öne çıkanlar)

| Tuş | İş |
|---|---|
| `Super+D` | Uygulama launcher (rofi) |
| `Super+W` | Duvar kağıdı galerisi |
| `Super+L` | Ekranı kilitle |
| `Super+Q` | Terminal |
| `Super+E` | Dosya yöneticisi |
| `Super+1..9` | Çalışma alanları |
| `Super+S` | Scratchpad |
| `Print` | Alan ekran görüntüsü |

## 🗂️ Yapı

```
├── install.sh              # kurucu
├── wallpapers/             # 14 manzara + logolar
├── screenshots/            # ekran görüntüleri
└── config/
    ├── hypr/               # hyprland.lua, hyprlock.conf, Scripts/
    ├── rofi/               # tema, launcher, rofi-fx (C + binary)
    ├── waybar/             # config.jsonc + matugen stilli style.css
    ├── swaync/             # bildirim merkezi (matugen uyumlu)
    ├── matugen/            # config + şablonlar + wallpaper.sh/lock.sh
    └── SelectWallpaper/    # Super+W galeri scripti
```

Üretilen dosyalar (`matugen.css`, `hyprlock-colors.conf`, `fx-colors`…) repoda yok — kurucu ilk duvarla birlikte üretiyor.

## ↩️ Geri alma

Kurucu eskileri yedekler: `ls ~/.config-backup-*` içinden istediğini geri kopyala. Hyprland tarafında sorun olursa `hyprland.lua`'yı kaldırıp `hyprctl reload` yapman yeterli.
