-- menu.lua
-- Simple Menu UI for Space Shooter (Love2D)

local Menu = {}

local fontTitle
local fontMenu
local items -- main menu items
local selected = 1
local mousePressed = false

-- Options UI state
local inOptions = false
local musicVolume = 1.0
local sfxVolume = 1.0

local sliderActive = nil -- "music" or "sfx" when dragging

-- callbacks set by main.lua
local callbacks = {
    start = function() end,
    quit  = function() love.event.quit() end,
    back  = function() end
}

function Menu.init(cbs)
    callbacks = callbacks or {}
    if cbs then
        callbacks.start = cbs.start or callbacks.start
        callbacks.quit  = cbs.quit  or callbacks.quit
        callbacks.back  = cbs.back  or callbacks.back
    end

    fontTitle = love.graphics.newFont(36)
    fontMenu  = love.graphics.newFont(18)

    items = {
        { id = "start", label = "Start Game" },
        { id = "options", label = "Options" },
        { id = "quit", label = "Quit" },
    }

    selected = 1
    inOptions = false

    -- load saved settings if present in love.filesystem
    if love.filesystem.getInfo("ss_settings.lua") then
        local ok, chunk = pcall(love.filesystem.load, "ss_settings.lua")
        if ok and chunk then
            local data = chunk()
            if type(data) == "table" then
                musicVolume = data.musicVolume or musicVolume
                sfxVolume = data.sfxVolume or sfxVolume
            end
        end
    end
end

local function saveSettings()
    local data = string.format("return { musicVolume = %f, sfxVolume = %f }", musicVolume, sfxVolume)
    love.filesystem.write("ss_settings.lua", data)
end

local function isHover(x,y,w,h)
    local mx, my = love.mouse.getPosition()
    return mx >= x and my >= y and mx <= x + w and my <= y + h
end

function Menu.update(dt)
    -- animated background or other effects could go here (kept simple)
    -- keyboard navigation
    if love.keyboard.isDown("up") then
        -- navigate only when not in options
        if not inOptions then
            selected = selected - 1
            if selected < 1 then selected = #items end
        end
    elseif love.keyboard.isDown("down") then
        if not inOptions then
            selected = selected + 1
            if selected > #items then selected = 1 end
        end
    end

    -- mouse selection highlight handled in draw + click handling in mousepressed

    -- slider dragging
    if sliderActive then
        local mx = love.mouse.getX()
        local sliderX, sliderY = 200, 220
        if sliderActive == "music" then sliderY = 220 else sliderY = 260 end
        local w = love.graphics.getWidth() - 400
        local rel = math.max(0, math.min(1, (mx - sliderX) / w))
        if sliderActive == "music" then musicVolume = rel else sfxVolume = rel end
        love.audio.setVolume(musicVolume) -- set master volume to music for immediate feedback
    end
end

function Menu.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- background
    love.graphics.clear(0.03, 0.03, 0.06)
    -- subtle stars
    love.graphics.setColor(1,1,1,0.06)
    for i=1,80 do
        local sx = (i*47) % w
        local sy = (i*73 + love.timer.getTime()*10) % h
        love.graphics.points(sx, sy)
    end

    -- Title
    love.graphics.setFont(fontTitle)
    love.graphics.setColor(0.9, 0.9, 1)
    love.graphics.printf("SPACE SHOOTER", 0, 80, w, "center")

    if inOptions then
        -- Options panel
        love.graphics.setFont(fontMenu)
        local panelW = w - 300
        local panelH = 260
        local px = 150
        local py = 160
        -- panel background
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.rectangle("fill", px, py, panelW, panelH, 8, 8)
        -- panel title
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Options", px, py + 10, panelW, "center")

        -- Music slider
        love.graphics.setColor(0.8,0.8,0.8)
        love.graphics.print("Music Volume", px + 20, py + 60)
        local sliderX = px + 50
        local sliderY = py + 100
        local sliderW = panelW - 100
        -- slider background
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", sliderX, sliderY, sliderW, 8, 4, 4)
        -- slider fill
        love.graphics.setColor(0.25, 0.7, 1)
        love.graphics.rectangle("fill", sliderX, sliderY, sliderW * musicVolume, 8, 4, 4)
        -- knob
        love.graphics.setColor(1,1,1)
        love.graphics.circle("fill", sliderX + sliderW * musicVolume, sliderY + 4, 8)

        -- SFX slider
        love.graphics.setColor(0.8,0.8,0.8)
        love.graphics.print("SFX Volume", px + 20, py + 120)
        local sX = sliderX
        local sY = py + 160
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", sX, sY, sliderW, 8, 4, 4)
        love.graphics.setColor(1,0.6,0.3)
        love.graphics.rectangle("fill", sX, sY, sliderW * sfxVolume, 8, 4, 4)
        love.graphics.setColor(1,1,1)
        love.graphics.circle("fill", sX + sliderW * sfxVolume, sY + 4, 8)

        -- Fullscreen toggle
        local fsText = love.window.getFullscreen() and "Fullscreen: ON" or "Fullscreen: OFF"
        love.graphics.setColor(0.9,0.9,0.9)
        love.graphics.print(fsText, px + 20, py + 200)

        -- Back hint
        love.graphics.setColor(1,1,1,0.8)
        love.graphics.printf("Press ESC to go back", px, py + panelH - 28, panelW, "center")
    else
        -- Main menu items
        love.graphics.setFont(fontMenu)
        local baseY = 200
        for i, item in ipairs(items) do
            local text = item.label
            local textW = fontMenu:getWidth(text)
            local x = (w - textW) / 2
            local y = baseY + (i-1) * 48
            -- hover if mouse over
            local isHovering = isHover(x - 18, y - 8, textW + 36, 36)
            if isHovering then
                selected = i
            end
            if selected == i then
                -- highlight background
                love.graphics.setColor(0.15, 0.45, 0.9, 0.9)
                love.graphics.rectangle("fill", x - 18, y - 8, textW + 36, 36, 6, 6)
                love.graphics.setColor(1,1,1)
            else
                love.graphics.setColor(0.85,0.85,0.95)
            end
            love.graphics.print(text, x, y)
        end

        love.graphics.setColor(1,1,1,0.6)
        love.graphics.printf("Use Arrow Keys / Mouse. Enter to select.", 0, h - 60, w, "center")
    end
end

function Menu.mousepressed(x,y,button)
    if button ~= 1 then return end
    if inOptions then
        -- check slider knobs
        local w = love.graphics.getWidth()
        local panelW = w - 300
        local px = 150
        local sliderX = px + 50
        local sliderW = panelW - 100
        local musicY = 160 + 60
        local mx,my = love.mouse.getPosition()
        -- music slider area
        if mx >= sliderX and mx <= sliderX + sliderW and my >= 220 and my <= 240 then
            sliderActive = "music"
            return
        end
        -- sfx slider area
        if mx >= sliderX and mx <= sliderX + sliderW and my >= 260 and my <= 280 then
            sliderActive = "sfx"
            return
        end
        -- toggle fullscreen if clicked near text
        local fsBoxX, fsBoxY, fsBoxW, fsBoxH = px + 20, 320, 200, 24
        if mx >= fsBoxX and mx <= fsBoxX + fsBoxW and my >= fsBoxY and my <= fsBoxY + fsBoxH then
            love.window.setFullscreen(not love.window.getFullscreen())
            return
        end
    else
        -- main menu click -> trigger selected item
        local w = love.graphics.getWidth()
        local baseY = 200
        for i, item in ipairs(items) do
            local textW = fontMenu:getWidth(item.label)
            local x = (w - textW) / 2
            local y = baseY + (i-1) * 48
            if isHover(x - 18, y - 8, textW + 36, 36) then
                selected = i
                -- trigger
                local id = item.id
                if id == "start" then
                    callbacks.start()
                elseif id == "options" then
                    inOptions = true
                elseif id == "quit" then
                    callbacks.quit()
                end
                break
            end
        end
    end
end

function Menu.mousereleased(x,y,button)
    if button ~= 1 then return end
    sliderActive = nil
    saveSettings()
end

function Menu.keypressed(key)
    if inOptions then
        if key == "escape" then
            inOptions = false
            saveSettings()
            callbacks.back()
        end
        if key == "f" then
            love.window.setFullscreen(not love.window.getFullscreen())
        end
        if key == "left" then
            musicVolume = math.max(0, musicVolume - 0.05)
            love.audio.setVolume(musicVolume)
        elseif key == "right" then
            musicVolume = math.min(1, musicVolume + 0.05)
            love.audio.setVolume(musicVolume)
        end
    else
        if key == "return" or key == "kpenter" or key == "space" then
            local id = items[selected].id
            if id == "start" then
                callbacks.start()
            elseif id == "options" then
                inOptions = true
            elseif id == "quit" then
                callbacks.quit()
            end
        elseif key == "escape" then
            callbacks.quit()
        end
    end
end

return Menu