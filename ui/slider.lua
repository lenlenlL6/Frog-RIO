local slider = {}

function slider:new(x, y, width, height, image, sliderWidth, sliderHeight)
    local object = {
        x = x,
        y = y,
        width = width,
        height = height,
        image = image,
        sliderWidth = sliderWidth,
        sliderHeight = sliderHeight,
        sliderActive = false,
        sliderRead = false,
        buttonHovered = false,
        sliderHovered = false,
        value = y - sliderHeight
    }

    return setmetatable(object, {__index = self})
end

function slider:update(dt)
    local mx, my = love.mouse.getPosition()

    self.buttonHovered = mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
    self.sliderHovered = mx >= self.x and mx <= self.x + self.width and my >= self.y - 10 - self.sliderHeight and my <= self.y - 10

    if self.sliderRead then
        self.value = my
        if self.value > self.y - 20 then
            self.value = self.y - 20
        end

        if self.value < self.y - self.sliderHeight then
            self.value = self.y - self.sliderHeight
        end
    end
end

function slider:draw()
    if self.buttonHovered then love.graphics.setColor(1, 1, 1, 0.7) end

    love.graphics.draw(self.image, self.x, self.y, 0, self.width/self.image:getWidth(), self.height/self.image:getHeight())
    love.graphics.setColor(1, 1, 1)

    if not self.sliderActive then return end
    if self.sliderHovered then love.graphics.setColor(1, 1, 1, 0.7) end

    love.graphics.rectangle("fill", self.x, self.y - 10 - self.sliderHeight, self.sliderWidth, self.sliderHeight, 5)
    love.graphics.setColor(0.18, 0.18, 0.18)
    love.graphics.rectangle("fill", self.x + 10, self.value, self.sliderWidth - 20, self.y - 20 - self.value, (self.value == self.y - 20) and 0 or 5)
    love.graphics.setColor(1, 1, 1)
end

function slider:mousepressed(x, y, button)
    if button ~= 1 then return end

    if self.buttonHovered then
        self.sliderActive = not self.sliderActive
    end

    if self.sliderHovered then
        if self.sliderActive then
            self.sliderRead = true
        end
    end
end

function slider:mousereleased()
    self.sliderRead = false
end

function slider:release()
    self.image:release()
end

return slider