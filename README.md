# 🌌 dotfiles




My personal **Hyprland** configuration for **Gentoo Linux** and **Arch Linux**. 


**Photo**:
<img width="2559" height="1439" alt="image" src="https://github.com/user-attachments/assets/fa49343c-39fe-48dc-9c05-0f650a95baea" /> <img width="2559" height="1439" alt="image" src="https://github.com/user-attachments/assets/a6b7ce63-a08b-4d76-b777-78603927b402" />




![Gentoo](https://img.shields.io/badge/OS-Gentoo_Linux-purple?logo=gentoo&logoColor=white)
![Arch](https://img.shields.io/badge/OS-Arch_Linux-blue?logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-blue?logo=wayland&logoColor=white)
![Waybar](https://img.shields.io/badge/Bar-Waybar-teal?logo=wayland&logoColor=white)
![Themes](https://img.shields.io/badge/Themes-30_Palettes-orange)
![Styles](https://img.shields.io/badge/Bar_Styles-19_Layouts-violet)
![Shell](https://img.shields.io/badge/Shell-Bash-green?logo=gnu-bash&logoColor=white)

[**English**](#-dotfiles) | [**Русский**](#-dotfiles-на-русском)

---

## 📸 Stack & Components

| Component | Tool | Description |
|---|---|---|
| **Window Manager** | `Hyprland` | Smooth dynamic Wayland tiling powered by Lua/Hyprlang |
| **Status Bar** | `Waybar` | 19 top-bar styles + 39 dynamic color themes with glassmorphism & neon glows |
| **App Launcher** | `Fuzzel` | Spotlight-style centered launcher, zero latency, `cliphist` clipboard integration |
| **Power Menu** | `Wlogout` | Glass capsules with neon hover glow matching the active theme |
| **Terminal** | `Kitty` / `Foot` | Lightning-fast GPU-accelerated terminal emulators |
| **Notifications** | `Dunst` | Lightweight, minimalist notification daemon |
| **Lock Screen** | `Hyprlock` + `Hypridle` | Secure lock screen with auto-dim and idle management |
| **Wallpapers** | `swaybg` + `mpvpaper` + `wallpaper-picker.py` | GTK3 + Layer Shell visual thumbnail gallery with video/animation support (`.mp4`, `.webm`, `.mkv`, `.mov`, `.gif`) and static images |
| **Audio** | `Pipewire` + `Wireplumber` | Modern Wayland audio stack with low latency |

---

## 🎨 Color Themes (30 Modular Themes)

Switch themes seamlessly at any moment:
* Press **`Super + Shift + T`**
* Or **Right-Click** the Gentoo logo on the Waybar

All **30 themes** sync instantly across Waybar, Fuzzel, and Wlogout:

### 🌟 Base Themes (10)
- `Dark Glass` — Dark frosted glass
- `White Frost` — Crisp clean light theme
- `Midnight Lavender` — Midnight purple & lavender
- `Neon Cyan` — High-tech electric cyan
- `Rosé Sakura` — Delicate Rosé Pine sakura
- `Tokyo Night` — Neon Tokyo cyber vibe
- `Nord Ice` — Arctic pastel coolness
- `Cyber Emerald` — Emerald cyberpunk matrix
- `Gruvbox Gold` — Warm retro Gruvbox
- `Ruby Crimson` — Deep crimson ruby

### 🎨 Designer Themes (20)
- **Catppuccin Palette**: `Catppuccin Mocha`, `Catppuccin Macchiato`, `Catppuccin Frappé`, `Catppuccin Latte`
- **Iconic Legends**: `Dracula Vampire`, `Solarized Dark`, `Solarized Light`, `One Dark Pro`, `Monokai Pro`
- **Gruvbox Editions**: `Gruvbox Dark`, `Gruvbox Light`
- **Nature & Japanese Aesthetics**: `Everforest`, `Kanagawa Wave`, `Ocean Abyss`
- **Cyberpunk & Synthwave**: `Synthwave '84`, `Cyberpunk 2077`, `Aura Dark`, `Carbon Mint`
- **Atmospheric**: `Sunset Twilight`, `Blood Moon`

---

## 🪄 Waybar Styles (19 Top-Bar Layouts)

The status bar is permanently positioned at the top (`position: top`), and its visual geometry can be swapped on the fly between 19 unixporn layout styles:

* Switch layout shortcut: **`Super + Shift + B`**

### Available Styles:
1. 💊 **Floating Capsules** — Classic floating pills with 12px rounded borders and subtle outline.
2. 🧊 **Unified Glass Bar** — Monolithic translucent glass strip spanning the top edge with rounded corners.
3. 🏝️ **Three Islands** — Three distinct floating islands: Left (Arch + Clock), Center (Workspaces), Right (System status + Power).
4. ✨ **Minimalist Underline** — Ultra-clean borderless bar with text shadows; active workspace accented with an underline strip.
5. ⚡ **Cyberpunk Sharp** — Strict rectangular blocks (`border-radius: 0px`) with sharp neon borders and retro-tech aesthetics.
6. ● **Dot Matrix** — Minimalist circular dots (10px) that expand into an oval capsule (24px) for the active workspace.
7. 🌈 **Gradient Border** — High-contrast neon borders around every widget with soft glowing aura.
8. 📐 **Pill Compact** — Dense, low-profile design (`font-size: 13px`, `padding: 3px 8px`) maximizing usable screen real estate.
9. 📟 **Powerline Chevrons** — Iconic terminal powerline ribbon: seamless connected segments with divider borders.
10. ❄️ **Nordic Frost** — Frosted matte finish, generous 20px pill radiuses and soft arctic shadows.
11. 🫧 **Bubble Float** — Playful 24px bubble capsules with airy spacing.
12. 🎀 **Ribbon Top** — Seamless top ribbon flush with the upper display edge (`margin-top: 0`) and 16px bottom rounded corners.
13. 💻 **Bracket Tech** — Cyberpunk HUD layout with transparent background and accent brackets (`border-left` & `border-right`).
14. 🔳 **Double Border** — Dual neon outlines (`border: 3px double @accent-color`) giving modules a distinct retro-futuristic depth.
15. 💫 **Glowing Strip** — Continuous neon glow line across the entire bottom edge of the bar.
16. ⏰ **Center Clock Focus** — Clock placed in the spotlight as the dominant center widget with an intense glow pill.
17. 🛸 **Cyber HUD** — Futuristic sci-fi HUD with top/bottom accent rails and bracketed modules.
18. 💊 **Frosted Glass Pills** — Separated translucent floating pills with clean border outlines.
19. 📟 **Retro Terminal** — Boxed high-contrast monospaced classic terminal aesthetic.

> [!TIP]
> All 39 color themes are 100% compatible with each of the 19 bar styles! Mix and match any color palette (`Super + Shift + T`) with any layout (`Super + Shift + B`).

---

## 🖼️ Wallpaper Management & Video Wallpapers

Integrated with both a GUI thumbnail gallery and a lightning-fast Fuzzel selector:
* **`Super + Shift + W`** (or **Middle-Click** the Arch logo on Waybar) — Launches the GTK3 + Layer Shell visual thumbnail gallery with frosted glass background, theme-matching border, keyboard navigation (arrows, Enter, Esc), mouse clicks, and a «🎲 Random Wallpaper» button.
* **`Super + Alt + W`** — Fast dmenu wallpaper selector via `Fuzzel`.
* **Universal Format Support**: Works with static images (`.jpg`, `.jpeg`, `.png`, `.webp`) and animated/video wallpapers (`.mp4`, `.webm`, `.mkv`, `.mov`, `.gif`).
* For video wallpapers, `ffmpeg` automatically extracts and caches preview thumbnails, cards are labeled with `🎬 `, and playback runs via the hardware-accelerated `mpvpaper` engine (or `swaybg` for static images).
* Wallpaper selections are saved to `~/.config/hypr/current_wallpaper` and restored automatically upon login via `apply_wallpaper.sh`.

---

## 🚀 Automated Installation

Clone the repository and run the automated installer:

```bash
git clone https://github.com/netanyahy/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

### What `install.sh` does:
1. 🔍 **Detects distribution** (Gentoo Linux with GURU & hyproverlay, Arch Linux with pacman & AUR helpers).
2. 📦 **Verifies and installs dependencies** (`hyprland`, `waybar`, `fuzzel`, `swaybg`, `mpvpaper`, `ffmpeg`, `gtk-layer-shell`, `jetbrains-mono`, etc.).
3. 💾 **Creates a full backup** of your existing configs in `~/.config-backup-<timestamp>`.
4. 📂 **Deploys dotfiles** into `~/.config/` with executable script permissions.
5. 🖼️ **Sets up wallpapers** in `~/Pictures/Wallpapers/` and `~/Изображения/Wallpapers/`.

---

## 🛠️ Manual Installation

If you prefer to copy the configurations manually:

```bash
git clone https://github.com/netanyahy/dotfiles.git
cd dotfiles

# Backup existing configs
mkdir -p ~/.config-backup
cp -r ~/.config/{hypr,waybar,kitty,fuzzel,dunst,foot,wlogout} ~/.config-backup/ 2>/dev/null

# Copy configs
cp -rf .config/* ~/.config/

# Setup default wallpaper
mkdir -p ~/Pictures/Wallpapers ~/Изображения/Wallpapers
cp wallpapers/default.jpg ~/Pictures/Wallpapers/default.jpg
cp wallpapers/default.jpg ~/Изображения/Wallpapers/189d538e3d89f6dcbb4b430d2afb2019.jpg

# Set executable permissions
find ~/.config/hypr ~/.config/waybar -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
```

---

## ⌨️ Keybindings

| Keybinding | Action |
|---|---|
| `Super` | App Launcher (Fuzzel) |
| `Super + Enter` | Terminal (Kitty) |
| `Super + Q` | Close active window |
| `Super + V` | Clipboard manager (Fuzzel + cliphist) |
| `Super + Shift + T` | Theme switcher (or Right-Click Arch icon) |
| `Super + Shift + B` | Bar style switcher (19 top-bar layouts) |
| `Super + Shift + D` | Window settings & decorations menu (Fuzzel) |
| `Super + Shift + G` | Window gaps & geometry menu (Fuzzel) |
| `Super + Alt + C` | Cursor theme switcher (69 cursor packs) |
| `Super + Shift + W` | Wallpaper gallery picker (or Middle-Click Arch icon) |
| `Super + Alt + W` | Quick wallpaper selector (Fuzzel) |
| `Ctrl + Alt + Delete` | Power menu (Wlogout, or click power button on Waybar) |
| `Print` | Screenshot to clipboard |
| `Ctrl + Print` | Screenshot to file and clipboard |
| `Super + 1..9` | Switch workspace |
| `Ctrl + Super + Alt + /` | Edit custom keybindings (`custom/keybinds.lua`) |

---
---

# 🌌 dotfiles (на русском)

Моя персональная конфигурация **Hyprland** для **Gentoo Linux** и **Arch Linux**

[**English**](#-dotfiles) | [**Русский**](#-dotfiles-на-русском)

---

## 📸 Стек и компоненты

| Компонент | Утилита | Описание |
|---|---|---|
| **Оконный менеджер** | `Hyprland` | Динамический тайлинг Wayland на Lua/Hyprlang |
| **Панель статуса** | `Waybar` | 19 стилей панели (всегда сверху) + 39 динамических тем со стеклом и свечением |
| **Лаунчер приложений** | `Fuzzel` | Spotlight-стиль, размытие фона, буфер обмена `cliphist` |
| **Меню выключения** | `Wlogout` | Стеклянные капсулы, неоновое свечение в тон выбранной темы |
| **Терминал** | `Kitty` / `Foot` | Быстрые эмуляторы терминалов с поддержкой GPU |
| **Уведомления** | `Dunst` | Минималистичный демон уведомлений |
| **Блокировка экрана** | `Hyprlock` + `Hypridle` | Экран блокировки и демон ожидания |
| **Обои** | `swaybg` + `mpvpaper` + `wallpaper-picker.py` | Галерея обоев на GTK3 + Layer Shell со стеклянным фоном, миниатюрами и поддержкой как фото, так и любых анимированных/видео обоев (`.mp4`, `.webm`, `.mkv`, `.mov`, `.gif`) |
| **Звук** | `Pipewire` + `Wireplumber` | Современный звуковой сервер |

---

## 🎨 Темы оформления (39 тем)

Переключение тем доступно в любой момент:
* Нажмите **`Super + Shift + T`**
* Либо кликните **ПКМ** по иконке Arch на панели Waybar

Всего доступно **39 тем** (Waybar + Fuzzel + Wlogout меняются одновременно):

### 🌟 Базовые темы (10)
- `Dark Glass` — тёмное стекло
- `White Frost` — морозная светлая тема
- `Midnight Lavender` — полуночная лаванда
- `Neon Cyan` — неоновый кибер-циан
- `Rosé Sakura` — нежная сакура Rosé Pine
- `Tokyo Night` — неоновый Токио
- `Nord Ice` — северный лёд
- `Cyber Emerald` — изумрудный киберпанк
- `Gruvbox Gold` — тёплый Gruvbox
- `Ruby Crimson` — рубиновый кармин

### 🎨 Дизайнерские темы (20)
- **Catppuccin**: `Catppuccin Mocha`, `Catppuccin Macchiato`, `Catppuccin Frappé`, `Catppuccin Latte`
- **Классические культовые палитры**: `Dracula Vampire`, `Solarized Dark`, `Solarized Light`, `One Dark Pro`, `Monokai Pro`
- **Gruvbox серия**: `Gruvbox Dark`, `Gruvbox Light`
- **Природные и японские эстетики**: `Everforest`, `Kanagawa Wave`, `Ocean Abyss`
- **Киберпанк и футуризм**: `Synthwave '84`, `Cyberpunk 2077`, `Aura Dark`, `Carbon Mint`
- **Глубокие атмосферные**: `Sunset Twilight`, `Blood Moon`

---

## 🪄 Стили оформления Waybar (Всегда сверху)

Панель статуса всегда зафиксирована в верхней части экрана (`position: top`), а её визуальный дизайн можно мгновенно переключать между 16 популярными unixporn-стилями:

* Хоткей переключения: **`Super + Shift + B`**

### Доступные стили:
1. 💊 **Floating Capsules** (Раздельные капсулы) — классический стиль: отдельные парящие стеклянные капсулы-пилюли с закруглениями 12px и тонкими рамками.
2. 🧊 **Unified Glass Bar** (Монолитная полоса) — сплошная стеклянная лента во всю ширину экрана с элегантными закругленными краями, модули объединены внутри единой панели без отдельных рамок.
3. 🏝️ **Three Islands** (Три парящих острова) — модули сгруппированы в ровно три парящих острова: левый (Arch + часы), центральный (воркспейсы) и правый (звук + BT + память + CPU + выключение) с радиусом скругления 16px.
4. ✨ **Minimalist Underline** (Минимализм с полоской) — ультрачистый прозрачный стиль без рамок и плашек, парящий текст с тенями, активный рабочий стол подчёркнут неоновой полоской (`border-bottom: 3px solid @accent-color`).
5. ⚡ **Cyberpunk Sharp** (Квадратные блоки) — строгая геометрия с прямыми углами (`border-radius: 0px`), контрастные неоновые рамки цвета акцента и терминальный ретрофутуризм.
6. ● **Dot Matrix** (Индикаторные точки) — минималистичные круглые точки-индикаторы рабочих столов (10px), активный стол плавно растягивается в овальную капсулу 24px в стиле Dynamic Island.
7. 🌈 **Gradient Border** (Неоновые рамки) — яркий неоновый контур (`border: 2px solid @accent-color`) вокруг каждого модуля с переливающимся ореолом мягкого свечения (`box-shadow: 0 0 12px @ws-glow`).
8. 📐 **Pill Compact** (Ультра-компакт) — плотный низкопрофильный дизайн с уменьшенными отступами (`font-size: 13px`, `padding: 3px 8px`), максимизирующий полезное экранное пространство.
9. 📟 **Powerline Chevrons** (Терминал блочный) — культовый терминальный powerline-стиль: модули плотно прилегают друг к другу без пробелов, образуя монолитную информационную ленту.
10. ❄️ **Nordic Frost** (Арктический матовый) — глубокий матовый фрост-эффект, крупные овальные пилюли со скруглением 20px и мягкими ледяными тенями.
11. 🫧 **Bubble Float** (Парящие пузыри) — выразительные парящие пузыри с радиусом скругления 24px, круглые капсулы воркспейсов и воздушная эстетика.
12. 🎀 **Ribbon Top** (Прижатая верхняя лента) — монолитная лента, вплотную прижатая к верхнему краю экрана (`margin-top: 0`), с элегантно закругленными нижними углами 16px.
13. 💻 **Bracket Tech** (Хакерские скобки) — киберпанковский HUD-стиль: прозрачный фон и технологичные акцентные скобки по бокам модулей (`border-left` и `border-right: 2px solid @accent-color`).
14. 🔳 **Double Border** (Двойной контур) — двойной неоновый контур (`border: 3px double @accent-color`), придающий модулям глубину и футуристичный ретро-вид.
15. 💫 **Glowing Strip** (Светящаяся полоса) — сплошная неоновая светящаяся полоса вдоль нижней границы всей панели (`border-bottom: 2px solid @accent-color; box-shadow: 0 4px 20px @ws-glow`).
16. ⏰ **Center Clock Focus** (Акцентные часы) — часы выделены как главный акцентный виджет в центре панели с крупной контрастной пилюлей и интенсивным неоновым ореолом.
17. 🛸 **Cyber HUD** (Футуристичный интерфейс) — верхние и нижние 2px рельсы, хакерские боковые скобки модулей и четкая окантовка.
18. 💊 **Frosted Glass Pills** (Матовые пилюли) — раздельные парящие пилюли со стеклянным фоном и аккуратной окантовкой.
19. 📟 **Retro Terminal** (Классический терминал) — моноширинный строгий терминальный вид с прямоугольными рамками.

> [!TIP]
> Все 30 цветовых тем полностью совместимы с каждым из 19 стилей оформления! Вы можете комбинировать любую цветовую палитру (`Super + Shift + T`) с любым стилем панели (`Super + Shift + B`).

---

## 🖼️ Выбор и управление обоями

В конфигурацию интегрирован графический селектор обоев и быстрый dmenu-селектор:
* **`Super + Shift + W`** (или **СКМ** по иконке Arch на панели Waybar) — запуск элегантной GUI-галереи миниатюр на GTK3 + Layer Shell с полупрозрачным стеклянным фоном, рамкой в тон текущей темы, навигацией клавишами (стрелки, Enter, Esc), мышью и кнопкой «🎲 Случайные обои».
* **`Super + Alt + W`** — быстрый текстовый селектор обоев через меню `Fuzzel`.
* **Поддержка любых форматов**: как статичных изображений (`.jpg`, `.jpeg`, `.png`, `.webp`), так и любых видео и анимаций (`.mp4`, `.webm`, `.mkv`, `.mov`, `.gif`).
* Для видео-обоев автоматически генерируются превью-кадры через `ffmpeg`, карточки помечаются иконкой `🎬 `, а воспроизведение осуществляется через аппаратный движок `mpvpaper` (для статичных изображений — `swaybg`).
* При выборе обоев путь автоматически сохраняется в `~/.config/hypr/current_wallpaper`, перезапускается фоновый плеер (`mpvpaper` или `swaybg`) и выводится системное уведомление.
* При старте Hyprland скрипт `apply_wallpaper.sh` автоматически восстанавливает выбранные обои (статичные или анимированные).

---

## 🚀 Автоматическая установка

Склонируйте репозиторий и запустите скрипт `install.sh`:

```bash
git clone https://github.com/netanyahy/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

### Что делает скрипт:
1. 🔍 **Проверяет систему** (Gentoo Linux или Arch Linux).
2. 📦 **Проверяет зависимости** и предлагает установить недостающие пакеты через `emerge` или `pacman` / AUR.
3. 🔤 **Устанавливает шрифты** `JetBrains Mono Nerd Font` (при необходимости загружает с GitHub).
4. 💾 **Делает резервную копию** всех существующих конфигов в `~/.config-backup-<дата>`.
5. 📂 **Устанавливает конфиги** в `~/.config/` и настраивает права исполнения на скрипты.
6. 🖼️ **Устанавливает фоновые обои** в директории `~/Изображения/Wallpapers/` и `~/Pictures/Wallpapers/`.

---

## 🛠️ Ручная установка (без скрипта)

Если вы хотите установить только конфиги вручную:

```bash
git clone https://github.com/netanyahy/dotfiles.git
cd dotfiles

# Создание бэкапа
mkdir -p ~/.config-backup
cp -r ~/.config/{hypr,waybar,kitty,fuzzel,dunst,foot,wlogout} ~/.config-backup/ 2>/dev/null

# Копирование конфигов
cp -rf .config/* ~/.config/

# Установка обоев
mkdir -p ~/Изображения/Wallpapers ~/Pictures/Wallpapers
cp wallpapers/default.jpg ~/Изображения/Wallpapers/189d538e3d89f6dcbb4b430d2afb2019.jpg
cp wallpapers/default.jpg ~/Pictures/Wallpapers/default.jpg

# Права на скрипты
find ~/.config/hypr ~/.config/waybar -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
```

---

## ⌨️ Основные горячие клавиши (Keybinds)

| Комбинация | Действие |
|---|---|
| `Super` | Запуск Fuzzel (меню приложений) |
| `Super + Enter` | Запуск терминала Kitty |
| `Super + Q` | Закрыть активное окно |
| `Super + V` | Буфер обмена (Fuzzel + cliphist) |
| `Super + Shift + T` | Смена темы Waybar/Fuzzel/Wlogout (или ПКМ по логотипу Arch) |
| `Super + Shift + B` | Смена стиля Waybar (19 стилей верхней панели) |
| `Super + Shift + D` | Меню настроек окон и декораций (Fuzzel) |
| `Super + Shift + G` | Меню отступов и геометрии окон (Fuzzel) |
| `Super + Alt + C` | Смена темы курсора (69 наборов курсоров) |
| `Super + Shift + W` | Выбор обоев — графическая галерея миниатюр (или СКМ по логотипу Arch) |
| `Super + Alt + W` | Быстрый выбор обоев через Fuzzel |
| `Ctrl + Alt + Delete` (или клик по питанию Waybar) | Меню выключения (wlogout) |
| `Print` | Скриншот в буфер обмена |
| `Ctrl + Print` | Скриншот в файл и буфер обмена |
| `Super + 1..9` | Переключение рабочих столов |
| `Ctrl + Super + Alt + /` | Редактировать пользовательские хоткеи (`custom/keybinds.lua`) |
