
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- Включаем прозрачность и размытие для VS Code (включая Antigravity)
hl.window_rule({ match = { class = "^(code)$" }, opacity = "0.88 0.88", no_blur = false })

-- Включаем прозрачность и размытие для отдельного приложения Antigravity
hl.window_rule({ match = { class = "^([Aa]ntigravity)$" }, opacity = "0.88 0.88", no_blur = false })
