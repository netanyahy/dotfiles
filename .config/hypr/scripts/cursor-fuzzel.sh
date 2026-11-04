#!/usr/bin/env bash
# Quick cursor theme selector using Fuzzel dmenu
set -e

CURSOR_DIRS=("$HOME/.icons" "$HOME/.local/share/icons" "/usr/share/icons")
declare -A THEMES
THEME_NAMES=()

for dir in "${CURSOR_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        for theme_path in "$dir"/*; do
            [ -d "$theme_path" ] || continue
            name=$(basename "$theme_path")
            case "$name" in
                default|hicolor|"."|"..")
                    continue
                    ;;
            esac
            if [ -d "$theme_path/cursors" ]; then
                if [ -z "${THEMES[$name]}" ]; then
                    THEMES["$name"]="$theme_path"
                    THEME_NAMES+=("$name")
                fi
            fi
        done
    fi
done

if [ ${#THEME_NAMES[@]} -eq 0 ]; then
    notify-send -i input-mouse "Выбор курсора" "Курсоры не найдены в системе"
    exit 1
fi

# Sort theme names alphabetically case-insensitively
IFS=$'\n' sorted_names=($(sort -f <<<"${THEME_NAMES[*]}"))
unset IFS

# Menu with Random option at top
menu_items="🎲 Случайный курсор"$'\n'"$(printf '%s\n' "${sorted_names[@]}")"

chosen=$(echo -e "$menu_items" | fuzzel --dmenu --lines 15 --width 38 --prompt "🖱️ Курсор: ")

[ -z "$chosen" ] && exit 0

if [ "$chosen" = "🎲 Случайный курсор" ]; then
    rand_idx=$(( RANDOM % ${#sorted_names[@]} ))
    chosen="${sorted_names[$rand_idx]}"
fi

# Validate that chosen theme exists
if [ -z "${THEMES[$chosen]}" ]; then
    notify-send -i dialog-error "Ошибка" "Неизвестная тема: $chosen"
    exit 1
fi

CURSOR_SIZE=24

# 1. Apply in Hyprland immediately
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl setcursor "$chosen" "$CURSOR_SIZE" || true
fi

# 2. Apply via gsettings for GTK/GNOME apps
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface cursor-theme "$chosen" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null || true
fi

# 3. Persist in Hyprland state
mkdir -p "$HOME/.config/hypr"
echo "$chosen" > "$HOME/.config/hypr/current_cursor"

# 4. Persist in default icon themes for XWayland / GTK compatibility
for default_dir in "$HOME/.icons/default" "$HOME/.local/share/icons/default"; do
    mkdir -p "$default_dir"
    cat <<EOF > "$default_dir/index.theme"
[Icon Theme]
Name=Default
Comment=Default cursor theme
Inherits=$chosen
EOF
done

notify-send -i input-mouse "Курсор изменен" "Тема: $chosen"
