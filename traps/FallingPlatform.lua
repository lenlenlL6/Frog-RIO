local anim8 = require("libraries.anim8")
local fallingPlatform = {}

local offImage = love.graphics.newImage("assets/Traps/Falling Platforms/Off.png")
local onImage = love.graphics.newImage("assets/Traps/Falling Platforms/On (32x10).png")

local grid = anim8.newGrid(32, 10, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 0.1, "pauseAtEnd")
grid = anim8.newGrid(32, 10, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-4", 1), 0.1)

local dustImage = love.graphics.newImage("assets/Other/Dust Particle.png")
function fallingPlatform:new(x, y, world, delay)
    local object = {
        delay = delay,
        animations = {
            off = {
                image = offImage,
                animation = offAnimation:clone()
            },
            on = {
                image = onImage,
                animation = onAnimation:clone()
            }
        },
        onStanding = false,
        isFalling = false,
        timer = 0,
        canBeDestroy = false
    }
    object.currentAnimation = object.animations.on
    object.dustParticle = love.graphics.newParticleSystem(dustImage)
    object.dustParticle:setEmissionRate(2)
    object.dustParticle:setParticleLifetime(0.5, 0.7)
    object.dustParticle:setEmissionArea("normal", 8, 0)
    object.dustParticle:setLinearAcceleration(0, 0, 0, 400)
    object.dustParticle:setColors(1, 1, 1, 1,   1, 1, 1, 0)
    object.dustParticle:start()
    object.collider = world:newRectangleCollider(x - 32, y - 10, 64, 20)
    object.collider:setType("static")
    object.collider:setFixedRotation(true)
    object.collider:setCollisionClass("Platform")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        local platformObject = col1:getObject()
        if platformObject.isFalling then contact:setEnabled(false); return end
        local _, ny = contact:getNormal()
        if col2.collision_class == "Player" and ny > 0 then
            platformObject.onStanding = true
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function fallingPlatform:update(dt)
    if self.canBeDestroy then return end
    if self.onStanding and not self.isFalling then
        self.timer = self.timer + dt
        if self.timer >= self.delay then
            self.collider:setType("dynamic")
            self.currentAnimation = self.animations.off
            self.isFalling = true
            self.dustParticle:stop()
        end
    end
    if self.isFalling and self.collider:getY() > 620 then
        self.dustParticle:release()
        self.dustParticle = nil
        self.canBeDestroy = true
        return
    end
    self.currentAnimation.animation:update(dt)
    self.dustParticle:update(dt)
end

function fallingPlatform:draw()
    if self.canBeDestroy then return end
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 32, y - 10, 0, 2, 2)
    love.graphics.draw(self.dustParticle, x, y + 10, 0, 1.5, 1.5)
end

return fallingPlatform