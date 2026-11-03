#!/usr/bin/env bash
THEMES_DIR="$HOME/.config/waybar/themes"
CURRENT="$THEMES_DIR/current.css"

# Список доступных тем
themes=$(find "$THEMES_DIR" -maxdepth 1 -name "*.css" ! -name "current.css" -exec basename {} .css \; | sort)

if [ -z "$themes" ]; then
    notify-send "Waybar Themes" "Темы не найдены в $THEMES_DIR"
    exit 1
fi

chosen=$(echo "$themes" | fuzzel --dmenu --prompt "🎨 Тема Waybar: ")

if [ -n "$chosen" ] && [ -f "$THEMES_DIR/$chosen.css" ]; then
    cp "$THEMES_DIR/$chosen.css" "$CURRENT"
    # Отправляем SIGUSR2 для мягкой перезагрузки Waybar, либо перезапускаем
    if pgrep -x waybar >/dev/null; then
        killall -SIGUSR2 waybar 2>/dev/null || (killall waybar && waybar &)
    else
        waybar &
    fi
fi
