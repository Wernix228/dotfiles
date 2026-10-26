#!/bin/sh
# Блокировка для Hyprland (Super+L, hypridle по таймеру и перед сном).
# qylock (тема в ~/.config/qylock/theme) → блокировка Noctalia → hyprlock.
QYLOCK="$HOME/.local/share/quickshell-lockscreen/lock.sh"

# уже заблокировано — второй экран блокировки не запускаем
pidof -q quickshell hyprlock && exit 0

# Английская раскладка: на экране блокировки её не переключить, а пароль латиницей
hyprctl switchxkblayout all 0 >/dev/null 2>&1

if [ -x "$QYLOCK" ] && command -v quickshell >/dev/null; then
    setsid -f "$QYLOCK" "$(cat "$HOME/.config/qylock/theme" 2>/dev/null || echo Genshin)" >/dev/null 2>&1
elif pidof -q noctalia; then
    noctalia msg session lock
else
    setsid -f hyprlock
fi
