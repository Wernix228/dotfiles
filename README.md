# dotfiles

Hyprland (Lua-конфиг, 0.56+) · Waybar · Fuzzel · Mako · Kitty · Catppuccin Mocha

Установка: `cd ~/dotfiles && stow hypr waybar fuzzel mako kitty`
Удалить ссылки: `stow -D <пакет>`

## Горячие клавиши
| Клавиши | Действие |
|---|---|
| Super + Enter | терминал (kitty) |
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
| Super + L | заблокировать |
| Super + Shift + E | выйти из Hyprland |
| Super + Shift + R | перезапустить Waybar |
| Print / Shift + Print | скриншот области в буфер / в файл |
| Alt + Shift | раскладка us/ru |
| 3 пальца влево/вправо | рабочие столы |

## driftwm (третья сессия, «поиграться»)
Установка: `paru -S driftwm`, затем `stow driftwm`. Проверка конфига: `driftwm --check-config`.
Waybar для него — `waybar/.config/waybar/drift.jsonc` (taskbar вместо рабочих столов).

| Клавиши / жесты | Действие |
|---|---|
| Super + Enter / D | терминал / лаунчер |
| Super + B / E | Firefox / Dolphin |
| Super + Q | закрыть окно |
| Super + стрелки | фокус на соседнее окно |
| Super + Ctrl + стрелки | двигать холст |
| Super + = / − / 0 / W | приблизить / отдалить / сброс / всё в кадре |
| Super + 1..4, Super + Shift + 1..4 | закладки на холсте: перейти / сохранить |
| Super + V | история буфера обмена |
| Super + L | заблокировать |
| Super + Ctrl + Shift + Q | выйти из driftwm |
| Alt + Shift | раскладка us/ru |
| 3 пальца | двигать холст; щипок — зум |
