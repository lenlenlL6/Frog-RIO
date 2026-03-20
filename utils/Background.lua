local Background = {}

function Background:new(image, direction, speed)
    local imageWidth, imageHeight = image:getWidth(), image:getHeight()
    local object = {
        image = image,
        imageWidth = imageWidth, imageHeight = imageHeight,
        direction = direction,
        speed = speed,
        quad = love.graphics.newQuad(0, 0, 800 + imageWidth, 600 + imageHeight, imageWidth, imageHeight),
        x = 0, y = 0
    }
    self.__index = self

    return setmetatable(object, self)
end

function Background:update(dt)
    self.x, self.y = self.x + self.direction[1] * self.speed * dt, self.y + self.direction[2] * self.speed * dt

    if self.x < -self.imageWidth then self.x = self.x + self.imageWidth end
    if self.x > 0 then self.x = self.x - self.imageWidth end
    if self.y < -self.imageHeight then self.y = self.y + self.imageHeight end
    if self.y > 0 then self.y = self.y - self.imageHeight end
end

function Background:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y)
end

return Background