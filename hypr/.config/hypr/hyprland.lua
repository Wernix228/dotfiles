-- Hyprland config (Lua, Hyprland 0.56+)
-- Тема: Catppuccin Mocha. Раскладки: us/ru, переключение Alt+Shift.
-- Вики: https://wiki.hypr.land/Configuring/Start/
-- Проверить конфиг без запуска: Hyprland --verify-config

local c = require("colors")


------------------
---- МОНИТОРЫ ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


-------------------
---- ПРОГРАММЫ ----
-------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local browser     = "firefox"
local menu        = "fuzzel"

-- Оболочка: Noctalia, если установлена; иначе Waybar + Mako + hyprpaper.
-- Каждая команда ниже сначала пробует Noctalia, при её отсутствии — запасной вариант.
local ipc = "noctalia msg "
local function shell_or(noctalia_cmd, fallback)
    return ipc .. noctalia_cmd .. " 2>/dev/null || " .. fallback
end


-------------------
---- АВТОЗАПУСК ---
-------------------

hl.on("hyprland.start", function()
    -- Noctalia сама рисует панель, уведомления, обои, трей и историю буфера
    hl.exec_cmd("command -v noctalia >/dev/null && exec noctalia || { waybar & mako & hyprpaper & nm-applet --indicator & wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store & }")
    -- GTK-программы: курсор и иконки. Plasma при входе выставляет свои значения обратно
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. cursor .. "; gsettings set org.gnome.desktop.interface cursor-size 24; gsettings set org.gnome.desktop.interface icon-theme " .. icons)
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)


-------------------------------
---- ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ  ----
-------------------------------
-- Задаются только для этой сессии, Plasma их не видит.

local cursor = "catppuccin-mocha-mauve-cursors"   -- ~/.local/share/icons
local icons  = "Papirus-Dark"
hl.env("XCURSOR_THEME", cursor)
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", cursor)
hl.env("HYPRCURSOR_SIZE", "24")
-- Qt-программы (Dolphin и др.): цвета Noctalia и иконки через qt6ct (~/.config/qt6ct)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- KDE-программы (Dolphin и др.) берут цвета из своей схемы, а не из qt6ct: схема Noctalia
-- задаётся в hypr/kde/<app>rc, которые Plasma не видит (её ~/.config их не переопределяет)
hl.env("XDG_CONFIG_DIRS", os.getenv("HOME") .. "/.config/hypr/kde:/etc/xdg")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND", "1")


-----------------------
---- ВНЕШНИЙ ВИД  -----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 12,

        border_size = 2,

        col = {
            active_border   = { colors = { c.rgba(c.mauve, "ee"), c.rgba(c.blue, "ee") }, angle = 45 },
            inactive_border = c.rgba(c.surface1, "aa"),
        },

        resize_on_border = true,

        -- Разрешает tearing для окон с правилом immediate (игры) — меньше задержка ввода
        allow_tearing = true,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = 0xee11111b,
        },

        -- Встройке Vega 8 хватает лёгкого блюра; passes > 2 уже заметно грузит
        blur = {
            enabled  = true,
            size     = 5,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},   {0.32, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},      {1, 1}    } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},  {0.75, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},   {0.1, 1}  } })
hl.curve("easy",         { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2.5,  bezier = "easeOutQuint", style = "slide" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        focus_on_activate       = true,
        -- Если экран блокировки упадёт, можно запустить новый (из TTY: hyprctl --instance 0 dispatch ...)
        allow_session_lock_restore = true,
    },

    -- Чтобы X11-программы и игры через Wine не были мыльными
    xwayland = {
        force_zero_scaling = true,
    },
})


---------------
---- ВВОД  ----
---------------

hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:alt_shift_toggle",

        numlock_by_default = true,
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },
})

-- Свайп тремя пальцами влево/вправо — переключение рабочих столов
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


-------------------------
---- ГОРЯЧИЕ КЛАВИШИ ----
-------------------------

local mod = "SUPER"

-- Программы
hl.bind(mod .. " + Return",      hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T",        hl.dsp.exec_cmd(terminal))
-- Выпадающий терминал (как в Quake/Yakuake): Super + ` (клавиша Ё) — показать/спрятать
hl.bind(mod .. " + grave",       hl.dsp.exec_cmd("~/.config/hypr/scripts/dropterm.sh"))
hl.bind(mod .. " + E",           hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + B",           hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + D",           hl.dsp.exec_cmd(shell_or("panel-toggle launcher", menu)))
hl.bind(mod .. " + C",           hl.dsp.exec_cmd(shell_or("panel-toggle clipboard", "cliphist list | fuzzel --dmenu --prompt '󰅌  ' | cliphist decode | wl-copy")))
-- Только с Noctalia: центр управления, настройки, обои, Alt+Tab
hl.bind(mod .. " + A",           hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mod .. " + comma",       hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mod .. " + W",           hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"))
hl.bind("ALT + Tab",             hl.dsp.exec_cmd(ipc .. "window-switcher hold"))

-- Окна
hl.bind(mod .. " + Q",           hl.dsp.window.close())
hl.bind(mod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mod .. " + V",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",           hl.dsp.window.pseudo())
hl.bind(mod .. " + J",           hl.dsp.layout("togglesplit"))

-- Система
hl.bind(mod .. " + L",           hl.dsp.exec_cmd("~/.local/bin/lockscreen"))
hl.bind(mod .. " + SHIFT + E",   hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
-- Перезапустить панель (Noctalia или Waybar)
hl.bind(mod .. " + SHIFT + R",   hl.dsp.exec_cmd("if command -v noctalia >/dev/null; then pkill -x noctalia; noctalia; else pkill waybar; waybar; fi"))

-- Скриншоты: Print — область в буфер, Shift+Print — область в файл
hl.bind("Print",                 hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SHIFT + Print",         hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png"))

-- Фокус: Super + стрелки
hl.bind(mod .. " + left",        hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right",       hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",          hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",        hl.dsp.focus({ direction = "down" }))

-- Перемещение окна: Super + Shift + стрелки
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Рабочие столы: Super + 1..0, перенести окно: Super + Shift + 1..0
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Скрытый рабочий стол (scratchpad)
hl.bind(mod .. " + S",           hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S",   hl.dsp.window.move({ workspace = "special:magic" }))

-- Колесо мыши по рабочим столам
hl.bind(mod .. " + mouse_down",  hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",    hl.dsp.focus({ workspace = "e-1" }))

-- Двигать/менять размер окна мышью
hl.bind(mod .. " + mouse:272",   hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273",   hl.dsp.window.resize(), { mouse = true })

-- Мультимедиа и яркость
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------
---- ПРАВИЛА ОКОН     ----
--------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Фикс перетаскивания в XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Игры: Steam-игры (steam_app_*) и gamescope — tearing и без блокировки экрана
hl.window_rule({
    name  = "games-immediate",
    match = { class = "^(steam_app_.*|gamescope)$" },
    immediate    = true,
    idle_inhibit = "always",
})

-- Steam: всё кроме главного окна — плавающее (друзья, загрузки, логин)
hl.window_rule({
    name  = "steam-popups-float",
    match = { class = "^steam$", title = "negative:^Steam$" },
    float = true,
})

-- Выпадающий терминал живёт на скрытом столе special:term, сверху по центру
hl.window_rule({
    name  = "dropterm",
    match = { class = "^dropterm$" },
    workspace = "special:term silent",
    float = true,
    size  = "monitor_w*0.8 monitor_h*0.55",
    move  = "monitor_w*0.1 50",
})

-- Окно настроек Noctalia — плавающее
hl.window_rule({
    name  = "noctalia-settings",
    match = { class = "^dev.noctalia.Noctalia$" },
    float = true,
    size  = { 1080, 920 },
})

-- Типовые диалоги и мелкие утилиты — плавающими
hl.window_rule({
    name  = "float-utils",
    match = { class = "^(org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager|org.kde.polkit-kde-authentication-agent-1|hyprpolkitagent|nwg-look|qt6ct)$" },
    float = true,
})

hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = "^(Open File|Save File|Открыть файл|Сохранить файл|Открытие файла|Сохранение файла).*" },
    float = true,
})

-- Видео не даёт экрану погаснуть
hl.window_rule({
    name  = "idle-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})


--------------------------
---- NOCTALIA         ----
--------------------------

-- Блюр под панелью, панелями, доком и уведомлениями; свои анимации Hyprland для них выключены
hl.layer_rule({
    name  = "noctalia",
    match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    no_anim      = true,
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})

-- Постоянные рабочие столы 1–5: виджет столов в Noctalia показывает и пустые
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
