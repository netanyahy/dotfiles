#!/usr/bin/env bash
# Quick wallpaper selector using Fuzzel dmenu
set -e

WALL_DIRS=("$HOME/Изображения/Wallpapers" "$HOME/Pictures/Wallpapers")
declare -A WALLPAPERS
declare -A SEEN_REAL
WALL_NAMES=()

for dir in "${WALL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        while IFS= read -r -d '' file; do
            [ -f "$file" ] || continue
            real=$(realpath "$file" 2>/dev/null || echo "$file")
            [ -f "$real" ] || continue
            name=$(basename "$file")
            ext="${file##*.}"
            ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
            case "$ext_lower" in
                mp4|webm|mkv|mov|gif)
                    display_name="🎬 $name"
                    ;;
                *)
                    display_name="$name"
                    ;;
            esac
            [ -n "${WALLPAPERS[$display_name]}" ] && continue
            [ -n "${SEEN_REAL[$real]}" ] && continue
            WALLPAPERS["$display_name"]="$real"
            SEEN_REAL["$real"]=1
            WALL_NAMES+=("$display_name")
        done < <(find -L "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.gif" \) -print0 2>/dev/null)
    fi
done

if [ ${#WALL_NAMES[@]} -eq 0 ]; then
    notify-send "Выбор обоев" "Обои не найдены в ~/Изображения/Wallpapers"
    exit 1
fi

# Sort wallpaper names alphabetically
IFS=$'\n' sorted_names=($(sort -f <<<"${WALL_NAMES[*]}"))
unset IFS

# Menu with Random option at top
menu_items="🎲 Случайные обои"$'\n'"$(printf '%s\n' "${sorted_names[@]}")"

chosen=$(echo -e "$menu_items" | fuzzel --dmenu --lines 12 --width 36 --prompt "🖼️ Обои: ")

[ -z "$chosen" ] && exit 0

if [ "$chosen" = "🎲 Случайные обои" ]; then
    rand_idx=$(( RANDOM % ${#sorted_names[@]} ))
    chosen_name="${sorted_names[$rand_idx]}"
    selected_wall="${WALLPAPERS[$chosen_name]}"
else
    selected_wall="${WALLPAPERS[$chosen]}"
fi

if [ -n "$selected_wall" ] && [ -f "$selected_wall" ]; then
    mkdir -p "$HOME/.config/hypr"
    echo "$selected_wall" > "$HOME/.config/hypr/current_wallpaper"

    ext="${selected_wall##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    case "$ext_lower" in
        mp4|webm|mkv|mov|gif)
            if command -v mpvpaper >/dev/null 2>&1; then
                pkill swaybg || true
                pkill mpvpaper || true
                nohup mpvpaper -o "no-audio --loop-playlist shuffle=no" '*' "$selected_wall" >/dev/null 2>&1 &
                notify-send "Обои обновлены" "$(basename "$selected_wall")" -i video
            else
                notify-send "Требуется mpvpaper" "Для воспроизведения анимированных обоев установите mpvpaper:\ndoas emerge gui-apps/mpvpaper (Gentoo) или pacman -S mpvpaper (Arch)" -i video
            fi
            ;;
        *)
            pkill mpvpaper || true
            pkill swaybg || true
            nohup swaybg -i "$selected_wall" -m fill >/dev/null 2>&1 &
            notify-send "Обои обновлены" "$(basename "$selected_wall")" -i "$selected_wall"
            ;;
    esac
fi
