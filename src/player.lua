-- player.lua
-- Player module: movement, shooting, draw, hp
local Audio = require "audio"
local Bullet = require "bullet"

local Player = {}
Player.x = 400
Player.y = 520
Player.w = 32
Player.h = 32
Player.speed = 300
Player.hp = 3
Player.shootTimer = 0
Player.shootInterval = 0.18

function Player.load()
    Player.x = love.graphics.getWidth() / 2 - Player.w/2
    Player.y = love.graphics.getHeight() - 80
    Player.hp = 3
    Player.shootTimer = Player.shootInterval
end

function Player.update(dt)
    local moveX, moveY = 0, 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then moveX = moveX - 1 end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then moveX = moveX + 1 end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then moveY = moveY + 1 end

    Player.x = Player.x + moveX * Player.speed * dt
    Player.y = Player.y + moveY * Player.speed * dt

    -- clamp
    Player.x = math.max(0, math.min(love.graphics.getWidth() - Player.w, Player.x))
    Player.y = math.max(0, math.min(love.graphics.getHeight() - Player.h, Player.y))

    Player.shootTimer = Player.shootTimer + dt
end

function Player.draw()
    love.graphics.setColor(0.2, 0.7, 1.0)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.w, Player.h, 6, 6)
    love.graphics.setColor(1,1,1,0.12)
    love.graphics.rectangle("fill", Player.x+6, Player.y+6, Player.w-12, Player.h-12, 4, 4)
    love.graphics.setColor(1,1,1)
end

function Player.shoot()
    if Player.shootTimer >= Player.shootInterval then
        Player.shootTimer = 0
        Bullet.spawn(Player.x + Player.w/2, Player.y, 0, -500, "player")
        Audio.playSFX("bullet")
    end
end

function Player:hit(damage)
    self.hp = self.hp - (damage or 1)
end

return Player