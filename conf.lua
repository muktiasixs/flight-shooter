-- conf.lua
-- Love2D configuration

function love.conf(t)
    t.window.title = "Space Shooter"
    t.window.width = 800
    t.window.height = 600
    t.window.vsync = 1
    t.identity = "space_shooter" 
    t.console = false
end