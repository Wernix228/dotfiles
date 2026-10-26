# Hyprland экспортирует свой QT_QPA_PLATFORMTHEME (qt6ct) в окружение systemd, и после
# выхода из Hyprland Plasma запускала plasmashell с чужой Qt-темой (чёрный экран).
# Plasma выполняет этот скрипт при входе, до запуска своих сервисов.
unset QT_QPA_PLATFORMTHEME
systemctl --user unset-environment QT_QPA_PLATFORMTHEME
