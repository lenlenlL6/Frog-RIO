local anim8 = require("libraries.anim8")
local fallingPlatform = {}

local offImage = love.graphics.newImage("assets/Traps/Falling Platforms/Off.png")
local grid = anim8.newGrid(32, 10, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 1, "pauseAtEnd")
local onImage = love.graphics.newImage("assets/Traps/Falling Platforms/On (32x10).png")
grid = anim8.newGrid(32, 10, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-4", 1), 0.08)

function fallingPlatform:new(x, y, world)
    local object = {
        id = 1,
        animations = {
            off = {
                image = offImage,
                animation = offAnimation
            },
            on = {
                image = onImage,
                animation = onAnimation
            }
        },
        standing = false,
        fallTimer = 0.4,
        fall = false,
        speed = 500
    }
    object.currentAnimation = object.animations.on

    object.collider = world:newRectangleCollider(x - 32, y - 10, 32*2, 10*2)
    object.collider:setType("static")
    object.collider:setCollisionClass("fallingPlatform")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        if col2.collision_class ~= "player" then
            contact:setEnabled(false)
        end
    end)

    local dustImage = love.graphics.newImage("assets/Other/Dust Particle.png")
    object.pSystem = love.graphics.newParticleSystem(dustImage)
    object.pSystem:setParticleLifetime(0.7, 0.8)
    object.pSystem:setEmissionRate(6)
    object.pSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    object.pSystem:setEmissionArea("normal", 5, 2, 0, true)
    object.pSystem:setLinearAcceleration(0, 500, 0, 800)
    object.pSystem:setPosition(object.collider:getX(), object.collider:getY() + 10)
    object.pSystem:start()

    return setmetatable(object, {__index = self})
end

function fallingPlatform:update(dt)
    if self.collider:isDestroyed() then
        return
    end
    self.pSystem:update(dt)
    self.currentAnimation.animation:update(dt)

    if self.standing then
        self.fallTimer = self.fallTimer - dt
        if self.fallTimer <= 0 then
            self.fall = true
            self.currentAnimation = self.animations.off
            self.pSystem:pause()
        end
    end

    if self.fall then
        self.collider:setY(self.collider:getY() + self.speed * dt)
        if self.collider:getY() > love.graphics.getHeight() then
            self.collider:destroy()
            self.pSystem:release()
        end
    end
end

function fallingPlatform:draw()
    if self.collider:isDestroyed() then
        return
    end

    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 32, y - 10, 0, 2, 2)

    love.graphics.draw(self.pSystem)
end

return fallingPlatform