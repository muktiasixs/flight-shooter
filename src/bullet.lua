-- bullet.lua
-- Bullet manager: spawn, update, draw bullets
local Bullet = {}
Bullet.list = {}
Bullet.w = 6
Bullet.h = 12

function Bullet.load()
    Bullet.list = {}
end

-- spawn at (x,y) with vx,vy and owner ("player" or "enemy")
function Bullet.spawn(x, y, vx, vy, from)
    table.insert(Bullet.list, {
        x = x - Bullet.w/2,
        y = y - Bullet.h/2,
        vx = vx or 0,
        vy = vy or -400,
        w = Bullet.w,
        h = Bullet.h,
        from = from or "player",
        damage = 1,
    })
end

function Bullet.update(dt)
    for i = #Bullet.list, 1, -1 do
        local b = Bullet.list[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        -- remove off-screen
        if b.y < -50 or b.y > love.graphics.getHeight() + 50 or b.x < -50 or b.x > love.graphics.getWidth() + 50 then
            table.remove(Bullet.list, i)
        end
    end
end

function Bullet.draw()
    for _, b in ipairs(Bullet.list) do
        if b.from == "player" then
            love.graphics.setColor(1, 0.9, 0.2)
        else
            love.graphics.setColor(1, 0.3, 0.3)
        end
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
    end
    love.graphics.setColor(1,1,1)
end

return Bullet