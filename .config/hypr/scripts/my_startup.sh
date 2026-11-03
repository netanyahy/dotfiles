#!/bin/bash

# Форсируем режим производительности Nvidia (если карта Nvidia и утилита установлена)
if command -v nvidia-settings >/dev/null 2>&1; then
    nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" &
fi

# Пример: запуск мессенджера или утилиты в фоне (значок '&' обязателен, чтобы скрипт не завис)
# telegram-desktop --minimized &
