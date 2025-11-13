-- menu.lua (fixed slider coordinates + audio integration)
local Audio = require "audio"

local Menu = {}

local fontTitle
local fontMenu
local items
local selected = 1

local inOptions = false
local musicVolume = Audio.getMusicVolume()
local sfxVolume = Audio.getSFXVolume()
local sliderActive = nil

local callbacks = {
    start = function() end,
    quit  = function() love.event.quit() end,
    back  = function() end
}

function Menu.init(cbs)
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
    sliderActive = nil

    -- load saved settings
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

    Audio.setMusicVolume(musicVolume)
    Audio.setSFXVolume(sfxVolume)
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
    -- keyboard nav (simple)
    if love.keyboard.isDown("up") and not inOptions then
        selected = math.max(1, selected - 1)
    elseif love.keyboard.isDown("down") and not inOptions then
        selected = math.min(#items, selected + 1)
    end

    -- handle dragging slider (use same coords as draw)
    if sliderActive then
        local w = love.graphics.getWidth()
        local panelW = w - 300
        local px = 150
        local sliderX = px + 50
        local sliderW = panelW - 100
        local mx = love.mouse.getX()
        local rel = math.max(0, math.min(1, (mx - sliderX) / sliderW))
        if sliderActive == "music" then
            musicVolume = rel
            Audio.setMusicVolume(musicVolume)
        elseif sliderActive == "sfx" then
            sfxVolume = rel
            Audio.setSFXVolume(sfxVolume)
        end
    end
end

function Menu.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- background
    love.graphics.clear(0.03, 0.03, 0.06)
    love.graphics.setColor(1,1,1,0.06)
    for i=1,80 do
        local sx = (i*47) % w
        local sy = (i*73 + love.timer.getTime()*10) % h
        love.graphics.points(sx, sy)
    end

    love.graphics.setFont(fontTitle)
    love.graphics.setColor(0.9, 0.9, 1)
    love.graphics.printf("SPACE SHOOTER", 0, 80, w, "center")

    love.graphics.setFont(fontMenu)
    if inOptions then
        local panelW = w - 300
        local panelH = 260
        local px = 150
        local py = 160
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.rectangle("fill", px, py, panelW, panelH, 8, 8)

        love.graphics.setColor(1,1,1)
        love.graphics.printf("Options", px, py + 10, panelW, "center")

        -- Music slider (positions defined relative to panel)
        love.graphics.setColor(0.8,0.8,0.8)
        love.graphics.print("Music Volume", px + 20, py + 60)
        local sliderX = px + 50
        local sliderY = py + 100
        local sliderW = panelW - 100
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", sliderX, sliderY, sliderW, 8, 4, 4)
        love.graphics.setColor(0.25, 0.7, 1)
        love.graphics.rectangle("fill", sliderX, sliderY, sliderW * musicVolume, 8, 4, 4)
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

        -- Fullscreen hint
        local fsText = love.window.getFullscreen() and "Fullscreen: ON (press F)" or "Fullscreen: OFF (press F)"
        love.graphics.setColor(0.9,0.9,0.9)
        love.graphics.print(fsText, px + 20, py + 200)

        love.graphics.setColor(1,1,1,0.8)
        love.graphics.printf("Press ESC to go back", px, py + panelH - 28, panelW, "center")
    else
        local baseY = 200
        for i, item in ipairs(items) do
            local text = item.label
            local textW = fontMenu:getWidth(text)
            local x = (w - textW) / 2
            local y = baseY + (i-1) * 48
            if isHover(x - 18, y - 8, textW + 36, 36) then selected = i end
            if selected == i then
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
        local w = love.graphics.getWidth()
        local panelW = w - 300
        local px = 150
        local py = 160
        local sliderX = px + 50
        local sliderW = panelW - 100
        local musicY = py + 100
        local sfxY = py + 160

        -- music slider click area
        if x >= sliderX and x <= sliderX + sliderW and y >= musicY - 8 and y <= musicY + 16 then
            sliderActive = "music"
            return
        end
        -- sfx slider area
        if x >= sliderX and x <= sliderX + sliderW and y >= sfxY - 8 and y <= sfxY + 16 then
            sliderActive = "sfx"
            return
        end
        -- fullscreen toggle area (simple)
        local fsBoxX, fsBoxY, fsBoxW, fsBoxH = px + 20, py + 200, 200, 24
        if x >= fsBoxX and x <= fsBoxX + fsBoxW and y >= fsBoxY and y <= fsBoxY + fsBoxH then
            love.window.setFullscreen(not love.window.getFullscreen())
            Audio.playSFX("menu")
            return
        end
    else
        local w = love.graphics.getWidth()
        local baseY = 200
        for i, item in ipairs(items) do
            local textW = fontMenu:getWidth(item.label)
            local x = (w - textW) / 2
            local y = baseY + (i-1) * 48
            if isHover(x - 18, y - 8, textW + 36, 36) then
                selected = i
                Audio.playSFX("menu")
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
            Audio.playSFX("menu")
        elseif key == "f" then
            love.window.setFullscreen(not love.window.getFullscreen())
            Audio.playSFX("menu")
        elseif key == "left" then
            musicVolume = math.max(0, musicVolume - 0.05)
            Audio.setMusicVolume(musicVolume)
        elseif key == "right" then
            musicVolume = math.min(1, musicVolume + 0.05)
            Audio.setMusicVolume(musicVolume)
        end
    else
        if key == "return" or key == "kpenter" or key == "space" then
            local id = items[selected].id
            Audio.playSFX("menu")
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