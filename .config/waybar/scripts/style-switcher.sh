#!/usr/bin/env bash

STYLES_DIR="$HOME/.config/waybar/styles"
CURRENT_STYLE="$STYLES_DIR/current-style.css"

options="💊 Floating Capsules (Раздельные капсулы)
🧊 Unified Glass Bar (Монолитная полоса)
🏝️ Three Islands (Три парящих острова)
✨ Minimalist Underline (Минимализм с полоской)
⚡ Cyberpunk Sharp (Квадратные блоки)
● Dot Matrix (Индикаторные точки)"

chosen=$(echo "$options" | fuzzel --dmenu --lines 6 --width 36 --prompt "✨ Стиль Waybar (сверху): ")

if [ -z "$chosen" ]; then
    exit 0
fi

case "$chosen" in
    *"Floating Capsules"*)    style_file="capsules.css"; name="Floating Capsules (Раздельные капсулы)" ;;
    *"Unified Glass Bar"*)    style_file="unified-bar.css"; name="Unified Glass Bar (Монолитная полоса)" ;;
    *"Three Islands"*)        style_file="three-islands.css"; name="Three Islands (Три парящих острова)" ;;
    *"Minimalist Underline"*) style_file="underline.css"; name="Minimalist Underline (Минимализм с полоской)" ;;
    *"Cyberpunk Sharp"*)      style_file="cyber-boxes.css"; name="Cyberpunk Sharp (Квадратные блоки)" ;;
    *"Dot Matrix"*)           style_file="dot-matrix.css"; name="Dot Matrix (Индикаторные точки)" ;;
    *)                        exit 0 ;;
esac

if [ -f "$STYLES_DIR/$style_file" ]; then
    cp "$STYLES_DIR/$style_file" "$CURRENT_STYLE"
    
    # Мягкое обновление Waybar
    if pgrep -x waybar >/dev/null; then
        killall -SIGUSR2 waybar 2>/dev/null || true
    fi
    
    notify-send "Стиль Waybar изменен" "$name" -i waybar
fi
