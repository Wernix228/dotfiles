# dotfiles

Hyprland (Lua-конфиг, 0.56+) · Noctalia · Waybar · Fuzzel · Mako · Kitty · Catppuccin Mocha

Установка: `cd ~/dotfiles && stow hypr noctalia waybar fuzzel mako kitty fish starship fastfetch btop cava qt6ct`

В Hyprland оболочка — **Noctalia** (`paru -S noctalia-git`). Если её нет, Hyprland сам
запускает запасной набор Waybar + Mako + hyprpaper, бинды переключаются на fuzzel/cliphist/hyprlock.
Удалить ссылки: `stow -D <пакет>`

## Горячие клавиши
| Клавиши | Действие |
|---|---|
| Super + Enter / Ctrl + Alt + T | терминал (kitty) |
| Super + ` (Ё) | выпадающий терминал: показать / спрятать |
| Super + D | лаунчер (fuzzel) |
| Super + B / E | Firefox / Dolphin |
| Super + Q | закрыть окно |
| Super + F / V | фуллскрин / плавающее окно |
| Super + стрелки | фокус |
| Super + Shift + стрелки | двигать окно |
| Super + 1..0 | рабочий стол |
| Super + Shift + 1..0 | перенести окно на рабочий стол |
| Super + S | скрытый стол (scratchpad) |
| Super + C | история буфера обмена |
| Super + A | центр управления (Noctalia) |
| Super + , | настройки Noctalia |
| Super + W | выбор обоев (Noctalia) |
| Alt + Tab | переключатель окон (Noctalia) |
| Super + L | заблокировать (qylock, тема Genshin) |
| Super + Shift + E | выйти из Hyprland |
| Super + Shift + R | перезапустить панель (Noctalia/Waybar) |
| Print / Shift + Print | скриншот области в буфер / в файл |
| Alt + Shift | раскладка us/ru |
| 3 пальца влево/вправо | рабочие столы |

## driftwm (третья сессия, «поиграться»)
Установка: `paru -S driftwm`, затем `stow driftwm`. Проверка конфига: `driftwm --check-config`.
Waybar для него — `waybar/.config/waybar/drift.jsonc` (taskbar вместо рабочих столов).

| Клавиши / жесты | Действие |
|---|---|
| Super + Enter / Ctrl + Alt + T | терминал |
| Super + D | лаунчер |
| Super + B / E | Firefox / Dolphin |
| Super + Q | закрыть окно |
| Super + стрелки | фокус на соседнее окно |
| Super + Ctrl + стрелки | двигать холст |
| Super + = / − / 0 / W | приблизить / отдалить / сброс / всё в кадре |
| Super + 1..4, Super + Shift + 1..4 | закладки на холсте: перейти / сохранить |
| Super + V | история буфера обмена |
| Super + L | заблокировать (qylock, тема Genshin) |
| Super + Ctrl + Shift + Q | выйти из driftwm |
| Alt + Shift | раскладка us/ru |
| 3 пальца | двигать холст; щипок — зум |

## Оформление
- **Шаблоны Noctalia** (`noctalia/.config/noctalia/templates.toml`): kitty, btop, cava, GTK3/4, Qt
  перекрашиваются под палитру Noctalia. Применить заново: `noctalia msg templates-apply`.
  Сгенерированные темы в git не попадают (см. `.gitignore`).
- **Qt в Hyprland** — qt6ct (`QT_QPA_PLATFORMTHEME=qt6ct` только в Hyprland), иконки Papirus-Dark.
- **Курсор** — Catppuccin Mocha Mauve (`~/.local/share/icons`, релиз github.com/catppuccin/cursors).
- **Терминал** — fish (конфиг CachyOS) + Starship (`catppuccin-powerline`) + fastfetch.
- Firefox: локальный шаблон только на ноуте (`~/.config/noctalia/local-firefox.toml`), в dotfiles его нет.

## Экран блокировки (qylock)
Темы — github.com/Darkkal44/qylock (клон в `~/Git/qylock`, обёртка в `~/.local/share/quickshell-lockscreen`).
Тема — `~/.config/qylock/theme` (сейчас `Genshin`), сменить: записать туда имя папки из `~/Git/qylock/themes`.
Super+L и hypridle вызывают `hypr/scripts/lock.sh`: qylock → блокировка Noctalia → hyprlock.
Если экран блокировки завис: Ctrl+Alt+F3, войти и выполнить
`pkill -x quickshell; hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("hyprlock")'`, затем вернуться в Hyprland.
