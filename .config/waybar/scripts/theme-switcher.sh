#!/usr/bin/env bash

THEMES_WAYBAR="$HOME/.config/waybar/themes"
THEMES_FUZZEL="$HOME/.config/fuzzel/themes"
THEMES_WLOGOUT="$HOME/.config/wlogout/themes"

WAYBAR_CURRENT="$THEMES_WAYBAR/current.css"
BT_CURRENT="$THEMES_WAYBAR/bluetooth_theme.css"
FUZZEL_CURRENT="$HOME/.config/fuzzel/fuzzel_theme.ini"
WLOGOUT_CURRENT="$HOME/.config/wlogout/theme.css"

# Список вариантов для меню Fuzzel
options="Dark Glass\nWhite Frost\nMidnight Lavender\nNeon Cyan\nRosé Sakura\nTokyo Night\nNord Ice\nCyber Emerald\nGruvbox Gold\nRuby Crimson"

chosen=$(echo -e "$options" | fuzzel --dmenu --prompt "🎨 Тема: ")

if [ -z "$chosen" ]; then
    exit 0
fi

case "$chosen" in
    "Dark Glass")        theme="dark" ;;
    "White Frost")       theme="white" ;;
    "Midnight Lavender") theme="violet" ;;
    "Neon Cyan")         theme="cyan" ;;
    "Rosé Sakura")       theme="rose-pine" ;;
    "Tokyo Night")       theme="tokyo-night" ;;
    "Nord Ice")          theme="nord" ;;
    "Cyber Emerald")     theme="emerald" ;;
    "Gruvbox Gold")      theme="amber" ;;
    "Ruby Crimson")      theme="crimson" ;;
    *)                   exit 0 ;;
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
