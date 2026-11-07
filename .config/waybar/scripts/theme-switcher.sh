#!/usr/bin/env bash

THEMES_WAYBAR="$HOME/.config/waybar/themes"
THEMES_FUZZEL="$HOME/.config/fuzzel/themes"
THEMES_WLOGOUT="$HOME/.config/wlogout/themes"
THEMES_KITTY="$HOME/.config/kitty/themes"
THEMES_FF="$HOME/.config/fastfetch/themes"
THEMES_FISH="$HOME/.config/fish/themes"
THEMES_STARSHIP="$HOME/.config/starship/themes"

WAYBAR_CURRENT="$THEMES_WAYBAR/current.css"
BT_CURRENT="$THEMES_WAYBAR/bluetooth_theme.css"
FUZZEL_CURRENT="$HOME/.config/fuzzel/fuzzel_theme.ini"
WLOGOUT_CURRENT="$HOME/.config/wlogout/theme.css"
KITTY_CURRENT="$HOME/.config/kitty/current-theme.conf"
FF_CURRENT="$HOME/.config/fastfetch/config.jsonc"
FISH_CURRENT="$THEMES_FISH/current.fish"
STARSHIP_CURRENT="$HOME/.config/starship.toml"
STATE_FILE="$HOME/.config/terminal-settings.json"

# Список всех 39 тем (10 базовых + 29 дизайнерских)
options="🌌 Dark Glass
❄️ White Frost
🔮 Midnight Lavender
💎 Neon Cyan
🌸 Rosé Sakura
🌃 Tokyo Night
🧊 Nord Ice
🌲 Cyber Emerald
🍯 Gruvbox Gold
🍷 Ruby Crimson
☕ Catppuccin Mocha
🧁 Catppuccin Macchiato
🧋 Catppuccin Frappé
🥛 Catppuccin Latte
🧛 Dracula Vampire
🌘 Solarized Dark
☀️ Solarized Light
🌆 Synthwave '84
⚡ Cyberpunk 2077
✨ Aura Dark
⚛️ One Dark Pro
🍂 Gruvbox Dark
📜 Gruvbox Light
🌿 Everforest
🌊 Kanagawa Wave
🎨 Monokai Pro
🌇 Sunset Twilight
🐬 Ocean Abyss
🩸 Blood Moon
🍃 Carbon Mint
🖤 Oxocarbon
🟢 Matrix Neon
🌌 Nordic Aurora
☀️ Solar Flare
🌸 Sakura Pastel
⚪ Noir Monochrome
🔘 Stealth Carbon
🔥 Blaze Orange
👑 Cyber Gold"

chosen=$(echo "$options" | fuzzel --dmenu --lines 15 --width 28 --prompt "🎨 Тема: ")

if [ -z "$chosen" ]; then
  exit 0
fi

case "$chosen" in
  *"Dark Glass"*)           theme="dark" ;;
  *"White Frost"*)          theme="white" ;;
  *"Midnight Lavender"*)    theme="violet" ;;
  *"Neon Cyan"*)            theme="cyan" ;;
  *"Rosé Sakura"*)          theme="rose-pine" ;;
  *"Tokyo Night"*)          theme="tokyo-night" ;;
  *"Nord Ice"*)             theme="nord" ;;
  *"Cyber Emerald"*)        theme="emerald" ;;
  *"Gruvbox Gold"*)         theme="amber" ;;
  *"Ruby Crimson"*)         theme="crimson" ;;
  *"Catppuccin Mocha"*)     theme="catppuccin-mocha" ;;
  *"Catppuccin Macchiato"*) theme="catppuccin-macchiato" ;;
  *"Catppuccin Frappé"*)    theme="catppuccin-frappe" ;;
  *"Catppuccin Latte"*)     theme="catppuccin-latte" ;;
  *"Dracula Vampire"*)      theme="dracula" ;;
  *"Solarized Dark"*)       theme="solarized-dark" ;;
  *"Solarized Light"*)      theme="solarized-light" ;;
  *"Synthwave"*)            theme="synthwave" ;;
  *"Cyberpunk 2077"*)       theme="cyberpunk-2077" ;;
  *"Aura Dark"*)            theme="aura-dark" ;;
  *"One Dark Pro"*)         theme="one-dark" ;;
  *"Gruvbox Dark"*)         theme="gruvbox-dark" ;;
  *"Gruvbox Light"*)        theme="gruvbox-light" ;;
  *"Everforest"*)           theme="everforest" ;;
  *"Kanagawa Wave"*)        theme="kanagawa" ;;
  *"Monokai Pro"*)          theme="monokai-pro" ;;
  *"Sunset Twilight"*)      theme="sunset" ;;
  *"Ocean Abyss"*)          theme="ocean" ;;
  *"Blood Moon"*)           theme="blood-moon" ;;
  *"Carbon Mint"*)          theme="carbon-mint" ;;
  *"Oxocarbon"*)            theme="oxocarbon" ;;
  *"Matrix Neon"*)          theme="matrix-neon" ;;
  *"Nordic Aurora"*)        theme="nordic-aurora" ;;
  *"Solar Flare"*)          theme="solar-flare" ;;
  *"Sakura Pastel"*)        theme="sakura-pastel" ;;
  *"Noir Monochrome"*)      theme="noir-white" ;;
  *"Stealth Carbon"*)       theme="stealth-gray" ;;
  *"Blaze Orange"*)         theme="blaze-orange" ;;
  *"Cyber Gold"*)           theme="cyber-gold" ;;
  *)                        exit 0 ;;
esac

# 1. Применяем тему для Waybar и Bluetooth меню
if [ -f "$THEMES_WAYBAR/$theme.css" ]; then
  cp "$THEMES_WAYBAR/$theme.css" "$WAYBAR_CURRENT"
  cp "$THEMES_WAYBAR/$theme.css" "$BT_CURRENT"
fi

# 2. Применяем тему для Fuzzel
if [ -f "$THEMES_FUZZEL/$theme.ini" ]; then
  cp "$THEMES_FUZZEL/$theme.ini" "$FUZZEL_CURRENT"
fi

# 3. Применяем тему для Wlogout
if [ -f "$THEMES_WLOGOUT/$theme.css" ]; then
  cp "$THEMES_WLOGOUT/$theme.css" "$WLOGOUT_CURRENT"
fi

# 4. Применяем тему для Kitty
if [ -f "$THEMES_KITTY/$theme.conf" ]; then
  cp "$THEMES_KITTY/$theme.conf" "$KITTY_CURRENT"
  killall -SIGUSR1 kitty 2>/dev/null || true
fi

# 5. Применяем тему для Fastfetch
if [ -f "$THEMES_FF/$theme.json" ] && [ -f "$FF_CURRENT" ]; then
  tmp=$(mktemp)
  if jq --slurpfile t "$THEMES_FF/$theme.json" '
    .display.color = $t[0].display.color |
    .display.constants = $t[0].display.constants |
    .logo.color = $t[0].logo.color
  ' "$FF_CURRENT" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$FF_CURRENT"
  else
    rm -f "$tmp"
  fi
fi

# 5b. Применяем тему для Fish (цвета промпта и синтаксиса)
if [ -f "$THEMES_FISH/$theme.fish" ]; then
  mkdir -p "$THEMES_FISH"
  cp "$THEMES_FISH/$theme.fish" "$FISH_CURRENT"
  fish -c "source '$FISH_CURRENT'; set -U fish_color_user \$fish_color_user; set -U fish_color_host \$fish_color_host; set -U fish_color_cwd \$fish_color_cwd; set -U fish_color_command \$fish_color_command; set -U fish_color_operator \$fish_color_operator; set -U fish_color_param \$fish_color_param; set -U fish_color_keyword \$fish_color_keyword" 2>/dev/null || true
fi

# 5c. Применяем тему для Starship
if [ -f "$THEMES_STARSHIP/$theme.toml" ]; then
  cp "$THEMES_STARSHIP/$theme.toml" "$STARSHIP_CURRENT"
fi

# 6. Обновляем terminal-settings.json (2 отступа)
if [ -f "$STATE_FILE" ]; then
  tmp=$(mktemp)
  if jq ".terminal.theme = \"$theme\" | .fastfetch.theme = \"$theme\" | .starship.theme = \"$theme\"" "$STATE_FILE" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$STATE_FILE"
  else
    rm -f "$tmp"
  fi
fi

# 7. Перезагружаем Waybar через SIGUSR2 (мягкая перезагрузка стилей)
if pgrep -x waybar >/dev/null; then
  killall -SIGUSR2 waybar 2>/dev/null || true
fi

notify-send -a "Оформление" -i preferences-desktop-theme "Тема переключена" "$chosen (Waybar, Kitty, Shell, Starship, Fastfetch, Fuzzel)"
