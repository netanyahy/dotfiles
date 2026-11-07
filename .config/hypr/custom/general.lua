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

-- Сохранённые настройки окон и декораций (создаются через window-settings-fuzzel.sh)
if is_file_exists(HOME .. "/.config/hypr/custom/window_settings.lua") then
    dofile(HOME .. "/.config/hypr/custom/window_settings.lua")
end

