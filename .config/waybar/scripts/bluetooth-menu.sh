#!/bin/bash
# Bluetooth rofi menu for Waybar
# Manages bluetooth devices via bluetoothctl

ROFI_THEME="$HOME/.config/rofi/rofi-themes/BluetoothMenu.rasi"

# Check if bluetooth is powered
bt_power=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

if [[ "$bt_power" != "yes" ]]; then
    choice=$(echo -e "󰂯  Включить Bluetooth" | rofi -dmenu -theme "$ROFI_THEME" -p "󰂲 Bluetooth выключен")
    if [[ "$choice" == *"Включить"* ]]; then
        bluetoothctl power on
        sleep 1
    else
        exit 0
    fi
fi

build_menu() {
    local menu=""

    # Connected devices
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            mac=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | cut -d' ' -f3-)
            menu+="󰂱  $name [$mac] (подключено)\n"
        fi
    done <<< "$(bluetoothctl devices Connected 2>/dev/null)"

    # Paired but not connected devices
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            mac=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | cut -d' ' -f3-)
            # Skip if already connected
            if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
                menu+="󰂰  $name [$mac] (сопряжено)\n"
            fi
        fi
    done <<< "$(bluetoothctl devices Paired 2>/dev/null)"

    # Separator and actions
    menu+="───────────────────────\n"
    menu+="󰂰  Сканировать устройства\n"
    menu+="󰂲  Выключить Bluetooth"

    echo -e "$menu"
}

# Start scan in background for fresh devices
bluetoothctl --timeout 4 scan on &>/dev/null &
SCAN_PID=$!

choice=$(build_menu | rofi -dmenu -theme "$ROFI_THEME" -p "󰂯 Bluetooth")

# Kill background scan
kill $SCAN_PID 2>/dev/null

if [[ -z "$choice" ]]; then
    exit 0
fi

# Handle actions
case "$choice" in
    *"Выключить Bluetooth"*)
        bluetoothctl power off
        ;;
    *"Сканировать устройства"*)
        # Scan and show discovered devices
        notify-send -t 3000 "Bluetooth" "Сканирование 5 секунд..." -i bluetooth
        bluetoothctl --timeout 5 scan on &>/dev/null

        scan_menu=""
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                mac=$(echo "$line" | awk '{print $2}')
                name=$(echo "$line" | cut -d' ' -f3-)
                [[ "$name" == "$mac" ]] && continue  # Skip unnamed
                scan_menu+="󰂱  $name [$mac]\n"
            fi
        done <<< "$(bluetoothctl devices 2>/dev/null)"

        if [[ -z "$scan_menu" ]]; then
            notify-send -t 3000 "Bluetooth" "Устройства не найдены" -i bluetooth
            exit 0
        fi

        scan_choice=$(echo -e "$scan_menu" | rofi -dmenu -theme "$ROFI_THEME" -p "󰂰 Найденные")

        if [[ -n "$scan_choice" ]]; then
            mac=$(echo "$scan_choice" | grep -oP '\[.*?\]' | tr -d '[]')
            name=$(echo "$scan_choice" | sed 's/^[^ ]* *//' | sed 's/ \[.*//')
            notify-send -t 3000 "Bluetooth" "Подключение к $name..." -i bluetooth
            bluetoothctl pair "$mac" 2>/dev/null
            sleep 1
            bluetoothctl trust "$mac" 2>/dev/null
            bluetoothctl connect "$mac" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                notify-send -t 3000 "Bluetooth" "Подключено: $name" -i bluetooth
            else
                notify-send -t 3000 "Bluetooth" "Не удалось подключить $name" -i bluetooth
            fi
        fi
        ;;
    *"(подключено)"*)
        # Disconnect device
        mac=$(echo "$choice" | grep -oP '\[.*?\]' | tr -d '[]')
        name=$(echo "$choice" | sed 's/^[^ ]* *//' | sed 's/ \[.*//')

        action=$(echo -e "󰂲  Отключить\n  Забыть устройство" | rofi -dmenu -theme "$ROFI_THEME" -p "󰂱 $name")

        case "$action" in
            *"Отключить"*)
                bluetoothctl disconnect "$mac"
                notify-send -t 3000 "Bluetooth" "Отключено: $name" -i bluetooth
                ;;
            *"Забыть"*)
                bluetoothctl disconnect "$mac" 2>/dev/null
                bluetoothctl remove "$mac"
                notify-send -t 3000 "Bluetooth" "Удалено: $name" -i bluetooth
                ;;
        esac
        ;;
    *"(сопряжено)"*)
        # Connect to paired device
        mac=$(echo "$choice" | grep -oP '\[.*?\]' | tr -d '[]')
        name=$(echo "$choice" | sed 's/^[^ ]* *//' | sed 's/ \[.*//')
        notify-send -t 3000 "Bluetooth" "Подключение к $name..." -i bluetooth
        bluetoothctl connect "$mac"
        if [[ $? -eq 0 ]]; then
            notify-send -t 3000 "Bluetooth" "Подключено: $name" -i bluetooth
        else
            notify-send -t 3000 "Bluetooth" "Не удалось подключить $name" -i bluetooth
        fi
        ;;
esac
