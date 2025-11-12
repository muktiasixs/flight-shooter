-- player.lua
local Player = {}
Player.x = 400
Player.y = 520
Player.w = 32
Player.h = 32
Player.speed = 300
Player.hp = 3
Player.shootTimer = 0
Player.shootInterval = 0.18 -- rate of fire

function Player.load()
    Player.x = 400 - Player.w/2
    Player.y = 520
    Player.hp = 3
    Player.shootTimer = 0
end

function Player.update(dt)
    local moveX, moveY = 0, 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then moveX = moveX - 1 end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then moveX = moveX + 1 end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then moveY = moveY + 1 end

    Player.x = Player.x + moveX * Player.speed * dt
    Player.y = Player.y + moveY * Player.speed * dt

    -- clamp to window
    Player.x = math.max(0, math.min(love.graphics.getWidth() - Player.w, Player.x))
    Player.y = math.max(0, math.min(love.graphics.getHeight() - Player.h, Player.y))

    Player.shootTimer = Player.shootTimer + dt
end

function Player.draw()
    love.graphics.setColor(0.2, 0.7, 1.0)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.w, Player.h)
    -- cockpit highlight
    love.graphics.setColor(1,1,1,0.12)
    love.graphics.rectangle("fill", Player.x+6, Player.y+6, Player.w-12, Player.h-12)
end

function Player.shoot()
    if Player.shootTimer >= Player.shootInterval then
        Player.shootTimer = 0
        local Bullet = require "bullet"
        Bullet.spawn(Player.x + Player.w/2, Player.y, 0, -500, "player")
    end
end

function Player:hit(damage)
    self.hp = self.hp - damage
end

return Player