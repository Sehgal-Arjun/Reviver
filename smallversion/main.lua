require("player")
require("arrow")
love.graphics.setDefaultFilter("nearest", "nearest")
require("map")
require("feather")

function love.load()
    world = love.physics.newWorld(0, 0)
    world:setCallbacks(beginContact, endContact)

    player:load()
    arrow:load()
    map:load()
end

function love.update(dt)
    world:update(dt)
    player:update(dt)
    arrow:update(dt)
    feather.updateAll(dt)
    --map:update(dt)
end

function love.draw()
    local scalebgx = 2.25;
    local scalebgy = 3;
    if (map.currentbackground == 1) then
        scalebgx = 1;
        scalebgy = 1.5;
    end
    love.graphics.draw(map.background, 0, 0, 0, scalebgx, scalebgy)
    map.level:draw(0, 0, 1, 1)
    love.graphics.push()
    love.graphics.scale(1, 1)

    player:draw()
    arrow:draw()
    feather.drawAll()

    love.graphics.pop()
end

function beginContact(a, b, collision)
    if feather.beginContact(a, b, collision) == true then return end;

    player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    player:endContact(a, b, collision)
end

function love.keypressed(key)
    player:jump(key)
    player:shoot(key)
end