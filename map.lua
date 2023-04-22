map = {};

local STI = require("sti")
require("player")
require("arrow")

function map:load()
    self.currentlevel = 0
    self.currentbackground = 0

    self:init()
end

function map:init()
    self.level = STI("maps/map"..self.currentlevel.."/"..self.currentlevel..".lua", {"box2d"})
    self.level:box2d_init(world)
    self.level.layers.solid.visible = false
    self:pickbg()
    self.background = love.graphics.newImage("assets/background"..self.currentbackground..".png")
end

function map:pickbg()
    self.currentbackground = math.floor(self.currentlevel/5)
end

function map:next()
    self:clean()
    self.currentlevel = self.currentlevel + 1
    self:init()
    player:changemap("newmap")
end

function map:last()
    self:clean()
    self.currentlevel = self.currentlevel - 1
    self:init()
    player:changemap("oldmap")
end


function map:clean()
    self.level:box2d_removeLayer("solid")
end