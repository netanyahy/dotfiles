#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════════╗
# ║        Hyprland • Waybar • Gentoo / Arch Linux • Fuzzel       ║
# ╚═══════════════════════════════════════════════════════════════╝

# Не используем жесткий 'set -e', чтобы мелкие ошибки не прерывали работу
set -u

# Цвета
BOLD='\033[1m'
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
DISTRO="unknown"

log()     { echo -e "  ${GREEN}✓${NC} $1"; }
info()    { echo -e "  ${CYAN}ℹ${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
error()   { echo -e "  ${RED}✗${NC} $1"; }
heading() { echo -e "\n${BOLD}${MAGENTA}─── $1 ───${NC}\n"; }

print_banner() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
  _  _                 _                 _ 
 | || |_  _ _ __  _ _| |__ _ _ _  __| |
 | __ | || | '_ \| '_| / _` | ' \/ _` |
 |_||_|\_, | .__/|_| |_\__,_|_||_\__,_|
       |__/|_|    netanyahy/dotfiles   
EOF
    echo -e "${NC}"
    echo -e "${WHITE}Окружение:${NC} Hyprland + Waybar + Kitty + Fuzzel + Wlogout"
    echo -e "${WHITE}Поддерживаемые ОС:${NC} Gentoo Linux, Arch Linux"
    echo -e "${WHITE}Репозиторий:${NC} https://github.com/netanyahy/dotfiles\n"
}

# 1. Проверка дистрибутива
check_system() {
    heading "1. Проверка системы"
    if [ -f /etc/gentoo-release ]; then
        DISTRO="gentoo"
        log "Обнаружен $(cat /etc/gentoo-release 2>/dev/null || echo 'Gentoo Linux')"
    elif [ -f /etc/arch-release ] || grep -qi "arch" /etc/os-release 2>/dev/null; then
        DISTRO="arch"
        log "Обнаружен Arch Linux"
    else
        warn "Дистрибутив не определен как Gentoo или Arch Linux."
        info "Установка пакетов через пакетный менеджер будет пропущена."
        info "Вы можете продолжить для установки конфигурационных файлов и тем."
    fi
}

# 2. Установка пакетов (Gentoo / Arch)
install_packages() {
    heading "2. Проверка и установка пакетов"
    
    if [ "$DISTRO" = "gentoo" ]; then
        install_packages_gentoo
    elif [ "$DISTRO" = "arch" ]; then
        install_packages_arch
    else
        info "Пропуск пакетного менеджера (неизвестный дистрибутив)."
    fi
}

install_packages_gentoo() {
    info "Настройка пакетного менеджера Gentoo (Portage)..."

    # 1. Автоматическое подключение hyproverlay (требуется для Hyprland, hypridle, hyprlock)
    local has_hyproverlay=false
    if [ -d /var/db/repos/hyproverlay ]; then
        has_hyproverlay=true
    elif command -v eselect >/dev/null 2>&1 && eselect repository list -i 2>/dev/null | grep -qw "hyproverlay"; then
        has_hyproverlay=true
    fi

    if [ "$has_hyproverlay" = false ]; then
        info "Автоматическое подключение оверлея hyproverlay..."
        if sudo eselect repository enable hyproverlay && sudo emaint sync -r hyproverlay; then
            log "Оверлей hyproverlay успешно подключен и синхронизирован!"
        else
            warn "Не удалось подключить оверлей hyproverlay автоматически."
            info "Выполните вручную: sudo eselect repository enable hyproverlay && sudo emaint sync -r hyproverlay"
        fi
    else
        log "Оверлей hyproverlay уже подключен."
    fi

    # 2. Автоматическое подключение GURU (требуется для fuzzel, wlogout)
    local has_guru=false
    if [ -d /var/db/repos/guru ]; then
        has_guru=true
    elif command -v eselect >/dev/null 2>&1 && eselect repository list -i 2>/dev/null | grep -qw "guru"; then
        has_guru=true
    fi

    if [ "$has_guru" = false ]; then
        info "Автоматическое подключение оверлея GURU..."
        if sudo eselect repository enable guru && sudo emaint sync -r guru; then
            log "Оверлей GURU успешно подключен и синхронизирован!"
        else
            warn "Не удалось подключить оверлей GURU автоматически."
            info "Выполните вручную: sudo eselect repository enable guru && sudo emaint sync -r guru"
        fi
    else
        log "Оверлей GURU уже подключен."
    fi

    local PKGS=(
        "gui-wm/hyprland"
        "gui-apps/waybar"
        "x11-terms/kitty"
        "gui-apps/fuzzel"
        "x11-misc/dunst"
        "gui-apps/foot"
        "gui-apps/swaybg"
        "gui-apps/wl-clipboard"
        "app-misc/cliphist"
        "media-video/pipewire"
        "media-video/wireplumber"
        "gui-apps/hypridle"
        "gui-apps/hyprlock"
        "gnome-base/gnome-keyring"
        "gui-apps/wlogout"
        "media-fonts/jetbrains-mono"
        "sys-process/btop"
        "media-sound/pavucontrol"
        "app-misc/brightnessctl"
        "gui-apps/grim"
        "gui-apps/slurp"
        "net-wireless/bluez"
        "gui-libs/gtk-layer-shell"
        "dev-python/pygobject"
        "app-portage/portage-utils"
        "app-misc/jq"
        "gui-apps/hyprshot"
        "media-sound/playerctl"
        "sys-devel/bc"
        "app-shells/fish"
    )

    local to_install=()
    echo -e "${WHITE}Статус ключевых пакетов Gentoo:${NC}"

    for pkg in "${PKGS[@]}"; do
        if command -v qlist >/dev/null 2>&1 && (qlist -I "$pkg" >/dev/null 2>&1 || qlist -I "${pkg##*/}" >/dev/null 2>&1); then
            echo -e "  ${GREEN}●${NC} $pkg (установлен)"
        else
            echo -e "  ${YELLOW}○${NC} $pkg (требуется)"
            to_install+=("$pkg")
        fi
    done

    echo ""
    if [ ${#to_install[@]} -eq 0 ]; then
        log "Все необходимые пакеты Gentoo уже установлены!"
        return 0
    fi

    echo -e "${YELLOW}Найдено отсутствующих пакетов: ${#to_install[@]}${NC}"
    read -r -p "Установить недостающие пакеты через sudo emerge? [y/N]: " ans
    if [[ "$ans" =~ ^[YyДд]$ ]]; then
        info "Запуск emerge (может потребоваться ввод пароля sudo)..."
        if sudo emerge --ask=n --noreplace "${to_install[@]}"; then
            log "Пакеты успешно установлены!"
        else
            warn "Emerge завершился с ошибкой. Проверьте USE-флаги/маскировки вручную."
        fi
    else
        info "Установка пакетов пропущена пользователем."
    fi
}

install_packages_arch() {
    info "Настройка пакетного менеджера Arch Linux (pacman)..."

    local ARCH_PKGS=(
        "hyprland"
        "waybar"
        "kitty"
        "fuzzel"
        "dunst"
        "foot"
        "swaybg"
        "wl-clipboard"
        "cliphist"
        "pipewire"
        "wireplumber"
        "pipewire-pulse"
        "hypridle"
        "hyprlock"
        "gnome-keyring"
        "ttf-jetbrains-mono-nerd"
        "btop"
        "pavucontrol"
        "brightnessctl"
        "grim"
        "slurp"
        "bluez"
        "bluez-utils"
        "gtk-layer-shell"
        "python-gobject"
        "jq"
        "playerctl"
        "bc"
        "fish"
    )

    local to_install_arch=()
    echo -e "${WHITE}Статус ключевых пакетов Arch Linux:${NC}"

    for pkg in "${ARCH_PKGS[@]}"; do
        if pacman -Qi "$pkg" >/dev/null 2>&1; then
            echo -e "  ${GREEN}●${NC} $pkg (установлен)"
        else
            echo -e "  ${YELLOW}○${NC} $pkg (требуется)"
            to_install_arch+=("$pkg")
        fi
    done

    if [ ${#to_install_arch[@]} -gt 0 ]; then
        echo -e "${YELLOW}Отсутствует пакетов pacman: ${#to_install_arch[@]}${NC}"
        read -r -p "Установить отсутствующие пакеты через sudo pacman? [Y/n]: " ans
        if [[ -z "$ans" || "$ans" =~ ^[YyДд]$ ]]; then
            sudo pacman -S --needed "${to_install_arch[@]}"
        fi
    else
        log "Все официальные пакеты Arch Linux уже установлены!"
    fi

    # Проверка AUR пакетов (wlogout, hyprshot)
    local AUR_PKGS=("wlogout" "hyprshot")
    local to_install_aur=()
    for pkg in "${AUR_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
            to_install_aur+=("$pkg")
        fi
    done

    if [ ${#to_install_aur[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}Требуются пакеты из AUR:${NC} ${to_install_aur[*]}"
        local aur_helper=""
        if command -v yay >/dev/null 2>&1; then
            aur_helper="yay"
        elif command -v paru >/dev/null 2>&1; then
            aur_helper="paru"
        fi

        if [ -n "$aur_helper" ]; then
            read -r -p "Установить AUR пакеты через $aur_helper? [Y/n]: " ans
            if [[ -z "$ans" || "$ans" =~ ^[YyДд]$ ]]; then
                $aur_helper -S --needed "${to_install_aur[@]}"
            fi
        else
            warn "AUR хелпер (yay / paru) не найден. Установите вручную: ${to_install_aur[*]}"
        fi
    fi
}

# 3. Шрифты (JetBrains Mono Nerd Font)
install_fonts() {
    heading "3. Установка шрифтов"

    if fc-list : family 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
        log "JetBrains Mono Nerd Font уже установлен в системе."
        return 0
    fi

    read -r -p "Скачать и установить JetBrains Mono Nerd Font в ~/.local/share/fonts? [Y/n]: " ans
    if [[ -z "$ans" || "$ans" =~ ^[YyДд]$ ]]; then
        local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
        mkdir -p "$font_dir"
        info "Загрузка архива шрифтов с GitHub Releases..."
        
        local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
        local tmp_archive="/tmp/JetBrainsMono-NF.tar.xz"

        if curl -sSL "$font_url" -o "$tmp_archive"; then
            tar -xf "$tmp_archive" -C "$font_dir" 2>/dev/null || true
            rm -f "$tmp_archive"
            if command -v fc-cache >/dev/null 2>&1; then
                fc-cache -fv "$font_dir" >/dev/null 2>&1 || true
            fi
            log "Шрифт JetBrains Mono Nerd Font успешно установлен!"
        else
            warn "Не удалось загрузить шрифт. Установите media-fonts/nerd-fonts вручную."
        fi
    else
        info "Установка шрифта пропущена."
    fi
}

# 4. Резервное копирование
backup_configs() {
    heading "4. Резервное копирование текущих конфигов"

    local configs=("hypr" "waybar" "kitty" "fuzzel" "dunst" "foot" "wlogout")
    local found=()

    for cfg in "${configs[@]}"; do
        if [ -e "$HOME/.config/$cfg" ]; then
            found+=("$cfg")
        fi
    done

    if [ ${#found[@]} -eq 0 ]; then
        info "Конфигураций для бэкапа не найдено (чистая система)."
        return 0
    fi

    mkdir -p "$BACKUP_DIR"
    info "Создание резервной копии в ${YELLOW}$BACKUP_DIR${NC}:"

    for cfg in "${found[@]}"; do
        cp -a "$HOME/.config/$cfg" "$BACKUP_DIR/"
        echo -e "  ${CYAN}→${NC} ~/.config/$cfg"
    done
    log "Бэкап сохранен. В случае необходимости вы можете восстановить свои файлы."
}

# 5. Установка конфигурационных файлов
install_configs() {
    heading "5. Установка dotfiles"

    mkdir -p "$HOME/.config"
    local configs=("hypr" "waybar" "kitty" "fuzzel" "dunst" "foot" "wlogout")

    for cfg in "${configs[@]}"; do
        local src="$SCRIPT_DIR/.config/$cfg"
        local dst="$HOME/.config/$cfg"

        if [ -d "$src" ]; then
            mkdir -p "$dst"
            cp -a "$src/." "$dst/"
            log "Установлен: ~/.config/$cfg"
        fi
    done

    # Делаем скрипты исполняемыми
    if [ -d "$HOME/.config/hypr" ]; then
        find "$HOME/.config/hypr" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} + 2>/dev/null || true
        log "Права на исполнение для скриптов Hyprland выданы (+x)"
    fi
    if [ -d "$HOME/.config/waybar/scripts" ]; then
        find "$HOME/.config/waybar/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
        log "Права на исполнение для скриптов Waybar выданы (+x)"
    fi
}

# 6. Обои
install_wallpapers() {
    heading "6. Установка обоев"

    local wp_src="$SCRIPT_DIR/wallpapers/default.jpg"
    local target_dir1="$HOME/Изображения/Wallpapers"
    local target_dir2="$HOME/Pictures/Wallpapers"

    mkdir -p "$target_dir1" "$target_dir2"

    if [ -f "$wp_src" ]; then
        cp -f "$wp_src" "$target_dir1/189d538e3d89f6dcbb4b430d2afb2019.jpg" 2>/dev/null || true
        cp -f "$wp_src" "$target_dir1/default.jpg" 2>/dev/null || true
        cp -f "$wp_src" "$target_dir2/189d538e3d89f6dcbb4b430d2afb2019.jpg" 2>/dev/null || true
        cp -f "$wp_src" "$target_dir2/default.jpg" 2>/dev/null || true
        log "Обои по умолчанию установлены в $target_dir1 и $target_dir2"
    else
        info "Файл обоев не найден в репозитории, проверка существующих каталогов."
    fi

    # Гарантируем наличие 189d538e3d89f6dcbb4b430d2afb2019.jpg и default.jpg в обеих директориях
    for f in "189d538e3d89f6dcbb4b430d2afb2019.jpg" "default.jpg"; do
        if [ -f "$target_dir1/$f" ] && [ ! -f "$target_dir2/$f" ]; then
            ln -sf "$target_dir1/$f" "$target_dir2/$f" 2>/dev/null || cp -f "$target_dir1/$f" "$target_dir2/$f" 2>/dev/null || true
        elif [ -f "$target_dir2/$f" ] && [ ! -f "$target_dir1/$f" ]; then
            ln -sf "$target_dir2/$f" "$target_dir1/$f" 2>/dev/null || cp -f "$target_dir2/$f" "$target_dir1/$f" 2>/dev/null || true
        fi
    done
}

# 7. Кэширование иконок
update_icon_caches() {
    heading "7. Обновление кэша иконок"

    if ! command -v gtk-update-icon-cache >/dev/null 2>&1; then
        warn "gtk-update-icon-cache не найден, пропуск кэширования иконок."
        return 0
    fi

    local updated=0
    local icon_dirs=("$HOME/.local/share/icons" "$HOME/.icons")

    for parent_dir in "${icon_dirs[@]}"; do
        if [ -d "$parent_dir" ]; then
            for dir in "$parent_dir"/*; do
                if [ -d "$dir" ] && [ -f "$dir/index.theme" ]; then
                    gtk-update-icon-cache -f -q "$dir" 2>/dev/null || true
                    log "Обновлен кэш иконок: $(basename "$dir")"
                    updated=$((updated + 1))
                fi
            done
        fi
    done

    if [ "$updated" -eq 0 ]; then
        info "Директории пользовательских иконок не найдены."
    fi
}

# 8. Финал
finish_up() {
    heading "Готово!"
    echo -e "${GREEN}${BOLD}Все компоненты успешно установлены!${NC}\n"
    echo -e "${WHITE}Что делать дальше:${NC}"
    echo -e "  1. Если вы уже в Hyprland — примените конфиг:"
    echo -e "     ${CYAN}hyprctl reload${NC}"
    echo -e "  2. Перезапустите Waybar:"
    echo -e "     ${CYAN}killall waybar; waybar &disown${NC}"
    echo -e "  3. Если вы настраиваете систему с нуля — просто запустите:"
    echo -e "     ${CYAN}Hyprland${NC}"
    echo ""
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "  ${YELLOW}Ваш бэкап сохранен здесь:${NC} $BACKUP_DIR"
    fi
    echo -e "\n${BOLD}${CYAN}Приятного использования!${NC}\n"
}

# Запуск
main() {
    print_banner
    check_system
    install_packages
    install_fonts
    backup_configs
    install_configs
    install_wallpapers
    update_icon_caches
    finish_up
}

main "$@"
