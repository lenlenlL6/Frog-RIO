local Transition = {}

local transitionImage = love.graphics.newImage("assets/Other/Transition.png")
function Transition:new(speed)
    local object = {
        speed = speed,
        scale = 0,
        active = true,
        onComplete = function() end
    }
    self.__index = self

    return setmetatable(object, self)
end

function Transition:update(dt)
    if not self.active then return end

    self.scale = self.scale + self.speed * dt
    if self.scale >= 7 then
        self.active = false
        self.scale = 7
        self.onComplete()
    end
    if self.scale <= 0 then
        self.active = false
        self.scale = 0
        self.onComplete()
    end
end

function Transition:draw()
    for i = 0, 5 do
        for s = 0, 7 do
            local x, y = s * 120, i * 120
            love.graphics.push()
            love.graphics.translate(x, y)
            love.graphics.scale(self.scale, self.scale)
            love.graphics.translate(-x, -y)
            love.graphics.draw(transitionImage, x - transitionImage:getWidth() / 2, y - transitionImage:getHeight() / 2)
            love.graphics.pop()
        end
    end
end

return Transition