-- Настройка монитора (180 Гц)
hl.monitor({
    output = "DP-1",
    mode = "2560x1440@180",
    position = "0x0",
    scale = 1,
})

-- Основные настройки
hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
    }
    
})

