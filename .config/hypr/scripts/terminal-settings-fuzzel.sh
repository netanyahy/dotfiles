#!/usr/bin/env bash
# ==============================================================================
# terminal-settings-fuzzel.sh
# Interactive Fuzzel menu for terminal, fastfetch and starship styling & settings.
# Config: ~/.config/terminal-settings.json (2-space indent)
# ==============================================================================

STATE_FILE="$HOME/.config/terminal-settings.json"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
KITTY_CURRENT_THEME="$HOME/.config/kitty/current-theme.conf"
KITTY_THEMES_DIR="$HOME/.config/kitty/themes"
FISH_THEMES_DIR="$HOME/.config/fish/themes"

FASTFETCH_CONF="$HOME/.config/fastfetch/config.jsonc"
FASTFETCH_THEMES_DIR="$HOME/.config/fastfetch/themes"
FASTFETCH_PRESETS_DIR="$HOME/.config/fastfetch/presets"

STARSHIP_CONF="$HOME/.config/starship.toml"
STARSHIP_THEMES_DIR="$HOME/.config/starship/themes"
STARSHIP_PRESETS_DIR="$HOME/.config/starship/presets"

WAYBAR_THEMES="$HOME/.config/waybar/themes"
WAYBAR_CURRENT="$WAYBAR_THEMES/current.css"
BT_CURRENT="$WAYBAR_THEMES/bluetooth_theme.css"
FUZZEL_CURRENT="$HOME/.config/fuzzel/fuzzel_theme.ini"
FUZZEL_THEMES="$HOME/.config/fuzzel/themes"
WLOGOUT_CURRENT="$HOME/.config/wlogout/theme.css"
WLOGOUT_THEMES="$HOME/.config/wlogout/themes"

# ------------------------------------------------------------------------------
# 1. State Management
# ------------------------------------------------------------------------------
init_state() {
  if [ ! -f "$STATE_FILE" ]; then
    cat <<'JSON' > "$STATE_FILE"
{
  "startup": {
    "show_settings_summary": false
  },
  "starship": {
    "enabled": true,
    "preset": "user_default",
    "theme": "amber"
  },
  "fastfetch": {
    "enabled": true,
    "preset": "gentoo_box",
    "theme": "amber"
  },
  "terminal": {
    "theme": "amber",
    "opacity": "0.70",
    "padding": "21.75",
    "cursor_shape": "beam",
    "cursor_trail": "1",
    "font_size": "16.0"
  }
}
JSON
  fi
}

get_state() {
  local query="$1"
  local def="$2"
  local val
  val=$(jq -r "try ($query) catch empty" "$STATE_FILE" 2>/dev/null)
  if [ -z "$val" ] || [ "$val" = "null" ]; then
    echo "$def"
  else
    echo "$val"
  fi
}

set_state() {
  local query="$1"
  local tmp
  tmp=$(mktemp)
  if jq "$query" "$STATE_FILE" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$STATE_FILE"
  else
    rm -f "$tmp"
  fi
}

# Автосохранение: вызывается при любом выходе из скрипта
on_exit() {
  sync "$STATE_FILE" 2>/dev/null || true
  notify-send -t 1500 -i dialog-information "Терминал" "Настройки сохранены" 2>/dev/null || true
}
trap on_exit EXIT INT TERM

# ------------------------------------------------------------------------------
# 2. Helpers
# ------------------------------------------------------------------------------
fuzzel_select() {
  local prompt="$1"
  local lines="$2"
  shift 2
  printf '%s\n' "$@" | fuzzel --dmenu --lines "$lines" --width 46 --prompt "$prompt" --no-sort || true
}

update_kitty_option() {
  local key="$1"
  local val="$2"
  if [ -f "$KITTY_CONF" ]; then
    if grep -q "^${key} " "$KITTY_CONF" 2>/dev/null; then
      sed -i "s|^${key} .*|${key} ${val}|" "$KITTY_CONF"
    else
      echo "${key} ${val}" >> "$KITTY_CONF"
    fi
    killall -SIGUSR1 kitty 2>/dev/null || true
  fi
}

apply_kitty_theme() {
  local theme_slug="$1"
  if [ -f "$KITTY_THEMES_DIR/$theme_slug.conf" ]; then
    cp "$KITTY_THEMES_DIR/$theme_slug.conf" "$KITTY_CURRENT_THEME"
    set_state ".terminal.theme = \"$theme_slug\""
    killall -SIGUSR1 kitty 2>/dev/null || true
  fi
  if [ -f "$FISH_THEMES_DIR/$theme_slug.fish" ]; then
    mkdir -p "$FISH_THEMES_DIR"
    cp "$FISH_THEMES_DIR/$theme_slug.fish" "$FISH_THEMES_DIR/current.fish"
    fish -c "source '$FISH_THEMES_DIR/current.fish'; set -U fish_color_user \$fish_color_user; set -U fish_color_host \$fish_color_host; set -U fish_color_cwd \$fish_color_cwd; set -U fish_color_command \$fish_color_command; set -U fish_color_operator \$fish_color_operator; set -U fish_color_param \$fish_color_param; set -U fish_color_keyword \$fish_color_keyword" 2>/dev/null || true
  fi
}

apply_fastfetch_theme() {
  local theme_slug="$1"
  local theme_file="$FASTFETCH_THEMES_DIR/$theme_slug.json"
  if [ -f "$theme_file" ] && [ -f "$FASTFETCH_CONF" ]; then
    local tmp
    tmp=$(mktemp)
    if jq --slurpfile t "$theme_file" '
      .display.color = $t[0].display.color |
      .display.constants = $t[0].display.constants |
      .logo.color = $t[0].logo.color
    ' "$FASTFETCH_CONF" > "$tmp" 2>/dev/null; then
      mv "$tmp" "$FASTFETCH_CONF"
    else
      rm -f "$tmp"
    fi
    set_state ".fastfetch.theme = \"$theme_slug\""
  fi
}

apply_starship_theme() {
  local theme_slug="$1"
  if [ -f "$STARSHIP_THEMES_DIR/$theme_slug.toml" ]; then
    cp "$STARSHIP_THEMES_DIR/$theme_slug.toml" "$STARSHIP_CONF"
    set_state ".starship.theme = \"$theme_slug\""
  fi
}

# ------------------------------------------------------------------------------
# 3. 39 Themes Mapping
# ------------------------------------------------------------------------------
get_theme_slug() {
  case "$1" in
    *"Dark Glass"*)           echo "dark" ;;
    *"White Frost"*)          echo "white" ;;
    *"Midnight Lavender"*)    echo "violet" ;;
    *"Neon Cyan"*)            echo "cyan" ;;
    *"Rosé Sakura"*)          echo "rose-pine" ;;
    *"Tokyo Night"*)          echo "tokyo-night" ;;
    *"Nord Ice"*)             echo "nord" ;;
    *"Cyber Emerald"*)        echo "emerald" ;;
    *"Gruvbox Gold"*)         echo "amber" ;;
    *"Ruby Crimson"*)         echo "crimson" ;;
    *"Catppuccin Mocha"*)     echo "catppuccin-mocha" ;;
    *"Catppuccin Macchiato"*) echo "catppuccin-macchiato" ;;
    *"Catppuccin Frappé"*)    echo "catppuccin-frappe" ;;
    *"Catppuccin Latte"*)     echo "catppuccin-latte" ;;
    *"Dracula Vampire"*)      echo "dracula" ;;
    *"Solarized Dark"*)       echo "solarized-dark" ;;
    *"Solarized Light"*)      echo "solarized-light" ;;
    *"Synthwave"*)            echo "synthwave" ;;
    *"Cyberpunk 2077"*)       echo "cyberpunk-2077" ;;
    *"Aura Dark"*)            echo "aura-dark" ;;
    *"One Dark Pro"*)         echo "one-dark" ;;
    *"Gruvbox Dark"*)         echo "gruvbox-dark" ;;
    *"Gruvbox Light"*)        echo "gruvbox-light" ;;
    *"Everforest"*)           echo "everforest" ;;
    *"Kanagawa Wave"*)        echo "kanagawa" ;;
    *"Monokai Pro"*)          echo "monokai-pro" ;;
    *"Sunset Twilight"*)      echo "sunset" ;;
    *"Ocean Abyss"*)          echo "ocean" ;;
    *"Blood Moon"*)           echo "blood-moon" ;;
    *"Carbon Mint"*)          echo "carbon-mint" ;;
    *"Oxocarbon"*)            echo "oxocarbon" ;;
    *"Matrix Neon"*)          echo "matrix-neon" ;;
    *"Nordic Aurora"*)        echo "nordic-aurora" ;;
    *"Solar Flare"*)          echo "solar-flare" ;;
    *"Sakura Pastel"*)        echo "sakura-pastel" ;;
    *"Noir Monochrome"*)      echo "noir-white" ;;
    *"Stealth Carbon"*)       echo "stealth-gray" ;;
    *"Blaze Orange"*)         echo "blaze-orange" ;;
    *"Cyber Gold"*)           echo "cyber-gold" ;;
    *)                        echo "" ;;
  esac
}

THEME_LIST=(
  "🌌 Dark Glass"
  "❄️ White Frost"
  "🔮 Midnight Lavender"
  "💎 Neon Cyan"
  "🌸 Rosé Sakura"
  "🌃 Tokyo Night"
  "🧊 Nord Ice"
  "🌲 Cyber Emerald"
  "🍯 Gruvbox Gold"
  "🍷 Ruby Crimson"
  "☕ Catppuccin Mocha"
  "🧁 Catppuccin Macchiato"
  "🧋 Catppuccin Frappé"
  "🥛 Catppuccin Latte"
  "🧛 Dracula Vampire"
  "🌘 Solarized Dark"
  "☀️ Solarized Light"
  "🌆 Synthwave '84"
  "⚡ Cyberpunk 2077"
  "✨ Aura Dark"
  "⚛️ One Dark Pro"
  "🍂 Gruvbox Dark"
  "📜 Gruvbox Light"
  "🌿 Everforest"
  "🌊 Kanagawa Wave"
  "🎨 Monokai Pro"
  "🌇 Sunset Twilight"
  "🐬 Ocean Abyss"
  "🩸 Blood Moon"
  "🍃 Carbon Mint"
  "🖤 Oxocarbon"
  "🟢 Matrix Neon"
  "🌌 Nordic Aurora"
  "☀️ Solar Flare"
  "🌸 Sakura Pastel"
  "⚪ Noir Monochrome"
  "🔘 Stealth Carbon"
  "🔥 Blaze Orange"
  "👑 Cyber Gold"
)

# ------------------------------------------------------------------------------
# 4. Terminal Themes Menu (Kitty)
# ------------------------------------------------------------------------------
menu_terminal_themes() {
  local cur_theme
  cur_theme=$(get_state ".terminal.theme" "amber")

  local options=()
  for item in "${THEME_LIST[@]}"; do
    local slug
    slug=$(get_theme_slug "$item")
    if [ "$slug" = "$cur_theme" ]; then
      options+=("$item ●")
    else
      options+=("$item")
    fi
  done
  options+=("⬅ Назад")

  local sel
  sel=$(fuzzel_select "🎨 Тема терминала: " 15 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local slug
  slug=$(get_theme_slug "$sel")
  if [ -n "$slug" ]; then
    apply_kitty_theme "$slug"
    notify-send -i preferences-desktop-theme "Терминал" "Применена тема: $sel"
  fi
}

# ------------------------------------------------------------------------------
# 5. Fastfetch Themes Menu (39 Themes)
# ------------------------------------------------------------------------------
menu_fastfetch_themes() {
  local cur_theme
  cur_theme=$(get_state ".fastfetch.theme" "amber")

  local options=()
  for item in "${THEME_LIST[@]}"; do
    local slug
    slug=$(get_theme_slug "$item")
    if [ "$slug" = "$cur_theme" ]; then
      options+=("$item ●")
    else
      options+=("$item")
    fi
  done
  options+=("⬅ Назад")

  local sel
  sel=$(fuzzel_select "🌈 Цвета Fastfetch: " 15 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local slug
  slug=$(get_theme_slug "$sel")
  if [ -n "$slug" ]; then
    apply_fastfetch_theme "$slug"
    notify-send -i preferences-desktop-theme "Fastfetch" "Цветовая палитра: $sel"
  fi
}

# ------------------------------------------------------------------------------
# 5b. Starship Themes Menu (39 Themes)
# ------------------------------------------------------------------------------
menu_starship_themes() {
  local cur_theme
  cur_theme=$(get_state ".starship.theme" "amber")

  local options=()
  for item in "${THEME_LIST[@]}"; do
    local slug
    slug=$(get_theme_slug "$item")
    if [ "$slug" = "$cur_theme" ]; then
      options+=("$item ●")
    else
      options+=("$item")
    fi
  done
  options+=("⬅ Назад")

  local sel
  sel=$(fuzzel_select "🎨 Цвета Starship: " 15 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local slug
  slug=$(get_theme_slug "$sel")
  if [ -n "$slug" ]; then
    apply_starship_theme "$slug"
    notify-send -i preferences-desktop-theme "Starship" "Цветовая палитра: $sel"
  fi
}

# ------------------------------------------------------------------------------
# 6. Global Theme Switcher (Sync All)
# ------------------------------------------------------------------------------
menu_sync_all_themes() {
  local options=()
  for item in "${THEME_LIST[@]}"; do
    options+=("$item")
  done
  options+=("⬅ Назад")

  local sel
  sel=$(fuzzel_select "🌟 Тема для всего: " 15 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local slug
  slug=$(get_theme_slug "$sel")
  if [ -n "$slug" ]; then
    apply_kitty_theme "$slug"
    apply_fastfetch_theme "$slug"
    apply_starship_theme "$slug"

    [ -f "$WAYBAR_THEMES/$slug.css" ] && {
      cp "$WAYBAR_THEMES/$slug.css" "$WAYBAR_CURRENT"
      cp "$WAYBAR_THEMES/$slug.css" "$BT_CURRENT"
    }
    [ -f "$FUZZEL_THEMES/$slug.ini" ] && cp "$FUZZEL_THEMES/$slug.ini" "$FUZZEL_CURRENT"
    [ -f "$WLOGOUT_THEMES/$slug.css" ] && cp "$WLOGOUT_THEMES/$slug.css" "$WLOGOUT_CURRENT"

    pgrep -x waybar >/dev/null && killall -SIGUSR2 waybar 2>/dev/null || true

    notify-send -a "Оформление" -i preferences-desktop-theme "Тема синхронизирована" "$sel"
  fi
}

# ------------------------------------------------------------------------------
# 7. Starship Presets Menu
# ------------------------------------------------------------------------------
menu_starship_presets() {
  local cur_preset
  cur_preset=$(get_state ".starship.preset" "user_default")

  local options=(
    "🌟 Пользовательский (Кастомный) $([ "$cur_preset" = "user_default" ] && echo "●")"
    "💎 Tokyo Night Powerline $([ "$cur_preset" = "tokyo_night" ] && echo "●")"
    "🌿 Gruvbox Retro $([ "$cur_preset" = "gruvbox" ] && echo "●")"
    "🔮 Catppuccin Mocha $([ "$cur_preset" = "catppuccin" ] && echo "●")"
    "🚀 Minimal Clean $([ "$cur_preset" = "minimal" ] && echo "●")"
    "⚡ Cyberpunk Neon $([ "$cur_preset" = "cyberpunk" ] && echo "●")"
    "⬅ Назад"
  )

  local sel
  sel=$(fuzzel_select "󱄅 Стиль Starship: " 8 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local chosen=""
  case "$sel" in
    *"Пользовательский"*) chosen="user_default" ;;
    *"Tokyo Night"*)     chosen="tokyo_night" ;;
    *"Gruvbox"*)         chosen="gruvbox" ;;
    *"Catppuccin"*)      chosen="catppuccin" ;;
    *"Minimal"*)         chosen="minimal" ;;
    *"Cyberpunk"*)       chosen="cyberpunk" ;;
  esac

  if [ -n "$chosen" ] && [ -f "$STARSHIP_PRESETS_DIR/$chosen.toml" ]; then
    cp "$STARSHIP_PRESETS_DIR/$chosen.toml" "$STARSHIP_CONF"
    set_state ".starship.preset = \"$chosen\""
    notify-send -i terminal "Starship" "Применён стиль: $chosen"
  fi
}

# ------------------------------------------------------------------------------
# 8. Fastfetch Layouts Menu
# ------------------------------------------------------------------------------
menu_fastfetch_presets() {
  local cur_preset
  cur_preset=$(get_state ".fastfetch.preset" "gentoo_box")

  local options=(
    "🐧 Gentoo Box (Рамка + gentoo.txt) $([ "$cur_preset" = "gentoo_box" ] && echo "●")"
    "📊 Детальный системный $([ "$cur_preset" = "system_details" ] && echo "●")"
    "🌸 Neofetch Classic $([ "$cur_preset" = "neofetch_box" ] && echo "●")"
    "⚡ Компактный $([ "$cur_preset" = "compact" ] && echo "●")"
    "🚫 Без логотипа $([ "$cur_preset" = "clean_no_logo" ] && echo "●")"
    "⬅ Назад"
  )

  local sel
  sel=$(fuzzel_select "🖼️ Макет Fastfetch: " 7 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local chosen=""
  case "$sel" in
    *"Gentoo Box"*)   chosen="gentoo_box" ;;
    *"Детальный"*)    chosen="system_details" ;;
    *"Neofetch"*)     chosen="neofetch_box" ;;
    *"Компактный"*)   chosen="compact" ;;
    *"Без логотипа"*) chosen="clean_no_logo" ;;
  esac

  if [ -n "$chosen" ] && [ -f "$FASTFETCH_PRESETS_DIR/$chosen.jsonc" ]; then
    cp "$FASTFETCH_PRESETS_DIR/$chosen.jsonc" "$FASTFETCH_CONF"
    # Re-apply current theme colors to new preset
    local cur_theme
    cur_theme=$(get_state ".fastfetch.theme" "amber")
    apply_fastfetch_theme "$cur_theme"
    set_state ".fastfetch.preset = \"$chosen\""
    notify-send -i terminal "Fastfetch" "Применён макет: $chosen"
  fi
}

# ------------------------------------------------------------------------------
# 9. Window Settings Menus
# ------------------------------------------------------------------------------
menu_opacity() {
  local cur_op
  cur_op=$(get_state ".terminal.opacity" "0.70")

  local options=(
    "1.00 (Полностью непрозрачный) $([ "$cur_op" = "1.00" ] && echo "●")"
    "0.90 $([ "$cur_op" = "0.90" ] && echo "●")"
    "0.85 $([ "$cur_op" = "0.85" ] && echo "●")"
    "0.80 $([ "$cur_op" = "0.80" ] && echo "●")"
    "0.75 $([ "$cur_op" = "0.75" ] && echo "●")"
    "0.70 (Стандартный) $([ "$cur_op" = "0.70" ] && echo "●")"
    "0.60 $([ "$cur_op" = "0.60" ] && echo "●")"
    "0.50 (Полупрозрачный) $([ "$cur_op" = "0.50" ] && echo "●")"
    "⬅ Назад"
  )

  local sel
  sel=$(fuzzel_select "🪟 Прозрачность: " 10 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local val=""
  case "$sel" in
    1.00*) val="1.00" ;;
    0.90*) val="0.90" ;;
    0.85*) val="0.85" ;;
    0.80*) val="0.80" ;;
    0.75*) val="0.75" ;;
    0.70*) val="0.70" ;;
    0.60*) val="0.60" ;;
    0.50*) val="0.50" ;;
  esac

  if [ -n "$val" ]; then
    update_kitty_option "background_opacity" "$val"
    set_state ".terminal.opacity = \"$val\""
    notify-send -i preferences-desktop-theme "Kitty" "Прозрачность: $val"
  fi
}

menu_padding() {
  local cur_pad
  cur_pad=$(get_state ".terminal.padding" "21.75")

  local options=(
    "0 px (Без отступов) $([ "$cur_pad" = "0" ] && echo "●")"
    "8 px (Минимальные) $([ "$cur_pad" = "8" ] && echo "●")"
    "14 px (Средние) $([ "$cur_pad" = "14" ] && echo "●")"
    "21.75 px (Стандартные) $([ "$cur_pad" = "21.75" ] && echo "●")"
    "30 px (Просторные) $([ "$cur_pad" = "30" ] && echo "●")"
    "⬅ Назад"
  )

  local sel
  sel=$(fuzzel_select "📏 Внутренние отступы: " 7 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local val=""
  case "$sel" in
    0\ px*)     val="0" ;;
    8\ px*)     val="8" ;;
    14\ px*)    val="14" ;;
    21.75\ px*) val="21.75" ;;
    30\ px*)    val="30" ;;
  esac

  if [ -n "$val" ]; then
    update_kitty_option "window_margin_width" "$val"
    set_state ".terminal.padding = \"$val\""
    notify-send -i preferences-desktop-theme "Kitty" "Отступы: ${val}px"
  fi
}

menu_cursor() {
  local cur_shape
  cur_shape=$(get_state ".terminal.cursor_shape" "beam")

  local options=(
    "beam (Полоска |) $([ "$cur_shape" = "beam" ] && echo "●")"
    "block (Прямоугольник █) $([ "$cur_shape" = "block" ] && echo "●")"
    "underline (Подчёркивание _) $([ "$cur_shape" = "underline" ] && echo "●")"
    "⬅ Назад"
  )

  local sel
  sel=$(fuzzel_select "🖱️ Форма курсора: " 5 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local val=""
  case "$sel" in
    beam*)      val="beam" ;;
    block*)     val="block" ;;
    underline*) val="underline" ;;
  esac

  if [ -n "$val" ]; then
    update_kitty_option "cursor_shape" "$val"
    set_state ".terminal.cursor_shape = \"$val\""
    notify-send -i input-mouse "Kitty" "Форма курсора: $val"
  fi
}

menu_font_size() {
  local cur_sz
  cur_sz=$(get_state ".terminal.font_size" "16.0")

  local options=(
    "12.0 pt $([ "$cur_sz" = "12.0" ] && echo "●")"
    "13.0 pt $([ "$cur_sz" = "13.0" ] && echo "●")"
    "14.0 pt $([ "$cur_sz" = "14.0" ] && echo "●")"
    "15.0 pt $([ "$cur_sz" = "15.0" ] && echo "●")"
    "16.0 pt (Стандартный) $([ "$cur_sz" = "16.0" ] && echo "●")"
    "17.0 pt $([ "$cur_sz" = "17.0" ] && echo "●")"
    "18.0 pt $([ "$cur_sz" = "18.0" ] && echo "●")"
    "20.0 pt $([ "$cur_sz" = "20.0" ] && echo "●")"
    "⬅ Назад"
  )

  local sel
  sel=$(fuzzel_select "🔤 Размер шрифта: " 10 "${options[@]}")
  if [ -z "$sel" ] || [[ "$sel" == *"Назад"* ]]; then
    return 0
  fi

  local val=""
  case "$sel" in
    12.0*) val="12.0" ;;
    13.0*) val="13.0" ;;
    14.0*) val="14.0" ;;
    15.0*) val="15.0" ;;
    16.0*) val="16.0" ;;
    17.0*) val="17.0" ;;
    18.0*) val="18.0" ;;
    20.0*) val="20.0" ;;
  esac

  if [ -n "$val" ]; then
    update_kitty_option "font_size" "$val"
    set_state ".terminal.font_size = \"$val\""
    notify-send -i preferences-desktop-font "Kitty" "Размер шрифта: $val"
  fi
}

# ------------------------------------------------------------------------------
# 10. Main Loop
# ------------------------------------------------------------------------------
run_menu() {
  init_state

  while true; do
    local st_en st_pr st_th ff_en ff_pr ff_th term_th sum_en op pad c_shape c_trail f_sz
    st_en=$(get_state ".starship.enabled" "true")
    st_pr=$(get_state ".starship.preset" "user_default")
    st_th=$(get_state ".starship.theme" "amber")
    ff_en=$(get_state ".fastfetch.enabled" "true")
    ff_pr=$(get_state ".fastfetch.preset" "gentoo_box")
    ff_th=$(get_state ".fastfetch.theme" "amber")
    term_th=$(get_state ".terminal.theme" "amber")
    sum_en=$(get_state ".startup.show_settings_summary" "false")

    op=$(get_state ".terminal.opacity" "0.70")
    pad=$(get_state ".terminal.padding" "21.75")
    c_shape=$(get_state ".terminal.cursor_shape" "beam")
    c_trail=$(get_state ".terminal.cursor_trail" "1")
    f_sz=$(get_state ".terminal.font_size" "16.0")

    local st_lbl ff_lbl sum_lbl trail_lbl
    [ "$st_en" = "true" ]  && st_lbl="[Вкл]"  || st_lbl="[Выкл]"
    [ "$ff_en" = "true" ]  && ff_lbl="[Вкл]"  || ff_lbl="[Выкл]"
    [ "$sum_en" = "true" ] && sum_lbl="[Вкл]" || sum_lbl="[Выкл]"
    [ "$c_trail" = "1" ]   && trail_lbl="[Вкл]" || trail_lbl="[Выкл]"

    local items=(
      "🎨 Цветовая тема терминала: ($term_th) ➔"
      "🌈 Цвета Fastfetch: ($ff_th) ➔"
      "🎨 Цвета Starship: ($st_th) ➔"
      "🌟 Синхронизировать всё ➔"
      "🖼️ Макет Fastfetch: ($ff_pr) ➔"
      "📊 Fastfetch при старте: $ff_lbl"
      "🚀 Starship Prompt: $st_lbl"
      "󱄅 Оформление Starship: ($st_pr) ➔"
      "📋 Выводить настройки при старте: $sum_lbl"
      "🪟 Прозрачность окна: $op ➔"
      "📏 Отступы окна: ${pad}px ➔"
      "🖱️ Форма курсора: $c_shape ➔"
      "✨ След курсора: $trail_lbl"
      "🔤 Размер шрифта: ${f_sz}pt ➔"
      "❌ Выход"
    )

    local chosen
    chosen=$(fuzzel_select "💻 Настройки терминала: " 15 "${items[@]}")

    # Пустая строка = Escape = выход (автосохранение через trap)
    if [ -z "$chosen" ]; then
      exit 0
    fi

    case "$chosen" in
      *"❌ Выход"*)
        exit 0
        ;;
      *"Цветовая тема терминала:"*)
        menu_terminal_themes
        ;;
      *"Цвета Fastfetch:"*)
        menu_fastfetch_themes
        ;;
      *"Цвета Starship:"*)
        menu_starship_themes
        ;;
      *"Синхронизировать всё"*)
        menu_sync_all_themes
        ;;
      *"Макет Fastfetch:"*)
        menu_fastfetch_presets
        ;;
      *"Fastfetch при старте:"*)
        if [ "$ff_en" = "true" ]; then
          set_state ".fastfetch.enabled = false"
          notify-send -i terminal "Fastfetch" "Вывод при старте выключен"
        else
          set_state ".fastfetch.enabled = true"
          notify-send -i terminal "Fastfetch" "Вывод при старте включён"
        fi
        ;;
      *"Starship Prompt:"*)
        if [ "$st_en" = "true" ]; then
          set_state ".starship.enabled = false"
          notify-send -i terminal "Starship" "Промпт выключен"
        else
          set_state ".starship.enabled = true"
          notify-send -i terminal "Starship" "Промпт включён"
        fi
        ;;
      *"Оформление Starship:"*)
        menu_starship_presets
        ;;
      *"Выводить настройки при старте:"*)
        if [ "$sum_en" = "true" ]; then
          set_state ".startup.show_settings_summary = false"
          notify-send -i terminal "Инфо-панель" "Вывод настроек выключен"
        else
          set_state ".startup.show_settings_summary = true"
          notify-send -i terminal "Инфо-панель" "Вывод настроек включён"
        fi
        ;;
      *"Прозрачность окна:"*)
        menu_opacity
        ;;
      *"Отступы окна:"*)
        menu_padding
        ;;
      *"Форма курсора:"*)
        menu_cursor
        ;;
      *"След курсора:"*)
        if [ "$c_trail" = "1" ]; then
          update_kitty_option "cursor_trail" "0"
          set_state ".terminal.cursor_trail = \"0\""
          notify-send -i input-mouse "Kitty" "След курсора выключен"
        else
          update_kitty_option "cursor_trail" "1"
          set_state ".terminal.cursor_trail = \"1\""
          notify-send -i input-mouse "Kitty" "След курсора включён"
        fi
        ;;
      *"Размер шрифта:"*)
        menu_font_size
        ;;
    esac
  done
}

run_menu
