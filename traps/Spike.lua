local spike = {}

local spikeImage = love.graphics.newImage("assets/Traps/Spikes/Idle.png")
function spike:new(x, y, world)
    local object = {}
    object.collider = world:newRectangleCollider(x, y + 16, 32, 16)
    object.collider:setType("static")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end

            player:kill()
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function spike:update(dt) end

function spike:draw()
    local x, y = self.collider:getPosition()
    love.graphics.draw(spikeImage, x - 16, y - 25, 0, 2, 2)
end

return spike