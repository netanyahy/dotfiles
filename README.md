# 🌌 dotfiles

Моя персональная конфигурация **Hyprland** на **Gentoo Linux**

![Gentoo](https://img.shields.io/badge/OS-Gentoo_Linux-purple?logo=gentoo&logoColor=white)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-blue?logo=wayland&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-green?logo=gnu-bash&logoColor=white)

---

## 📸 Стек и компоненты

| Компонент | Утилита | Описание |
|-----------|---------|----------|
| **Оконный менеджер** | `Hyprland` | Динамический тайлинг Wayland на Lua/Hyprlang (база end-4) |
| **Панель статуса** | `Waybar` | Капсульный дизайн, анимированные воркспейсы со свечением |
| **Терминал** | `Kitty` / `Foot` | Быстрый эмулятор терминала с поддержкой GPU |
| **Лаунчер приложений** | `Rofi-Wayland` / `Fuzzel` | Меню приложений, выбор стилей, селектор обоев |
| **Уведомления** | `Dunst` | Минималистичный демон уведомлений |
| **Блокировка экрана** | `Hyprlock` + `Hypridle` | Экран блокировки со стилями matugen |
| **Звук** | `Pipewire` + `Wireplumber` | Современный звуковой сервер |

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
cp -r ~/.config/{hypr,waybar,kitty,rofi,fuzzel,dunst,foot} ~/.config-backup/ 2>/dev/null

# Копирование конфигов
cp -rf .config/* ~/.config/

# Установка обоев
mkdir -p ~/Изображения/Wallpapers
cp wallpapers/default.jpg ~/Изображения/Wallpapers/189d538e3d89f6dcbb4b430d2afb2019.jpg

# Права на скрипты
find ~/.config/hypr -name "*.sh" -exec chmod +x {} +
```

---

## ⌨️ Основные горячие клавиши (Keybinds)

- `Super + Enter` — Запуск терминала Kitty
- `Super + D` / `Super + Space` — Меню приложений (Rofi / Fuzzel)
- `Super + Q` / `Super + C` — Закрыть активное окно
- `Super + M` — Выход / Меню питания (wlogout)
- `Ctrl + Super + Alt + /` — Редактировать пользовательские хоткеи (`custom/keybinds.lua`)
- `Super + 1..9` — Переключение рабочих столов (с анимацией Waybar)

---

