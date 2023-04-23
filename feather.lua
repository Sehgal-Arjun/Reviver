require("player")

feather = {}
feather.__index = feather

activefeathers = {}

function feather.new(x, y)
    local instance = setmetatable({}, feather)
    instance.x = x
    instance.y = y
    instance.img = love.graphics.newImage("assets/undergroundassets/feather.png")
    instance.width = instance.img:getWidth() - 5
    instance.height = instance.img:getHeight() - 5
    instance.active = true;

    instance.toberemoved = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    instance.timeremoved = 0;
    table.insert(activefeathers, instance)
end

function feather:remove()
    for i, instance in ipairs(activefeathers) do
        if instance == self then
            self.physics.body:setActive(false)
            self.active = false;
            --table.remove(activefeathers, i)
        end
    end
end

function feather:update(dt)
    self:spin(dt)
    self:checkremove()
    self:reloadfeather(dt)
end

function feather:spin(dt)
    self.scalex = math.sin(love.timer.getTime()*2);
end

function feather:checkremove()
    if self.toberemoved == true then
        self:remove()
        self.toberemoved = false
    end
end

function feather:draw()
    love.graphics.draw(self.img, self.x, self.y + math.sin(love.timer.getTime()*2)*3, 0, self.scalex, 1, self.width/2, self.height/2)
end

function feather.updateAll()
    for i, instance in ipairs(activefeathers) do
        instance:update(dt)
    end
end

function feather.drawAll()
    for i, instance in ipairs(activefeathers) do
        if instance.active == true then 
            instance:draw()
        end
    end
end

function feather.beginContact(a, b, collision)
    for i, instance in ipairs(activefeathers) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == player.physics.fixture or b == player.physics.fixture then
                instance.toberemoved = true;
                player.doublejump = true;
                instance.timeremoved = love.timer.getTime();
                feather:remove()
                return true;
            end
        end
    end
end

function feather.removeAll()
    for i, v in ipairs(activefeathers) do
        v.physics.body:destroy()
    end
    activefeathers = {}
end

function feather:reloadfeather(dt)
    if not self.timeremoved == 0 then
        if math.abs(love.timer.getTime() - self.timeremoved) >= 5 then
            feather.new(self.x, self.y)
        end
    end
end