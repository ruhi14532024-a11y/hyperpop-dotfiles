-- Hyprland Lua config — legacy hyprland.conf'un birebir karşılığı.
-- Hyprland 0.57 legacy .conf desteğini kaldırıyor; bu dosya hem
-- 0.56.2'de hem 0.57'de çalışır. Geri dönüş: bu dosyayı sil + reload.
-- Referans: https://wiki.hypr.land/configuring/

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet &")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("waybar & awww-daemon")
    hl.exec_cmd("hyprpolkit")
    hl.exec_cmd("sleep 1 && awww restore")
    hl.exec_cmd("swaync & swaync-client")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "Furina-v2")
hl.env("XCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_SIZE", "32")

hl.env("GDK_SCALE", "1.25")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1.5")
hl.env("QT_SCALE_FACTOR", "1.10")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("ELECTRON_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_FORCE_DEVICE_SCALE_FACTOR", "1.5")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- env=XKB_DEFAULT_OPTIONS=ctrl:nocaps


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 15,

        border_size = 2,

        col = {
            active_border   = "rgba(33ccffee)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(89b4faee)",
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },
})

hl.curve("easeStandard", { type = "bezier", points = { {0.25, 0.1},  {0.25, 1.0} } })
hl.curve("easeIn",       { type = "bezier", points = { {0.42, 0.0},  {1.0, 1.0}   } })
hl.curve("easeOut",      { type = "bezier", points = { {0.0, 0.0},   {0.58, 1.0}  } })
hl.curve("easeInOut",    { type = "bezier", points = { {0.42, 0.0},  {0.58, 1.0}  } })
hl.curve("spring",       { type = "bezier", points = { {0.175, 0.885}, {0.32, 1.275} } })
hl.curve("gentle",       { type = "bezier", points = { {0.4, 0.0},   {0.2, 1.0}   } })

hl.animation({ leaf = "windows",         enabled = true, speed = 1, bezier = "easeInOut",  style = "slide" })
hl.animation({ leaf = "windowsIn",       enabled = true, speed = 1, bezier = "easeOut",    style = "slide" })
hl.animation({ leaf = "windowsOut",      enabled = true, speed = 1, bezier = "easeIn",     style = "slide" })
hl.animation({ leaf = "windowsMove",     enabled = true, speed = 1, bezier = "easeInOut",  style = "slide" })
hl.animation({ leaf = "border",          enabled = true, speed = 1, bezier = "gentle" })
hl.animation({ leaf = "borderangle",     enabled = true, speed = 1, bezier = "easeStandard", style = "loop" })
hl.animation({ leaf = "fade",            enabled = true, speed = 1, bezier = "easeOut" })
hl.animation({ leaf = "fadeIn",          enabled = true, speed = 4, bezier = "easeOut" })
hl.animation({ leaf = "fadeOut",         enabled = true, speed = 3, bezier = "easeIn" })
hl.animation({ leaf = "fadeSwitch",      enabled = true, speed = 3, bezier = "easeInOut" })
hl.animation({ leaf = "fadeShadow",      enabled = true, speed = 3, bezier = "easeOut" })
hl.animation({ leaf = "fadeDim",         enabled = true, speed = 3, bezier = "easeInOut" })
hl.animation({ leaf = "workspaces",      enabled = true, speed = 2, bezier = "easeInOut",  style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "easeInOut", style = "slidevert" })
hl.animation({ leaf = "layers",          enabled = true, speed = 3, bezier = "easeOut",    style = "slide" })
hl.animation({ leaf = "layersIn",        enabled = true, speed = 3, bezier = "easeOut",    style = "slide" })
hl.animation({ leaf = "layersOut",       enabled = true, speed = 2, bezier = "easeIn",     style = "slide" })

-- Static workspaces: 1-8 HDMI-A-1 (ana ekran), 9-10 eDP-1
for i = 1, 8 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", persistent = true })
end
for _, i in ipairs({ 9, 10 }) do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", persistent = true })
end

-- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "tr",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        numlock_by_default = true,

        follow_mouse = 1,

        sensitivity = 0,

        force_no_accel = true,

        scroll_factor = 2.0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("kitty --class kitty-drop"))
hl.window_rule({
    name  = "kitty-drop-float",
    match = { class = "^(kitty-drop)$" },
    float = true,
})
hl.window_rule({
    name  = "kitty-drop-size",
    match = { class = "^(kitty-drop)$" },
    size  = { "90%", "50%" },
})
hl.window_rule({
    name  = "kitty-drop-center",
    match = { class = "^(kitty-drop)$" },
    center = true,
})
hl.window_rule({
    name  = "kitty-drop-scratch",
    match = { class = "^(kitty-drop)$" },
    workspace = "special:kitty-scratch",
})

hl.bind(mainMod .. " + F2", hl.dsp.workspace.toggle_special("kitty-scratch"))

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("flatpak run app.zen_browser.zen"))
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/rofi/launch.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("/home/suleyman/.config/SelectWallpaper/wallpaper-selector.sh"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- 10. alan 0 tuşunda (eDP-1'de)
hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Cambiar foco entre monitores
hl.bind(mainMod .. " + space", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + comma", hl.dsp.focus({ monitor = "-1" }))

-- Mover ventana al siguiente/anterior monitor
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.window.move({ monitor = "-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                 { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------
----SCREENSHOT
--------------

hl.bind("Print",               hl.dsp.exec_cmd("~/.config/hypr/Scripts/screenshot.sh region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("~/.config/hypr/Scripts/screenshot.sh window"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/Scripts/screenshot.sh screen"))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Rofi: float + center + no Hypr border (rofi kendi çerçevesini çizer)
hl.window_rule({
    name  = "rofi-float",
    match = { class = "^(rofi)$" },
    float = true,
})
hl.window_rule({
    name  = "rofi-center",
    match = { class = "^(rofi)$" },
    center = true,
})
hl.window_rule({
    name  = "rofi-focus",
    match = { class = "^(rofi)$" },
    stay_focused = true,
})
hl.window_rule({
    name  = "rofi-noborder",
    match = { class = "^(rofi)$" },
    border_size = 0,
})
hl.window_rule({
    name  = "rofi-round",
    match = { class = "^(rofi)$" },
    -- NOTE: lua üst sınırı 20 (.conf'ta 24 idi, görsel fark yok)
    rounding = 20,
})

hl.layer_rule({
    name  = "rofi-blur",
    match = { namespace = "rofi" },
    blur = true,
})
hl.layer_rule({
    name  = "rofi-dimaround",
    match = { namespace = "rofi" },
    dim_around = true,
})
hl.layer_rule({
    name  = "rofi-anim",
    match = { namespace = "rofi" },
    animation = "fade",
})
