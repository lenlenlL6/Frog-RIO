local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local blueBird = {}

local flyingImage = love.graphics.newImage("assets/Enemies/BlueBird/Flying (32x32).png")
local hitImage = love.graphics.newImage("assets/Enemies/BlueBird/Hit (32x32).png")

local grid = anim8.newGrid(32, 32, flyingImage:getWidth(), flyingImage:getHeight())
local flyingAnimation = anim8.newAnimation(grid("1-9", 1), 0.07)
grid = anim8.newGrid(32, 32, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-5", 1), 0.07, "pauseAtEnd")

function blueBird:new(x, y, world, width, direction)
    local object = {
        animations = {
            flying = {
                image = flyingImage,
                animation = flyingAnimation:clone()
            },
            hit = {
                image = hitImage,
                animation = hitAnimation:clone()
            }
        },
        width = width,
        direction = direction,
        isDeath = false
    }
    object.currentAnimation = object.animations.flying
    object.collider = world:newRectangleCollider(x - 32, y - 32, 50, 50)
    object.collider:setType("dynamic")
    object.collider:setGravityScale(0)
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        local birdObject = col1:getObject()
        if birdObject.isDeath then return end
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end

            local _, ny = contact:getNormal()
            if ny > 0 then
                contact:setEnabled(false)
                shack:setShake(20)
                birdObject:kill()
                player.collider:setLinearVelocity(0, 0)
                player.collider:applyLinearImpulse(0, -player.jumpStrength)
                return
            end
            player:kill()
        end
    end)
    object.defaultX = x + width / 2 * direction
    object.x, object.y = object.collider:getPosition()
    self.__index = self

    return setmetatable(object, self)
end

function blueBird:update(dt)
    self.currentAnimation.animation:update(dt)

    if self.isDeath then return end

    if not self.moveFlux then
        self.moveFlux = flux.to(self, self.width / 100, {x = self.defaultX + self.width / 2 * self.direction}):ease("linear"):oncomplete(function()
            self.direction = -self.direction
            self.moveFlux = nil
        end):delay(0.5)
    end

    self.collider:setPosition(self.x, self.y)
end

function blueBird:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 32, y - 32, 0, -2 * self.direction, 2,
        (self.direction == 1) and 32 or 0)
end

function blueBird:kill()
    if self.moveFlux then self.moveFlux:stop(); self.moveFlux = nil end
    self.isDeath = true
    self.collider:setLinearVelocity(0, 0)
    self.collider:setGravityScale(1)
    self.collider:applyLinearImpulse(0, -1500)
    self.currentAnimation = self.animations.hit
    self.currentAnimation.animation:resume()
end

return blueBird
