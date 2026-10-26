# Стандартный конфиг CachyOS: алиасы, PATH (~/.local/bin), приветствие с fastfetch
source /usr/share/cachyos-fish-config/cachyos-config.fish

if status is-interactive
    # Строка приглашения — Starship (~/.config/starship.toml)
    starship init fish | source
end
