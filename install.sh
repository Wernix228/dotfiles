#!/usr/bin/env bash
# Установка райса на чистый CachyOS (KDE Plasma остаётся запасной сессией).
#
#   git clone https://github.com/Wernix228/dotfiles ~/dotfiles
#   ~/dotfiles/install.sh              # всё, кроме обоев
#   ~/dotfiles/install.sh --wallpapers # + коллекции обоев Catppuccin (~1,1 ГБ)
#   ~/dotfiles/install.sh --dry-run    # только показать, что будет сделано
#
# Повторный запуск безопасен: уже установленное пропускается.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPERS=0
DRY=0
for arg in "$@"; do
    case "$arg" in
        --wallpapers) WALLPAPERS=1 ;;
        --dry-run)    DRY=1 ;;
        -h|--help)    sed -n '2,9p' "$0"; exit 0 ;;
        *) echo "Неизвестный параметр: $arg" >&2; exit 1 ;;
    esac
done

step() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
run()  { if [ "$DRY" = 1 ]; then info "[dry-run] $*"; else "$@"; fi }

[ "$(id -u)" -ne 0 ] || { echo "Запускайте от обычного пользователя, не через sudo" >&2; exit 1; }
command -v pacman >/dev/null || { echo "Нужен Arch/CachyOS (pacman)" >&2; exit 1; }

# ── Пакеты ────────────────────────────────────────────────────────────────────

PACMAN_PKGS=(
    # Hyprland и его окружение
    hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent
    hypridle hyprlock hyprpaper
    # запасной набор, если нет Noctalia; Waybar ещё и панель driftwm
    waybar fuzzel mako network-manager-applet
    # driftwm: X11-программы, скриншаринг
    xwayland-satellite xdg-desktop-portal-wlr adwaita-fonts
    # утилиты, на которые ссылаются бинды
    kitty dolphin firefox grim slurp wl-clipboard cliphist brightnessctl playerctl
    pavucontrol wireplumber
    # оформление
    ttf-jetbrains-mono-nerd noto-fonts papirus-icon-theme adw-gtk-theme qt6ct qt6-wayland
    # терминал
    fish starship fastfetch btop cava imagemagick
    # игры
    gamescope gamemode mangohud
    # экран блокировки qylock
    quickshell qt6-declarative qt6-5compat qt6-svg qt6-multimedia qt6-multimedia-ffmpeg
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
    # инструменты установки
    git stow curl unzip python
)

# Из AUR (собираются через paru). Не ставьте noctalia-shell из репозитория CachyOS:
# он упакован как старая версия на Quickshell и не запускается.
AUR_PKGS=(driftwm noctalia-git)

step "Пакеты из репозиториев"
run sudo pacman -S --needed "${PACMAN_PKGS[@]}"

step "Пакеты из AUR: ${AUR_PKGS[*]}"
if ! command -v paru >/dev/null; then
    info "paru не найден — ставлю из репозитория CachyOS"
    run sudo pacman -S --needed paru
fi
info "paru покажет PKGBUILD и спросит подтверждение"
run paru -S --needed "${AUR_PKGS[@]}"

# ── Конфиги (GNU Stow) ────────────────────────────────────────────────────────

STOW_PKGS=(hypr noctalia waybar fuzzel mako kitty fish starship fastfetch btop cava qt6ct driftwm)
# Plasma: только скрипт в ~/.config/plasma-workspace/env, без захвата всей папки
STOW_NOFOLD=(plasma)
BACKUP="$HOME/.dotfiles-backup/$(date +%F_%H-%M-%S)"

# Файлы, которые мешают stow (например конфиг fish из /etc/skel), переносим в бэкап
backup_conflicts() {
    local pkg="$1"; shift
    local conflicts
    # stow -n при конфликтах завершается с ошибкой — это ожидаемо, не прерываем скрипт
    conflicts=$({ stow -n -d "$DOTFILES" -t "$HOME" "$@" "$pkg" 2>&1 || true; } \
        | sed -nE 's/.*over existing target ([^ ]+) since.*/\1/p; s/.*existing target is [^:]*: (.+)$/\1/p' \
        | sort -u)
    for rel in $conflicts; do
        [ -e "$HOME/$rel" ] || [ -L "$HOME/$rel" ] || continue
        info "мешает $rel → $BACKUP/"
        run mkdir -p "$BACKUP/$(dirname "$rel")"
        run mv "$HOME/$rel" "$BACKUP/$rel"
    done
}

step "Конфиги: stow ${STOW_PKGS[*]} ${STOW_NOFOLD[*]}"
for pkg in "${STOW_PKGS[@]}"; do
    backup_conflicts "$pkg"
    run stow -d "$DOTFILES" -t "$HOME" "$pkg"
done
for pkg in "${STOW_NOFOLD[@]}"; do
    backup_conflicts "$pkg" --no-folding
    run stow -d "$DOTFILES" -t "$HOME" --no-folding "$pkg"
done

# qt6ct не раскрывает ~ — путь к цветам Noctalia прописан абсолютным
if [ "$HOME" != "/home/wernix" ]; then
    info "qt6ct.conf: /home/wernix → $HOME"
    run sed -i "s|/home/wernix|$HOME|g" "$DOTFILES/qt6ct/.config/qt6ct/qt6ct.conf"
fi

# ── То, что не хранится в репозитории ─────────────────────────────────────────

step "Курсор Catppuccin Mocha Mauve"
CURSOR_DIR="$HOME/.local/share/icons/catppuccin-mocha-mauve-cursors"
if [ -d "$CURSOR_DIR" ]; then
    info "уже установлен"
else
    tmp=$(mktemp -d)
    run curl -fsSL -o "$tmp/c.zip" \
        https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-mocha-mauve-cursors.zip
    run mkdir -p "$HOME/.local/share/icons"
    run unzip -q "$tmp/c.zip" -d "$HOME/.local/share/icons"
    rm -rf "$tmp"
fi

step "Пиксельные персонажи для fastfetch"
if compgen -G "$HOME/.local/share/fastfetch/sprites/*.png" >/dev/null; then
    info "уже скачаны"
else
    run bash "$DOTFILES/fastfetch/get-sprites.sh"
fi

step "Экран блокировки qylock (тема из ~/.config/qylock/theme, по умолчанию minecraft)"
QYLOCK_SRC="$HOME/Git/qylock"
QYLOCK_DST="$HOME/.local/share/quickshell-lockscreen"
if [ -d "$QYLOCK_SRC/.git" ]; then
    run git -C "$QYLOCK_SRC" pull -q --ff-only
else
    run mkdir -p "$HOME/Git"
    run git clone -q https://github.com/Darkkal44/qylock "$QYLOCK_SRC"
fi
# То же, что делает qylock/quickshell.sh, но без интерактивных вопросов
run rm -rf "$QYLOCK_DST"
run cp -r "$QYLOCK_SRC/quickshell-lockscreen" "$QYLOCK_DST"
run ln -sfn "$QYLOCK_SRC/themes" "$QYLOCK_DST/themes_link"
run chmod +x "$QYLOCK_DST/lock.sh"
[ -f "$HOME/.config/qylock/theme" ] || { run mkdir -p "$HOME/.config/qylock"; [ "$DRY" = 1 ] || echo minecraft > "$HOME/.config/qylock/theme"; }
# Заглушка объекта keyboard из SDDM: без неё часть тем (Genshin) не находит пользователя
if [ "$DRY" = 0 ] && ! grep -q 'property var keyboard' "$QYLOCK_DST/lock_shell.qml"; then
    python3 - "$QYLOCK_DST/lock_shell.qml" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
anchor = "    readonly property var sessionModel: sddmShim.sessionModel\n"
assert anchor in s, "qylock изменился: заглушку keyboard нужно добавить вручную"
s = s.replace(anchor, anchor + "    property var keyboard: ({ numLock: true, capsLock: false, layouts: [], currentLayout: 0 })\n")
open(p, "w").write(s)
EOF
    info "заглушка keyboard добавлена"
fi

if [ "$WALLPAPERS" = 1 ]; then
    step "Обои Catppuccin Mocha (~1,1 ГБ) → ~/Pictures/Wallpapers"
    W="$HOME/Pictures/Wallpapers"
    run mkdir -p "$W"
    [ -d "$W/catppuccin-mocha" ] || run git clone -q --depth 1 https://github.com/orangci/walls-catppuccin-mocha.git "$W/catppuccin-mocha"
    [ -d "$W/catppuccin-categories" ] || run git clone -q --depth 1 https://github.com/zhichaoh/catppuccin-wallpapers.git "$W/catppuccin-categories"
else
    step "Обои пропущены (добавить: install.sh --wallpapers)"
fi

# ── Готово ────────────────────────────────────────────────────────────────────

step "Готово"
info "Выйдите из Plasma («Завершить сеанс») и на экране входа выберите Hyprland или driftwm."
info "Plasma остаётся в списке как запасная сессия."
[ -d "$BACKUP" ] && info "Мешавшие файлы перенесены в $BACKUP"
info "Шпаргалка по клавишам — $DOTFILES/README.md"
