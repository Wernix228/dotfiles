#!/bin/sh
# Выпадающий терминал: первый вызов запускает kitty на скрытом столе special:term,
# дальше — показать/спрятать. Размер и место задаёт правило "dropterm" в hyprland.lua.
running() { hyprctl clients | grep -q 'class: dropterm'; }

if ! running; then
    kitty --class dropterm &
    # ждём окно (до 3 с), иначе стол переключится раньше, чем kitty появится
    for _ in $(seq 30); do running && break; sleep 0.1; done
fi
hyprctl dispatch 'hl.dsp.workspace.toggle_special("term")'
