#!/usr/bin/env bash
# Apply saved wallpaper from ~/.config/hypr/current_wallpaper or fallback to default
set -e

CURRENT_WALL_FILE="$HOME/.config/hypr/current_wallpaper"
WALL=""

if [ -f "$CURRENT_WALL_FILE" ]; then
    CANDIDATE=$(cat "$CURRENT_WALL_FILE" | tr -d '\r\n')
    if [ -n "$CANDIDATE" ] && [ -f "$CANDIDATE" ]; then
        WALL="$CANDIDATE"
    fi
fi

if [ -z "$WALL" ]; then
    DEFAULT_CANDIDATES=(
        "$HOME/Изображения/Wallpapers/189d538e3d89f6dcbb4b430d2afb2019.jpg"
        "$HOME/Изображения/Wallpapers/default.jpg"
        "$HOME/Pictures/Wallpapers/189d538e3d89f6dcbb4b430d2afb2019.jpg"
        "$HOME/Pictures/Wallpapers/default.jpg"
    )
    for c in "${DEFAULT_CANDIDATES[@]}"; do
        if [ -f "$c" ]; then
            WALL="$c"
            break
        fi
    done
fi

# Fallback to first available wallpaper in directories if still not found
if [ -z "$WALL" ]; then
    WALL=$(find -L "$HOME/Изображения/Wallpapers" "$HOME/Pictures/Wallpapers" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.gif" \) 2>/dev/null | head -n 1)
fi

if [ -n "$WALL" ] && [ -f "$WALL" ]; then
    mkdir -p "$HOME/.config/hypr"
    echo "$WALL" > "$CURRENT_WALL_FILE"

    ext="${WALL##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    case "$ext_lower" in
        mp4|webm|mkv|mov|gif)
            if command -v mpvpaper >/dev/null 2>&1; then
                pkill swaybg || true
                pkill mpvpaper || true
                nohup mpvpaper -o "no-audio --loop-playlist shuffle=no" '*' "$WALL" >/dev/null 2>&1 &
            else
                # Fallback to swaybg with static image if mpvpaper is not installed
                fallback_img=$(find -L "$HOME/Изображения/Wallpapers" "$HOME/Pictures/Wallpapers" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | head -n 1)
                pkill mpvpaper || true
                pkill swaybg || true
                if [ -n "$fallback_img" ] && [ -f "$fallback_img" ]; then
                    nohup swaybg -i "$fallback_img" -m fill >/dev/null 2>&1 &
                fi
            fi
            ;;
        *)
            pkill mpvpaper || true
            pkill swaybg || true
            nohup swaybg -i "$WALL" -m fill >/dev/null 2>&1 &
            ;;
    esac
fi
