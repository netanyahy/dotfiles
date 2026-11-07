-- Настройка монитора внизу пример как писать если
hl.monitor({
    output = "DP-1", -- укажите порт
    mode = "2560x1440@180", --укажите разрешение вашего монитора
    position = "0x0", --позицию
    scale = 1,
})

-- настройка язык
hl.config({
    input = {
        kb_layout = "us,ru", -- меняющейсяя раскладка типо руская англиская
        kb_options = "grp:alt_shift_toggle", -- бинд на смену
    }
})

-- Сохранённые настройки окон и декораций (создаются через window-settings-fuzzel.sh)
if is_file_exists(HOME .. "/.config/hypr/custom/window_settings.lua") then
    dofile(HOME .. "/.config/hypr/custom/window_settings.lua")
end

