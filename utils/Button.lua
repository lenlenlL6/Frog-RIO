local Button = {}

function Button:new(x, y, width, height)
    local object = {
        x = x, y = y,
        width = width, height = height,
        active = true,
        isHovered = false,
        isPressed = false, pressesPosition = {},
        onClick = function(button) end,
        style = function(button) love.graphics.rectangle("line", button.x, button.y, button.width, button.height) end
    }
    self.__index = self

    return setmetatable(object, self)
end

function Button:update()
    if not self.active then return end
    local mx, my = love.mouse.getPosition()
    self.isHovered = mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

function Button:draw()
    if not self.active then return end
    self.style(self)
end

function Button:mousepressed(x, y, button)
    if not self.active then return end
    if button ~= 1 then return end

    self.isPressed = self.isHovered
    self.pressesPosition[1], self.pressesPosition[2] = x, y
end

function Button:mousereleased(x, y)
    if not self.active then return end
    if self.pressesPosition[1] ~= x or self.pressesPosition[2] ~= y then return end
    if self.isPressed then self.onClick(self); self.isPressed = false end
end

return Button