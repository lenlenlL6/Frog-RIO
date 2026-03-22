local pi = math.pi
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt
local function distance(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local flux = require("libraries.flux")
local spikedBall = {}

local chainImage = love.graphics.newImage("assets/Traps/Spiked Ball/Chain.png")
local spikedBallImage = love.graphics.newImage("assets/Traps/Spiked Ball/Spiked Ball.png")
function spikedBall:new(x, y, world, radius, range, delay, direction)
    local object = {
        radius = math.rad(radius),
        range = math.rad(range),
        delay = delay,
        direction = direction,
        batch = love.graphics.newSpriteBatch(chainImage)
    }
    object.angle = pi / 2 - object.range / 2 * object.direction
    for i = 1, math.ceil(math.deg(object.radius) / 16) do
        object.ballX, object.ballY = x + 16 * (i - 1), y
        object.batch:add(object.ballX - 8, object.ballY - 8, 0, 2, 2)
    end
    object.direction = -object.direction
    object.defaultX, object.defaultY = x, y
    object.collider = world:newCircleCollider(object.ballX, object.ballY, 28)
    object.collider:setType("kinematic")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end

            player:kill()
        end
    end)
    object.ballDistance = distance(x, y, object.ballX, object.ballY)
    self.__index = self

    return setmetatable(object, self)
end

function spikedBall:update(dt)
    if not self.rotationFlux then
        self.rotationFlux = flux.to(self, self.delay, { angle = pi / 2 - self.range / 2 * self.direction }):ease(
        "linear"):oncomplete(function()
            self.direction = -self.direction
            self.rotationFlux = nil
        end)
    end

    self.collider:setPosition(self.defaultX + cos(self.angle) * self.ballDistance, self.defaultY + sin(self.angle) * self.ballDistance)
end

function spikedBall:draw()
    love.graphics.push()
    love.graphics.translate(self.defaultX, self.defaultY)
    love.graphics.rotate(self.angle)
    love.graphics.translate(-self.defaultX, -self.defaultY)
    love.graphics.draw(self.batch)
    love.graphics.draw(spikedBallImage, self.ballX - 28, self.ballY - 28, 0, 2, 2)
    love.graphics.pop()
end

return spikedBall
