local STI = require("sti")
require("player")
require("arrow")
love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()
    map = STI("maps/map0/0.lua", {"box2d"})
    world = love.physics.newWorld(0, 0)
    map:box2d_init(world)
    map.layers.solid.visible = false
    world:setCallbacks(beginContact, endContact)

    background = love.graphics.newImage("assets/cavebackground.jpg")
    player:load()
    arrow:load()
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    arrow:update(dt)
end

function love.draw()
    love.graphics.draw(background, 0, 0, 0, 2, 3)
    map:draw(0, 0, 2, 2)
    love.graphics.push()
    love.graphics.scale(2, 2)

    player:draw()
    arrow:draw()

    love.graphics.pop()
end


function beginContact(a, b, collision)
    player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    player:endContact(a, b, collision)
end

function love.keypressed(key)
    player:jump(key)
    player:shoot(key)
end