hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )
hl.bind("SUPER+return", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER+w", hl.dsp.exec_cmd('google-chrome-stable'))
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/cursor-fuzzel.sh"), { description = "Cursor: Select with fuzzel" })
hl.bind("SUPER + ALT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/terminal-settings-fuzzel.sh"), { description = "Terminal Settings: Fuzzel Menu" })
hl.bind("SUPER + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-settings-fuzzel.sh"), { description = "Window Settings: Fuzzel Menu" })
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-settings-fuzzel.sh"), { description = "Window Settings: Fuzzel Menu" })
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/window-settings-fuzzel.sh"), { description = "Window Settings & Gaps: Fuzzel Menu" })
hl.bind("SUPER+P", hl.dsp.exec_cmd('vscode'))

-- Окно по центру экрана при переключении в плавающий режим (Win + Alt + Space)
hl.unbind("SUPER + ALT + Space")
hl.bind("SUPER + ALT + Space", function()
    local win = hl.get_active_window()
    if not win then return end

    if not win.floating then
        local mon = hl.get_active_workspace().monitor
        local target_w = math.floor(mon.width * 0.48)
        local target_h = math.floor(mon.height * 0.48)

        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, "exact" }))
        hl.dispatch(hl.dsp.window.center())
    else
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    end
end, { description = "Window: Float centered / Tile" })
