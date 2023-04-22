arrow = {};

function arrow:load()
    self.x = player.x
    self.y = player.y

    self.width = 45
    self.height = 28

    self.vel = 10

    self.image = love.graphics.newImage("assets/arrow/arrow1.png")
    
    self.offset = 50

    self.rotate = 0;
    self.rotatevel = 0.05;

    self.power = 0;
    self.maxpower = 12;

    self:loadassets()
end

function arrow:loadassets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.power = {total = 13, current = 1, img = {}}
    for i=1, self.animation.power.total do
        self.animation.power.img[i] = love.graphics.newImage("assets/arrow/arrow"..i..".png")
    end

    self.animation.draw = self.animation.power.img[1];
end

function arrow:update(dt)
    self.x = player.x
    self.y = player.y
    self:move(dt)
    self:updatepower(dt)
    self:setNewFrame()
end

function arrow:setNewFrame()
    self.animation.draw = self.animation.power.img[self.power + 1]
end

function arrow:move(dt)
    if love.keyboard.isDown("right") then
        self.rotate = self.rotate + self.rotatevel;
    elseif love.keyboard.isDown("left") then
        self.rotate = self.rotate - self.rotatevel;
    end
end

function arrow:updatepower(dt)
    if self.power < self.maxpower and love.keyboard.isDown("up") then
        self.power = self.power + 1;
    elseif self.power > 0 and love.keyboard.isDown("down") then
        self.power = self.power - 1;
    end
end

function arrow:draw()
    love.graphics.draw(self.animation.draw, self.x + (math.cos(self.rotate) * self.offset), self.y + self.height/2 + (math.sin(self.rotate) * self.offset) - player.height/2, self.rotate, 1, 1, self.width / 2, self.height / 2)
end