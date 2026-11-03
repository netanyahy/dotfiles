#!/usr/bin/env bash

THEMES_WAYBAR="$HOME/.config/waybar/themes"
THEMES_FUZZEL="$HOME/.config/fuzzel/themes"
THEMES_WLOGOUT="$HOME/.config/wlogout/themes"

WAYBAR_CURRENT="$THEMES_WAYBAR/current.css"
BT_CURRENT="$THEMES_WAYBAR/bluetooth_theme.css"
FUZZEL_CURRENT="$HOME/.config/fuzzel/fuzzel_theme.ini"
WLOGOUT_CURRENT="$HOME/.config/wlogout/theme.css"

# Список всех 30 тем (10 базовых + 20 дизайнерских)
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
🍃 Carbon Mint"

chosen=$(echo "$options" | fuzzel --dmenu --lines 12 --width 28 --prompt "🎨 Тема: ")

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

# 4. Перезагружаем Waybar через SIGUSR2 (мягкая перезагрузка стилей)
if pgrep -x waybar >/dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null || true
fi

notify-send -a "Оформление" -i preferences-desktop-theme "Тема переключена" "$chosen"
