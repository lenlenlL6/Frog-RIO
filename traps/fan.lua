local function isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local anim8 = require("libraries.anim8")
local fan = {}

local offImage = love.graphics.newImage("assets/Traps/Fan/Off.png")
local grid = anim8.newGrid(24, 8, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 1, "pauseAtEnd")
local onImage = love.graphics.newImage("assets/Traps/Fan/On (24x8).png")
grid = anim8.newGrid(24, 8, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-4", 1), 0.08)

function fan:new(x, y, world)
    local object = {
        id = 2,
        world = world,
        animations = {
            off = {
                image = offImage,
                animation = offAnimation
            },
            on = {
                image = onImage,
                animation = onAnimation
            }
        }
    }
    object.currentAnimation = object.animations.on
    
    object.collider = world:newRectangleCollider(x - 24, y - 8, 48, 8)
    object.collider:setType("static")
    object.collider:setCollisionClass("platform")

    local dustImage = love.graphics.newImage("assets/Other/Dust Particle.png")
    object.pSystem = love.graphics.newParticleSystem(dustImage)
    object.pSystem:setParticleLifetime(0.7, 0.8)
    object.pSystem:setEmissionRate(6)
    object.pSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    object.pSystem:setEmissionArea("normal", 5, 2, 0, true)
    object.pSystem:setLinearAcceleration(0, -800, 0, -500)
    object.pSystem:setPosition(object.collider:getX(), object.collider:getY() - 18)
    object.pSystem:start()

    return setmetatable(object, {__index = self})
end

function fan:update(dt, player)
    self.pSystem:update(dt)

    self.currentAnimation.animation:update(dt)

    local x, y = self.collider:getPosition()
    local px, py = player.collider:getPosition()
    local vx, _ = player.collider:getLinearVelocity()
    if isPointInRect(px, py, x - 24, 0, 48, y) then
        player.onGround = false
        player.onWall = false
        player.collider:setGravityScale(0)
        player.collider:setLinearVelocity(vx, -250)
    else
        player.collider:setGravityScale(1)
    end
end

function fan:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 24, y - 8, 0, 2, 2)

    love.graphics.draw(self.pSystem)
    -- love.graphics.rectangle("line", x - 24, 0, 48, y)
end

return fan