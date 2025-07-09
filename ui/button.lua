local button = {}

function button:new(x, y, width, height, image)
    local object = {
        x = x,
        y = y,
        width = width,
        height = height,
        image = image,
        hovered = false,
        onClick = function() end
    }

    return setmetatable(object, {__index = self})
end

function button:update()
    local mx, my = love.mouse.getPosition()

    self.hovered = mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

function button:draw(customColor)
    if self.hovered then love.graphics.setColor(1, 1, 1, 0.7) end

    if customColor then love.graphics.setColor(customColor) end

    love.graphics.draw(self.image, self.x, self.y, 0, self.width/self.image:getWidth(), self.height/self.image:getHeight())
    love.graphics.setColor(1, 1, 1)
end

function button:mousepressed(x, y, button)
    if button ~= 1 then return end

    if self.hovered then self.onClick() end
end

function button:mousereleased()

end

function button:release()
    self.image:release()
end

return button