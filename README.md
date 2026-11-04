# 🌌 dotfiles

Моя персональная конфигурация **Hyprland** для **Gentoo Linux** и **Arch Linux**

![Gentoo](https://img.shields.io/badge/OS-Gentoo_Linux-purple?logo=gentoo&logoColor=white)
![Arch](https://img.shields.io/badge/OS-Arch_Linux-blue?logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-blue?logo=wayland&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-green?logo=gnu-bash&logoColor=white)

---

## 📸 Стек и компоненты

| Компонент | Утилита | Описание |
|---|---|---|
| **Оконный менеджер** | `Hyprland` | Динамический тайлинг Wayland на Lua/Hyprlang |
| **Панель статуса** | `Waybar` | 6 стилей панели (всегда сверху) + 30 динамических тем со стеклом и свечением |
| **Лаунчер приложений** | `Fuzzel` | Spotlight-стиль, размытие фона, буфер обмена `cliphist` |
| **Меню выключения** | `Wlogout` | Стеклянные капсулы, неоновое свечение в тон выбранной темы |
| **Терминал** | `Kitty` / `Foot` | Быстрые эмуляторы терминалов с поддержкой GPU |
| **Уведомления** | `Dunst` | Минималистичный демон уведомлений |
| **Блокировка экрана** | `Hyprlock` + `Hypridle` | Экран блокировки и демон ожидания |
| **Обои** | `swaybg` + `wallpaper-picker.py` | Галерея обоев на GTK3 + Layer Shell со стеклянным фоном, миниатюрами и быстрой сменой |
| **Звук** | `Pipewire` + `Wireplumber` | Современный звуковой сервер |

---

## 🎨 Темы оформления

Переключение тем доступно в любой момент:
* Нажмите **`Super + Shift + T`**
* Либо кликните **ПКМ** по иконке Arch на панели Waybar

Всего доступно **30 тем** (Waybar + Fuzzel + Wlogout меняются одновременно):

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

Панель статуса всегда зафиксирована в верхней части экрана (`position: top`), а её визуальный дизайн можно мгновенно переключать между 6 популярными unixporn-стилями:

* Хоткей переключения: **`Super + Shift + B`**

### Доступные стили:
1. 💊 **Floating Capsules** (Раздельные капсулы) — классический стиль: отдельные парящие стеклянные капсулы-пилюли с закруглениями 12px и тонкими рамками.
2. 🧊 **Unified Glass Bar** (Монолитная полоса) — сплошная стеклянная лента во всю ширину экрана с элегантными закругленными краями, модули объединены внутри единой панели без отдельных рамок.
3. 🏝️ **Three Islands** (Три парящих острова) — модули сгруппированы в ровно три парящих острова: левый (Arch + часы), центральный (воркспейсы) и правый (звук + BT + память + CPU + выключение) с радиусом скругления 16px.
4. ✨ **Minimalist Underline** (Минимализм с полоской) — ультрачистый прозрачный стиль без рамок и плашек, парящий текст с тенями, активный рабочий стол подчёркнут неоновой полоской (`border-bottom: 3px solid @accent-color`).
5. ⚡ **Cyberpunk Sharp** (Квадратные блоки) — строгая геометрия с прямыми углами (`border-radius: 0px`), контрастные неоновые рамки цвета акцента и терминальный ретрофутуризм.
6. ● **Dot Matrix** (Индикаторные точки) — минималистичные круглые точки-индикаторы рабочих столов (10px), активный стол плавно растягивается в овальную капсулу 24px в стиле Dynamic Island.

> [!TIP]
> Все 30 цветовых тем полностью совместимы с каждым из 6 стилей оформления! Вы можете комбинировать любую цветовую палитру (`Super + Shift + T`) с любым стилем панели (`Super + Shift + B`).

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
1. 🔍 **Проверяет систему** (Gentoo Linux или другие дистрибутивы).
2. 📦 **Проверяет зависимости** и предлагает установить недостающие пакеты через `emerge`.
3. 🔤 **Устанавливает шрифты** `JetBrains Mono Nerd Font` (при необходимости загружает с GitHub).
4. 💾 **Делает резервную копию** всех существующих конфигов в `~/.config-backup-<дата>`.
5. 📂 **Устанавливает конфиги** в `~/.config/` и настраивает права исполнения на скрипты.
6. 🖼️ **Устанавливает фоновые обои** в директорию `~/Изображения/Wallpapers/`.

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
find ~/.config/hypr -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
```

---

## 🖼️ Выбор и управление обоями

В конфигурацию интегрирован графический селектор обоев и быстрый dmenu-селектор:
* **`Super + Shift + W`** (или **СКМ** по иконке Arch на панели Waybar) — запуск элегантной GUI-галереи миниатюр на GTK3 + Layer Shell с полупрозрачным стеклянным фоном, рамкой в тон текущей темы, навигацией клавишами (стрелки, Enter, Esc), мышью и кнопкой «🎲 Случайные обои».
* **`Super + Alt + W`** — быстрый текстовый селектор обоев через меню `Fuzzel`.
* При выборе обоев путь автоматически сохраняется в `~/.config/hypr/current_wallpaper`, перезапускается демон `swaybg` и выводится системное уведомление.
* При старте Hyprland скрипт `apply_wallpaper.sh` автоматически восстанавливает выбранные обои.

---

## ⌨️ Основные горячие клавиши (Keybinds)

| Комбинация | Действие |
|---|---|
| `Super` | Запуск Fuzzel (меню приложений) |
| `Super + Enter` | Запуск терминала Kitty |
| `Super + Q` | Закрыть активное окно |
| `Super + V` | Буфер обмена (Fuzzel + cliphist) |
| `Super + Shift + T` | Смена темы Waybar/Fuzzel/Wlogout (или ПКМ по логотипу Arch) |
| `Super + Shift + B` | Смена стиля Waybar (6 стилей верхней панели) |
| `Super + Shift + W` | Выбор обоев — графическая галерея миниатюр (или СКМ по логотипу Arch) |
| `Super + Alt + W` | Быстрый выбор обоев через Fuzzel |
| `Ctrl + Alt + Delete` (или клик по питанию Waybar) | Меню выключения (wlogout) |
| `Print` | Скриншот в буфер обмена |
| `Ctrl + Print` | Скриншот в файл и буфер обмена |
| `Super + 1..9` | Переключение рабочих столов |
| `Ctrl + Super + Alt + /` | Редактировать пользовательские хоткеи (`custom/keybinds.lua`) |

---

