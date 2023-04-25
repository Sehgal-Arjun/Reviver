player = {}

function player:load()

    self:loadassets()

    self.x = 10
    self.y = 500

    self.width = 20
    self.height = 32

    self.xvel = 0
    self.yvel = 100

    self.maxspeed = 135
    self.acceleration = 10000
    self.friction = 5000
    self.gravity = 1500
    
    self.jumpamount = -1 * 500;

    self.grounded = false
    self.doublejump = false;
    self.direction = "r" -- short for right

    self.state = "idle"

    self.justshot = false;

    self.shootvelocity = 50;

    self.physics = {}
    self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

    print(love.graphics.getWidth())
end

function player:loadassets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.run = {total = 6, current = 1, img = {}}
    for i=1, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/1 Pink_Monster/pinkguyrun/images/runsheet_0"..i..".png")
    end

    self.animation.idle = {total = 4, current = 1, img = {}}
    for i=1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/1 Pink_Monster/pinkguyidle/images/idlesheet_0"..i..".png")
    end

    self.animation.air = {total = 8, current = 1, img = {}}
    for i=1, self.animation.air.total do
        self.animation.air.img[i] = love.graphics.newImage("assets/1 Pink_Monster/pinkguyjump/images/jumpsheet_0"..i..".png")
    end

    self.animation.draw = self.animation.run.img[1]

    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current +1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end


function player:update(dt)
    self:syncphysics()
    self:walk(dt)
    self:applygravity(dt)
    self:animate(dt)
    self:setdirection()
    self:setstate()
    self:checksides(dt)
    self:checkposition(dt)
end

function player:checksides(dt)
    if self.x + self.xvel*dt >= love.graphics.getWidth() - 10 then -- DIVIDE BY 2 BC WE SCALED EVERTHING UP BY 2 EARLIER, SO THE MAP IS RLLY 640 PX, NOT 1280
        print("ghadh")
        self.xvel = self.xvel * -1.15
    end
    if self.x + self.xvel*dt <= 10 then
        self.xvel = self.xvel * -1.15
    end

    if self.x > love.graphics.getWidth() then
        self.x = love.graphics.getWidth() - 5
    elseif self.x < 0 then
        self.x = 5
    end
end

function player:setstate()
    if self.grounded == false then 
        self.state = "air"
    elseif self.xvel == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
end

function player:setdirection()
    if self.xvel < 0 then 
        self.direction = "l"
    elseif self.xvel > 0 then
        self.direction = "r"
    end
end

function player:walk(dt)
    if love.keyboard.isDown("d") then
        if self.xvel < self.maxspeed then
            if (self.xvel + self.acceleration * dt < self.maxspeed) then
                self.xvel = self.xvel + self.acceleration * dt
            else
                self.xvel = self.maxspeed
            end
        end
    elseif love.keyboard.isDown("a") then
        if self.xvel > -self.maxspeed then
            if (self.xvel - self.acceleration * dt > -self.maxspeed) then 
                self.xvel = self.xvel - self.acceleration * dt
            else
                self.xvel = -self.maxspeed
            end
        end
    else
        self:applyfriction(dt)
    end
end

function player:applyfriction(dt)
    if self.justshot == true then
        self.friction = 1000
    end
    if self.xvel > 0 then
        if self.xvel - self.friction * dt > 0 then
            self.xvel = self.xvel - self.friction * dt
        else
            self.xvel = 0
        end
    elseif self.xvel < 0 then
        if self.xvel + self.friction * dt < 0 then
            self.xvel = self.xvel + self.friction * dt
        else
            self.xvel = 0
        end
    end

    self.friction = 5000
end

function player:applygravity(dt)
    if self.grounded == false then
        self.yvel = self.yvel + self.gravity * dt
    end
end

function player:syncphysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xvel, self.yvel)
end

function player:beginContact(a, b, collision)
    if self.grounded then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yvel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.yvel = 0
        end
    end
end

function player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentgroundcollision == collision then
            self.grounded = false
        end
    end
    self.gravity = 1500
end

function player:land(collision)
    self.currentgroundcollision = collision
    self.yvel = 0
    self.grounded = true;
    self.justshot = false;
    self.state = "idle"
    if self.xvel > self.maxspeed then
        self.xvel = self.maxspeed
    elseif self.xvel < -self.maxspeed then
        self.xvel = -self.maxspeed
    end

end

function player:draw()
    local scalex = 1;
    if self.direction == "l" then
        scalex = -1;
    end
    --love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.draw(self.animation.draw, self.x, self.y - self.height/2, 0, scalex, 1, self.animation.width / 2, 0)
end

function player:jump(key)
    if (self.grounded) and (key == "w" or key == "space") then
        self.yvel = self.jumpamount
        self.grounded = false
    elseif self.doublejump and (key == "w" or key == "space") then
        self.doublejump = false;
        self.yvel = self.jumpamount
        self.grounded = false
    end
end

function player:shoot(key)
    if self.justshot == false and key == "e" then
        self.y = self.y - 150
        self.xvel = math.cos(arrow.rotate)*arrow.power*self.shootvelocity;
        
        print(math.sin(arrow.rotate))

        if self.grounded and math.sin(arrow.rotate) < 0 and arrow.power > 0 then
            self.yvel = math.sin(arrow.rotate)*arrow.power*self.shootvelocity;
            self.grounded = false
            self.justshot = true;
        elseif self.grounded and math.sin(arrow.rotate) > 0 and arrow.power > 0 then
            self.yvel = -1 * math.sin(arrow.rotate)*arrow.power*self.shootvelocity;
            self.justshot = true;
        elseif self.grounded == false then 
            self.yvel = math.sin(arrow.rotate)*arrow.power*self.shootvelocity;
            self.justshot = true;
        end
    end
end

function player:checkposition(dt)
    if player.y < 0 then
        map:next()
    end
    if player.y > love.graphics.getHeight() then
        map:last()
    end
end

function player:changemap(dir)
    if (dir == "newmap") then
        self.physics.body:setPosition(self.x, love.graphics.getHeight())
    elseif dir == "oldmap" then
        self.physics.body:setPosition(self.x, 0)
    end
end