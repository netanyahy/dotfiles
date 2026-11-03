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
| **Панель статуса** | `Waybar` | Капсульный дизайн, 10 динамических тем со стеклом и свечением |
| **Лаунчер приложений** | `Fuzzel` | Spotlight-стиль, размытие фона, буфер обмена `cliphist` |
| **Меню выключения** | `Wlogout` | Стеклянные капсулы, неоновое свечение в тон выбранной темы |
| **Терминал** | `Kitty` / `Foot` | Быстрые эмуляторы терминалов с поддержкой GPU |
| **Уведомления** | `Dunst` | Минималистичный демон уведомлений |
| **Блокировка экрана** | `Hyprlock` + `Hypridle` | Экран блокировки и демон ожидания |
| **Звук** | `Pipewire` + `Wireplumber` | Современный звуковой сервер |

---

## 🎨 Темы оформления

Переключение тем доступно в любой момент:
* Нажмите **`Super + Shift + T`**
* Либо кликните **ПКМ** по иконке Arch на панели Waybar

Доступно 10 тем (Waybar + Fuzzel + Wlogout меняются одновременно):
`Dark Glass`, `White Frost`, `Midnight Lavender`, `Neon Cyan`, `Rosé Sakura`, `Tokyo Night`, `Nord Ice`, `Cyber Emerald`, `Gruvbox Gold`, `Ruby Crimson`.

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
find ~/.config/hypr -name "*.sh" -exec chmod +x {} +
```

---

## ⌨️ Основные горячие клавиши (Keybinds)

| Комбинация | Действие |
|---|---|
| `Super` | Запуск Fuzzel (меню приложений) |
| `Super + Enter` | Запуск терминала Kitty |
| `Super + Q` | Закрыть активное окно |
| `Super + V` | Буфер обмена (Fuzzel + cliphist) |
| `Super + Shift + T` | Смена темы Waybar/Fuzzel/Wlogout |
| `Ctrl + Alt + Delete` (или клик по питанию Waybar) | Меню выключения (wlogout) |
| `Print` | Скриншот в буфер обмена |
| `Ctrl + Print` | Скриншот в файл и буфер обмена |
| `Super + 1..9` | Переключение рабочих столов |
| `Ctrl + Super + Alt + /` | Редактировать пользовательские хоткеи (`custom/keybinds.lua`) |

---

