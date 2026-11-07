#!/usr/bin/env python3
import os
import re

WAYBAR_DIR = os.path.expanduser("~/.config/waybar/themes")
FUZZEL_DIR = os.path.expanduser("~/.config/fuzzel/themes")
KITTY_THEMES_DIR = os.path.expanduser("~/.config/kitty/themes")
FF_THEMES_DIR = os.path.expanduser("~/.config/fastfetch/themes")
FISH_THEMES_DIR = os.path.expanduser("~/.config/fish/themes")
STARSHIP_THEMES_DIR = os.path.expanduser("~/.config/starship/themes")

os.makedirs(KITTY_THEMES_DIR, exist_ok=True)
os.makedirs(FF_THEMES_DIR, exist_ok=True)
os.makedirs(FISH_THEMES_DIR, exist_ok=True)
os.makedirs(STARSHIP_THEMES_DIR, exist_ok=True)

# List of 39 themes from theme-switcher.sh
THEMES = [
  ("dark", "🌌 Dark Glass"),
  ("white", "❄️ White Frost"),
  ("violet", "🔮 Midnight Lavender"),
  ("cyan", "💎 Neon Cyan"),
  ("rose-pine", "🌸 Rosé Sakura"),
  ("tokyo-night", "🌃 Tokyo Night"),
  ("nord", "🧊 Nord Ice"),
  ("emerald", "🌲 Cyber Emerald"),
  ("amber", "🍯 Gruvbox Gold"),
  ("crimson", "🍷 Ruby Crimson"),
  ("catppuccin-mocha", "☕ Catppuccin Mocha"),
  ("catppuccin-macchiato", "🧁 Catppuccin Macchiato"),
  ("catppuccin-frappe", "🧋 Catppuccin Frappé"),
  ("catppuccin-latte", "🥛 Catppuccin Latte"),
  ("dracula", "🧛 Dracula Vampire"),
  ("solarized-dark", "🌘 Solarized Dark"),
  ("solarized-light", "☀️ Solarized Light"),
  ("synthwave", "🌆 Synthwave '84"),
  ("cyberpunk-2077", "⚡ Cyberpunk 2077"),
  ("aura-dark", "✨ Aura Dark"),
  ("one-dark", "⚛️ One Dark Pro"),
  ("gruvbox-dark", "🍂 Gruvbox Dark"),
  ("gruvbox-light", "📜 Gruvbox Light"),
  ("everforest", "🌿 Everforest"),
  ("kanagawa", "🌊 Kanagawa Wave"),
  ("monokai-pro", "🎨 Monokai Pro"),
  ("sunset", "🌇 Sunset Twilight"),
  ("ocean", "🐬 Ocean Abyss"),
  ("blood-moon", "🩸 Blood Moon"),
  ("carbon-mint", "🍃 Carbon Mint"),
  ("oxocarbon", "🖤 Oxocarbon"),
  ("matrix-neon", "🟢 Matrix Neon"),
  ("nordic-aurora", "🌌 Nordic Aurora"),
  ("solar-flare", "☀️ Solar Flare"),
  ("sakura-pastel", "🌸 Sakura Pastel"),
  ("noir-white", "⚪ Noir Monochrome"),
  ("stealth-gray", "🔘 Stealth Carbon"),
  ("blaze-orange", "🔥 Blaze Orange"),
  ("cyber-gold", "👑 Cyber Gold")
]

def hex_to_rgb(hex_str):
  hex_str = hex_str.lstrip('#')
  if len(hex_str) >= 6:
    return int(hex_str[0:2], 16), int(hex_str[2:4], 16), int(hex_str[4:6], 16)
  return 255, 255, 255

def rgba_to_rgb(rgba_str):
  m = re.search(r'rgba?\((\d+),\s*(\d+),\s*(\d+)', rgba_str)
  if m:
    return int(m.group(1)), int(m.group(2)), int(m.group(3))
  return 25, 25, 30

def get_contrast_fg(hex_str):
  r, g, b = hex_to_rgb(hex_str)
  lum = 0.299 * r + 0.587 * g + 0.114 * b
  return "#11111b" if lum > 135 else "#ffffff"

for slug, title in THEMES:
  css_path = os.path.join(WAYBAR_DIR, f"{slug}.css")
  ini_path = os.path.join(FUZZEL_DIR, f"{slug}.ini")

  bg_hex = "#1a1b26"
  fg_hex = "#c0caf5"
  acc_hex = "#7aa2f7"
  sec_hex = None

  # Extract from fuzzel ini first if available
  if os.path.exists(ini_path):
    ini_content = open(ini_path).read()
    m_bg = re.search(r'background=([0-9a-fA-F]{6})', ini_content)
    m_tx = re.search(r'text=([0-9a-fA-F]{6})', ini_content)
    m_ma = re.search(r'match=([0-9a-fA-F]{6})', ini_content)
    m_sm = re.search(r'selection-match=([0-9a-fA-F]{6})', ini_content)
    if m_bg: bg_hex = f"#{m_bg.group(1)}"
    if m_tx: fg_hex = f"#{m_tx.group(1)}"
    if m_ma: acc_hex = f"#{m_ma.group(1)}"
    if m_sm and f"#{m_sm.group(1)}" != acc_hex:
      sec_hex = f"#{m_sm.group(1)}"

  if os.path.exists(css_path):
    css_content = open(css_path).read()
    m_bg = re.search(r'bg-color\s+(rgba?\([^)]+\)|#[0-9a-fA-F]+)', css_content)
    m_tx = re.search(r'text-color\s+(#[0-9a-fA-F]+)', css_content)
    m_ac = re.search(r'accent-color\s+(#[0-9a-fA-F]+)', css_content)
    m_bt = re.search(r'bt-color\s+(#[0-9a-fA-F]+)', css_content)
    if not os.path.exists(ini_path):
      if m_bg:
        if '#' in m_bg.group(1):
          bg_hex = m_bg.group(1)
        else:
          r, g, b = rgba_to_rgb(m_bg.group(1))
          bg_hex = f"#{r:02x}{g:02x}{b:02x}"
      if m_tx: fg_hex = m_tx.group(1)
      if m_ac: acc_hex = m_ac.group(1)

    if not sec_hex:
      if m_bt and m_bt.group(1) != acc_hex:
        sec_hex = m_bt.group(1)
      elif m_ac and m_ac.group(1) != acc_hex:
        sec_hex = m_ac.group(1)

  if not sec_hex:
    if slug in ("dark", "noir-white"):
      sec_hex = "#b0b0b8"
    else:
      sec_hex = acc_hex

  bg_r, bg_g, bg_b = hex_to_rgb(bg_hex)
  fg_r, fg_g, fg_b = hex_to_rgb(fg_hex)
  acc_r, acc_g, acc_b = hex_to_rgb(acc_hex)

  # Generate Kitty theme config
  kitty_conf = f"""# Theme: {title} ({slug})
# Generated for Kitty
foreground {fg_hex}
background {bg_hex}
selection_foreground {bg_hex}
selection_background {acc_hex}

cursor {acc_hex}
cursor_text_color {bg_hex}

active_border_color {acc_hex}
inactive_border_color #3b4261

# Standard 16 colors
color0 #15161e
color1 #f7768e
color2 #9ece6a
color3 #e0af68
color4 {acc_hex}
color5 #bb9af7
color6 #7dcfff
color7 {fg_hex}

color8 #414868
color9 #f7768e
color10 #9ece6a
color11 #e0af68
color12 {acc_hex}
color13 #bb9af7
color14 #7dcfff
color15 #ffffff
"""
  with open(os.path.join(KITTY_THEMES_DIR, f"{slug}.conf"), "w") as f:
    f.write(kitty_conf)

  # Generate Fastfetch theme JSON (2-space indentation)
  ff_json = f"""{{
  "name": "{slug}",
  "title": "{title}",
  "display": {{
    "color": {{
      "keys": "38;2;{acc_r};{acc_g};{acc_b}",
      "title": "38;2;{acc_r};{acc_g};{acc_b}",
      "output": "38;2;{fg_r};{fg_g};{fg_b}"
    }},
    "constants": [
      "\\u001b[38;2;{fg_r};{fg_g};{fg_b}m",
      "\\u001b[38;2;{acc_r};{acc_g};{acc_b}m"
    ]
  }},
  "logo": {{
    "color": {{
      "1": "38;2;{acc_r};{acc_g};{acc_b}"
    }}
  }}
}}
"""
  with open(os.path.join(FF_THEMES_DIR, f"{slug}.json"), "w") as f:
    f.write(ff_json)

  # Generate Fish Shell theme (prompt & syntax colors)
  acc_clean = acc_hex.lstrip('#')
  fg_clean = fg_hex.lstrip('#')
  fish_script = f"""# Theme: {title} ({slug})
# Generated for Fish Shell (prompt & syntax colors)
set -g fish_color_user {acc_clean}
set -g fish_color_host {acc_clean}
set -g fish_color_host_remote {acc_clean}
set -g fish_color_cwd {acc_clean}
set -g fish_color_cwd_root red
set -g fish_color_command {acc_clean} --bold
set -g fish_color_keyword {acc_clean}
set -g fish_color_quote {fg_clean}
set -g fish_color_redirection {acc_clean}
set -g fish_color_end {acc_clean}
set -g fish_color_error red --bold
set -g fish_color_param {fg_clean}
set -g fish_color_comment 666666
set -g fish_color_selection --background={acc_clean}
set -g fish_color_search_match --background={acc_clean}
set -g fish_color_operator {acc_clean}
set -g fish_color_escape {acc_clean}
set -g fish_color_autosuggestion 555555
set -g fish_color_cancel --reverse
set -g fish_pager_color_prefix {acc_clean} --bold --underline
set -g fish_pager_color_progress {acc_clean}
set -g fish_pager_color_completion {fg_clean}
set -g fish_pager_color_description 777777
set -g fish_pager_color_selected_background --background={acc_clean}
"""
  with open(os.path.join(FISH_THEMES_DIR, f"{slug}.fish"), "w") as f:
    f.write(fish_script)

  # Generate Starship theme config
  dir_bg_r = int(bg_r * 0.82 + fg_r * 0.18)
  dir_bg_g = int(bg_g * 0.82 + fg_g * 0.18)
  dir_bg_b = int(bg_b * 0.82 + fg_b * 0.18)
  dir_bg_hex = f"#{dir_bg_r:02x}{dir_bg_g:02x}{dir_bg_b:02x}"

  dur_bg_r = int(bg_r * 0.88 + fg_r * 0.12)
  dur_bg_g = int(bg_g * 0.88 + fg_g * 0.12)
  dur_bg_b = int(bg_b * 0.88 + fg_b * 0.12)
  dur_bg_hex = f"#{dur_bg_r:02x}{dur_bg_g:02x}{dur_bg_b:02x}"

  acc_fg = get_contrast_fg(acc_hex)
  sec_fg = get_contrast_fg(sec_hex)

  lum_bg = 0.299 * bg_r + 0.587 * bg_g + 0.114 * bg_b
  err_hex = "#d20f39" if lum_bg > 135 else "#ff5555"

  starship_toml = f"""# Theme: {title} ({slug})
# Generated for Starship Prompt
add_newline = false
palette = "{slug}"

format = \"\"\"
[](fg:accent)\\
$os\\
[](fg:accent bg:dir_bg)\\
$directory\\
[](fg:dir_bg)\\
$git_branch\\
$cmd_duration\\
\\n$character\"\"\"

[palettes.{slug}]
accent = "{acc_hex}"
accent_fg = "{acc_fg}"
secondary = "{sec_hex}"
secondary_fg = "{sec_fg}"
dir_bg = "{dir_bg_hex}"
dir_fg = "{fg_hex}"
dur_bg = "{dur_bg_hex}"
dur_fg = "{fg_hex}"
error = "{err_hex}"

[os]
disabled = false
style = "bg:accent fg:accent_fg"
format = "[ $symbol ]($style)"

[os.symbols]
Arch = "󰣇"
Gentoo = ""
Ubuntu = "󰕈"
Debian = "󰣚"
Fedora = "󰣛"
Manjaro = ""
Linux = "󰌽"

[directory]
style = "fg:dir_fg bg:dir_bg"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
style = "fg:secondary_fg bg:secondary"
symbol = "󰘬 "
format = " [](fg:secondary)[ $symbol$branch ]($style)[](fg:secondary)"

[cmd_duration]
min_time = 500
style = "fg:dur_fg bg:dur_bg"
format = " [](fg:dur_bg)[ 󰔛 $duration ]($style)[](fg:dur_bg)"

[character]
success_symbol = "[➜](bold fg:accent) "
error_symbol = "[➜](bold fg:error) "
"""
  with open(os.path.join(STARSHIP_THEMES_DIR, f"{slug}.toml"), "w") as f:
    f.write(starship_toml)

print(f"Generated {len(THEMES)} Kitty, Fastfetch, Fish, and Starship themes successfully.")
