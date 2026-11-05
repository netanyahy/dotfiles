#!/usr/bin/env bash

STYLES_DIR="$HOME/.config/waybar/styles"
CURRENT_STYLE="$STYLES_DIR/current-style.css"

options="💊 Floating Capsules (Раздельные капсулы)
🧊 Unified Glass Bar (Монолитная полоса)
🏝️ Three Islands (Три парящих острова)
✨ Minimalist Underline (Минимализм с полоской)
⚡ Cyberpunk Sharp (Квадратные блоки)
● Dot Matrix (Индикаторные точки)
🌈 Gradient Border (Неоновые рамки)
📐 Pill Compact (Ультра-компакт)
📟 Powerline Chevrons (Терминал блочный)
❄️ Nordic Frost (Арктический матовый)
🫧 Bubble Float (Парящие пузыри)
🎀 Ribbon Top (Прижатая верхняя лента)
💻 Bracket Tech (Хакерские скобки)
🔳 Double Border (Двойной контур)
💫 Glowing Strip (Светящаяся полоса)
⏰ Center Clock Focus (Акцентные часы)
🛸 Cyber HUD (Футуристичный интерфейс)
💊 Frosted Glass Pills (Матовые пилюли)
📟 Retro Terminal (Классический терминал)"

chosen=$(echo "$options" | fuzzel --dmenu --lines 19 --width 38 --prompt "✨ Стиль Waybar (сверху): ")

if [ -z "$chosen" ]; then
    exit 0
fi

case "$chosen" in
    *"Floating Capsules"*)     style_file="capsules.css"; name="Floating Capsules (Раздельные капсулы)" ;;
    *"Unified Glass Bar"*)     style_file="unified-bar.css"; name="Unified Glass Bar (Монолитная полоса)" ;;
    *"Three Islands"*)         style_file="three-islands.css"; name="Three Islands (Три парящих острова)" ;;
    *"Minimalist Underline"*)  style_file="underline.css"; name="Minimalist Underline (Минимализм с полоской)" ;;
    *"Cyberpunk Sharp"*)       style_file="cyber-boxes.css"; name="Cyberpunk Sharp (Квадратные блоки)" ;;
    *"Dot Matrix"*)            style_file="dot-matrix.css"; name="Dot Matrix (Индикаторные точки)" ;;
    *"Gradient Border"*)       style_file="gradient-border.css"; name="Gradient Border (Неоновые рамки)" ;;
    *"Pill Compact"*)          style_file="pill-compact.css"; name="Pill Compact (Ультра-компакт)" ;;
    *"Powerline Chevrons"*)    style_file="powerline.css"; name="Powerline Chevrons (Терминал блочный)" ;;
    *"Nordic Frost"*)          style_file="nordic-frost.css"; name="Nordic Frost (Арктический матовый)" ;;
    *"Bubble Float"*)          style_file="bubble-float.css"; name="Bubble Float (Парящие пузыри)" ;;
    *"Ribbon Top"*)            style_file="ribbon-top.css"; name="Ribbon Top (Прижатая верхняя лента)" ;;
    *"Bracket Tech"*)          style_file="bracket-tech.css"; name="Bracket Tech (Хакерские скобки)" ;;
    *"Double Border"*)         style_file="double-border.css"; name="Double Border (Двойной контур)" ;;
    *"Glowing Strip"*)         style_file="glowing-strip.css"; name="Glowing Strip (Светящаяся полоса)" ;;
    *"Center Clock Focus"*)    style_file="split-center-clock.css"; name="Center Clock Focus (Акцентные часы)" ;;
    *"Cyber HUD"*)             style_file="cyber-hud.css"; name="Cyber HUD (Футуристичный интерфейс)" ;;
    *"Frosted Glass Pills"*)   style_file="glass-pill.css"; name="Frosted Glass Pills (Матовые пилюли)" ;;
    *"Retro Terminal"*)        style_file="retro-terminal.css"; name="Retro Terminal (Классический терминал)" ;;
    *)                         exit 0 ;;
esac

if [ -f "$STYLES_DIR/$style_file" ]; then
    cp "$STYLES_DIR/$style_file" "$CURRENT_STYLE"
    
    # Мягкое обновление Waybar
    if pgrep -x waybar >/dev/null; then
        killall -SIGUSR2 waybar 2>/dev/null || true
    fi
    
    notify-send "Стиль Waybar изменен" "$name" -i waybar
fi
