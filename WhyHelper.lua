-- WhyHelper.lua
script_name("WhyHelper")
script_author("whyhotrt")
script_version("1.0")

require("lib.moonloader")
require("lib.sampfuncs")
local imgui = require("imgui")
local vkeys = require("vkeys")
local encoding = require("encoding")

encoding.default = "CP1251"
local u8 = encoding.UTF8

local window = imgui.ImBool(false)
local startTime = os.time()
local menuState = 1

local makeScreenshot = false
local screenshotTimer = 0

-- цвета
local col_green   = imgui.ImVec4(0.15, 0.60, 0.15, 1.00)
local col_red     = imgui.ImVec4(0.70, 0.20, 0.20, 1.00)
local col_yellow  = imgui.ImVec4(0.80, 0.70, 0.10, 1.00)
local col_purple  = imgui.ImVec4(0.50, 0.30, 0.70, 1.00)
local col_orange  = imgui.ImVec4(0.80, 0.45, 0.15, 1.00)
local col_blue    = imgui.ImVec4(0.20, 0.45, 0.70, 1.00)   -- Info
local col_darkblue= imgui.ImVec4(0.10, 0.30, 0.55, 1.00)   -- Time
local col_title   = imgui.ImVec4(0.6, 0.8, 1.0, 1.0)

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage(u8:decode("{00FF00}[WhyHelper]{FFFFFF} Загрузка хелпера прошла успешно, готов к работе!"), -1)
    sampAddChatMessage(u8:decode("{00FF00}[WhyHelper]{FFFFFF} Для открытие скрипта: /wh | Нажать по клавише F9"), -1)
    sampAddChatMessage(u8:decode("{00FF00}[WhyHelper]{FFFFFF} Версия: 1.0 | Автор: whyhotrt | TG: t.me/why_hotrt"), -1)

    sampRegisterChatCommand("wh", function()
        window.v = not window.v
        menuState = 1
    end)

    while true do
        wait(0)
        if wasKeyPressed(vkeys.VK_F9) then
            window.v = not window.v
            menuState = 1
        end
        if window.v and wasKeyPressed(vkeys.VK_ESCAPE) then
            consumeWindowMessage(true, 0x1B, 0) -- блокируем ESC для игры
            window.v = false
        end

        if makeScreenshot and (os.clock() - screenshotTimer >= 0.75) then
            setVirtualKeyDown(vkeys.VK_F8, true)
            wait(50)
            setVirtualKeyDown(vkeys.VK_F8, false)
            makeScreenshot = false
        end

        imgui.Process = window.v
    end
end

-- helper для цветных кнопок
local function ButtonColored(text, color, size)
    imgui.PushStyleColor(imgui.Col.Button, color)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(
        math.min(color.x+0.08,1), math.min(color.y+0.08,1), math.min(color.z+0.08,1), 1.0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(
        math.max(color.x-0.08,0), math.max(color.y-0.08,0), math.max(color.z-0.08,0), 1.0))
    local clicked = imgui.Button(text, size)
    imgui.PopStyleColor(3)
    return clicked
end

-- стиль
local styleInitialized = false

function imgui.OnDrawFrame()
    if not window.v then return end

    if not styleInitialized then
        local style = imgui.GetStyle()
        style.WindowRounding = 8.0
        style.FrameRounding = 5.0
        style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.10, 0.10, 0.10, 0.95)
        styleInitialized = true
    end

    local sw, sh = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(720, 460))
    imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))

    -- окно без крестика и перемещения
    imgui.Begin("WhyHelper", nil,
        bit.bor(imgui.WindowFlags.NoResize, imgui.WindowFlags.NoMove, imgui.WindowFlags.NoCollapse, imgui.WindowFlags.NoTitleBar))

    -- кастомный заголовок
    imgui.TextColored(col_title, "WhyHelper v1.0")
    imgui.Separator()

    if menuState == 1 then
        -- левая панель
        imgui.BeginChild("left_panel", imgui.ImVec2(200, 0), true)

        if ButtonColored("Дом", col_green, imgui.ImVec2(-1, 40)) then sampSendChat("/house") window.v = false end
        if ButtonColored("Business", col_red, imgui.ImVec2(-1, 40)) then sampSendChat("/bizinfo") window.v = false end
        if ButtonColored("Phone", col_yellow, imgui.ImVec2(-1, 40)) then sampSendChat("/phone") window.v = false end

        imgui.Spacing(); imgui.Separator(); imgui.Spacing()

        if ButtonColored("Info", col_blue, imgui.ImVec2(-1, 40)) then menuState = 2 end

        imgui.Spacing(); imgui.Separator(); imgui.Spacing()

        if ButtonColored("Stats", col_purple, imgui.ImVec2(-1, 40)) then sampSendChat("/stats") window.v = false end
        if ButtonColored("Piss", col_orange, imgui.ImVec2(-1, 40)) then sampSendChat("/piss") window.v = false end
        if ButtonColored("Time", col_darkblue, imgui.ImVec2(-1, 40)) then
            sampSendChat("/time")
            makeScreenshot = true
            screenshotTimer = os.clock()
            window.v = false
        end

        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        if ButtonColored("Биндер", col_title, imgui.ImVec2(-1, 30)) then menuState = 3
        end

        imgui.EndChild()

        -- правая панель
        imgui.SameLine()
        imgui.BeginChild("right_panel", imgui.ImVec2(0, 0), false)

        local title = "WhyHelper v1.0"
        imgui.SetWindowFontScale(1.3)
        local textSize = imgui.CalcTextSize(title)
        local winSize = imgui.GetWindowSize()
        imgui.SetCursorPosX((winSize.x - textSize.x) / 2)
        imgui.TextColored(col_title, title)
        imgui.SetWindowFontScale(1.1)
        imgui.Separator()

        -- команды
        imgui.TextColored(col_yellow, "Доступные команды:")
        imgui.BulletText("House  - Информация о доме")
        imgui.BulletText("Bizinfo - Информация о бизнесе")
        imgui.BulletText("Phone  - Открыть меню телефона")
        imgui.BulletText("Stats  - Показать статистику")
        imgui.BulletText("Piss   - Сделать действие 'пописать'")
        imgui.BulletText("Time   - Показать серверное время + скриншот")
        imgui.Separator()
        imgui.BulletText("F9     - Включить/Выключить это меню")
        imgui.SetWindowFontScale(1.0)

        imgui.Separator()

        -- инфа системы
        imgui.SetWindowFontScale(1.2)
        imgui.TextColored(col_green, "Системная информация:")
        imgui.Text("PC Data: " .. os.date("%d.%m.%Y"))
        imgui.Text("PC Time: " .. os.date("%H:%M:%S"))

        local elapsed = os.time() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        imgui.Separator()
        imgui.TextColored(col_orange, string.format("Время cкрипта: %02d:%02d:%02d", h, m, s))
        imgui.Separator()
        imgui.SetWindowFontScale(2.0)

        imgui.EndChild()

    elseif menuState == 2 then
        imgui.SetWindowFontScale(1.2)
        imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.0, 1.0), "Вся информация")
        imgui.SetWindowFontScale(1.0)

        imgui.TextWrapped("Обновления и тех.поддержка скрипта в нашем Telegram канале:")
        if imgui.Button("Telegram", imgui.ImVec2(100, 20)) then
            os.execute('start https://t.me/why_hotrt')
        end

        imgui.Separator()

        if imgui.Button("Назад в меню", imgui.ImVec2(200, 25)) then
            menuState = 1
        end
    elseif menuState == 3 then
        imgui.SetWindowFontScale(1.5)
        imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.0, 1.0), "В разработке")
        imgui.SetWindowFontScale(1.0)

        imgui.Separator()

        if imgui.Button("Назад в меню", imgui.ImVec2(200, 25)) then
            menuState = 1
    end
    end

    imgui.End()
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() and not quitGame then
        sampAddChatMessage(u8:decode("{FF0000}[WhyHelper]{FFFFFF} Скрипт завершился! Перезагрузите скрипт!"), -1)
        sampAddChatMessage(u8:decode("{FF0000}[WhyHelper]{FFFFFF} Нажмите по своей клавиатуре - CTRL + R"), -1)
    end
end
