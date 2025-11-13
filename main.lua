

-- ensure require finds modules under src/
package.path = package.path .. ";src/?.lua"

local Audio  = require "audio"
local Player = require "player"
local Bullet = require "bullet"
local Enemy  = require "enemy"
local Menu   = require "menu"

local enemies = {}
local enemySpawnTimer = 0
local enemySpawnInterval = 1.5
local score = 0
local gameState = "menu" -- "menu", "playing", "gameover"
local font

local function startGame()
    Player.load()
    Bullet.load()
    Enemy.load()
    enemies = {}
    enemySpawnTimer = 0
    enemySpawnInterval = 1.5
    score = 0
    gameState = "playing"
    Audio.playMusic("theme_song")
end

function love.load()
    love.window.setTitle("Space Shooter - Simple Love2D")
    love.window.setMode(800, 600)
    font = love.graphics.newFont(14)
    love.graphics.setFont(font)

    -- init menu callbacks
    Menu.init({
        start = function() startGame() end,
        quit  = function() love.event.quit() end,
        back  = function() end
    })

    gameState = "menu"


end

function love.update(dt)
    if gameState == "playing" then
        Player.update(dt)
        Bullet.update(dt)

        -- update enemies & collisions
        for i = #enemies, 1, -1 do
            local e = enemies[i]
            e:update(dt)

            -- collision: player bullet -> enemy
            for j = #Bullet.list, 1, -1 do
                local b = Bullet.list[j]
                if b.from == "player" and checkCollision(b.x, b.y, b.w, b.h, e.x, e.y, e.w, e.h) then
                    table.remove(Bullet.list, j)
                    e:hit(b.damage)
                    if e.hp <= 0 then
                        score = score + (e.score or 1)
                        Audio.playSFX("enemy") -- enemy death
                        table.remove(enemies, i)
                    end
                    break
                end
            end

            -- collision: enemy collides with player
            if checkCollision(e.x, e.y, e.w, e.h, Player.x, Player.y, Player.w, Player.h) then
                Player:hit(1)
                Audio.playSFX("player")
                table.remove(enemies, i)
            end
        end

        -- spawn enemies
        enemySpawnTimer = enemySpawnTimer + dt
        if enemySpawnTimer >= enemySpawnInterval then
            enemySpawnTimer = 0
            table.insert(enemies, Enemy.create())
            enemySpawnInterval = math.max(0.5, 1.5 - math.floor(score/10) * 0.1)
        end

        -- enemy shooting
        for _, e in ipairs(enemies) do
            if e.canShoot and e:shouldShoot(dt) then
                local bx, by = e.x + e.w/2, e.y + e.h
                Bullet.spawn(bx, by, 0, 250, "enemy")
                Audio.playSFX("bullet")
            end
        end

        -- enemy bullets hit player
        for i = #Bullet.list, 1, -1 do
            local b = Bullet.list[i]
            if b.from == "enemy" and checkCollision(b.x, b.y, b.w, b.h, Player.x, Player.y, Player.w, Player.h) then
                Player:hit(1)
                Audio.playSFX("player")
                table.remove(Bullet.list, i)
            end
        end

        if Player.hp <= 0 then
            gameState = "gameover"
        end
    elseif gameState == "menu" then
        Menu.update(dt)
    elseif gameState == "gameover" then
    end
end

function love.draw()
    if gameState == "menu" then
        Menu.draw()
        return
    end

    love.graphics.clear(0.05, 0.05, 0.1)
    love.graphics.setColor(1,1,1)
    Player.draw()
    Bullet.draw()
    for _, e in ipairs(enemies) do e:draw() end

    -- UI
    love.graphics.setColor(1,1,1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("HP: " .. Player.hp, 10, 30)

    if gameState == "gameover" then
        love.graphics.setColor(1,0.3,0.3)
        love.graphics.printf("GAME OVER\nPress R to restart\nPress ESC to return to Menu", 0, love.graphics.getHeight()/2 - 40, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        Menu.keypressed(key)
        return
    end

    if key == "space" and gameState == "playing" then
        Player.shoot()
    elseif key == "r" and gameState == "gameover" then
        startGame()
    elseif key == "escape" then
        if gameState == "playing" or gameState == "gameover" then
            -- switch to menu and pause music
            gameState = "menu"
            Audio.pauseMusic()
        end
    end
end

function love.mousepressed(x,y,button)
    if gameState == "menu" then Menu.mousepressed(x,y,button) end
end

function love.mousereleased(x,y,button)
    if gameState == "menu" then Menu.mousereleased(x,y,button) end
end

-- Simple AABB collision
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end