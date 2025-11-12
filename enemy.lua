-- enemy.lua
local Enemy = {}
local Bullet = require "bullet"

Enemy.w = 34
Enemy.h = 28

function Enemy.load()
    -- nothing specific for now
end

function Enemy.create()
    local w,h = Enemy.w, Enemy.h
    local x = math.random(20, love.graphics.getWidth() - 20 - w)
    local y = -h
    local speed = 60 + math.random() * 80
    local hp = 1 + math.random(0, math.floor(math.min(4, love.timer.getTime() / 60)))
    local canShoot = math.random() < 0.4 -- some enemies shoot
    local shootCooldown = 0
    local shootInterval = 1.5 + math.random()*1.5
    local score = hp * 1
    local obj = {
        x = x,
        y = y,
        w = w,
        h = h,
        speed = speed,
        hp = hp,
        canShoot = canShoot,
        shootTimer = 0,
        shootInterval = shootInterval,
        score = score,
        update = function(self, dt)
            -- simple sine horizontal movement
            local t = love.timer.getTime()
            self.x = self.x + math.sin(t * 2 + self.y) * 20 * dt
            self.y = self.y + self.speed * dt
            if self.y > love.graphics.getHeight() + 50 then
                -- off screen, mark for removal by setting hp=0 so main will remove
                self.hp = 0
            end
        end,
        draw = function(self)
            love.graphics.setColor(0.9, 0.3, 0.6)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 4, 4)
            -- hp bar
            local bx, by, bw, bh = self.x, self.y - 6, self.w, 4
            love.graphics.setColor(0.2,0.2,0.2)
            love.graphics.rectangle("fill", bx, by, bw, bh)
            love.graphics.setColor(0.2, 1, 0.2)
            love.graphics.rectangle("fill", bx, by, bw * (self.hp / math.max(1, self.hp)), bh)
        end,
        hit = function(self, dmg)
            self.hp = self.hp - dmg
        end,
        shouldShoot = function(self, dt)
            if not self.canShoot then return false end
            self.shootTimer = self.shootTimer + dt
            if self.shootTimer >= self.shootInterval then
                self.shootTimer = 0
                return true
            end
            return false
        end
    }
    return obj
end

return Enemy