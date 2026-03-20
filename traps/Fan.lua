local anim8 = require("libraries.anim8")
local fan = {}

local offImage = love.graphics.newImage("assets/Traps/Fan/Off.png")
local onImage = love.graphics.newImage("assets/Traps/Fan/On (24x8).png")

local grid = anim8.newGrid(24, 8, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 0.1, "pauseAtEnd")
grid = anim8.newGrid(24, 8, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-4", 1), 0.07)

local dustImage = love.graphics.newImage("assets/Other/Dust Particle.png")
function fan:new(x, y, world)
    local object = {
        animations = {
            on = {
                image = onImage,
                animation = onAnimation:clone()
            },
            off = {
                image = offImage,
                animation = offAnimation:clone()
            }
        },
        canBeDestroy = false
    }
    object.currentAnimation = object.animations.on
    object.collider = world:newRectangleCollider(x - 24, y - 16, 48, 16)
    object.collider:setType("static")
    object.collider:setObject(object)
    
    object.dustParticle = love.graphics.newParticleSystem(dustImage)
    object.dustParticle:setEmissionRate(2.5)
    object.dustParticle:setParticleLifetime(1.2, 1.4)
    object.dustParticle:setEmissionArea("normal", 5, 0)
    object.dustParticle:setLinearAcceleration(-30, -400, 30, 0)
    object.dustParticle:setColors(1, 1, 1, 1,   1, 1, 1, 0)
    object.dustParticle:start()

    local x, y = object.collider:getPosition()
    object.activeCollider = world:newRectangleCollider(x - 16, 0, 32, y - 8)
    object.activeCollider:setType("static")
    object.activeCollider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
    end)
    self.__index = self

    return setmetatable(object, self)
end

function fan:update(dt)
    if self.activeCollider:enter("Player") then
        self.player = self.activeCollider:getEnterCollisionData("Player").collider:getObject()
        self.player.onGround = false
        self.player.doubleJump = false
        self.player.canDoubleJump = false
        self.player.wallJump = false
        self.player.collider:setGravityScale(-0.5)
    end
    if self.activeCollider:exit("Player") then
        self.player.collider:setGravityScale(1)
        self.player = nil
    end
    self.currentAnimation.animation:update(dt)
    self.dustParticle:update(dt)
end

function fan:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 24, y - 8, 0, 2, 2)
    love.graphics.draw(self.dustParticle, x, y - 8, 0, 2, 2)
    -- love.graphics.rectangle("line", x - 16, 0, 32, y - 8)
end

return fan