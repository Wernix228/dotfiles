# Стандартный конфиг CachyOS: алиасы, PATH (~/.local/bin), приветствие с fastfetch
source /usr/share/cachyos-fish-config/cachyos-config.fish

# Приветствие: fastfetch со случайным пиксельным персонажем (картинка — только в kitty)
function fish_greeting
    set -l sprites ~/.local/share/fastfetch/sprites/*.png
    if test "$TERM" = xterm-kitty; and set -q sprites[1]
        fastfetch --logo (random choice $sprites) --logo-type kitty-direct --logo-width 16 --logo-preserve-aspect-ratio
    else
        fastfetch
    end
end

if status is-interactive
    # Строка приглашения — Starship (~/.config/starship.toml)
    starship init fish | source
end
