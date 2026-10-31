#!/bin/bash

# Форсируем режим производительности Nvidia (если карта Nvidia)
nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" &

# Пример: запуск мессенджера или утилиты в фоне (значок '&' обязателен, чтобы скрипт не завис)
# telegram-desktop --minimized &
