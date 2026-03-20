local anim8 = require("libraries.anim8")
local trampoline = {}

local idleImage = love.graphics.newImage("assets/Traps/Trampoline/Idle.png")
local jumpImage = love.graphics.newImage("assets/Traps/Trampoline/Jump (28x28).png")
local grid = anim8.newGrid(28, 28, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-1", 1), 0.1, "pauseAtEnd")
grid = anim8.newGrid(28, 28, jumpImage:getWidth(), jumpImage:getHeight())
local jumpAnimation = anim8.newAnimation(grid("1-8", 1), 0.07, "pauseAtEnd")
function trampoline:new(x, y, world, strength)
    local object = {
        strength = strength,
        active = false,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation:clone()
            },
            jump = {
                image = jumpImage,
                animation = jumpAnimation:clone()
            }
        }
    }
    object.currentAnimation = object.animations.idle
    object.collider = world:newRectangleCollider(x - 26, y - 22, 52, 22)
    object.collider:setType("static")
    object.collider:setObject(object)
    object.collider:setPostSolve(function(col1, col2, contact)
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end

            local _, ny = contact:getNormal()
            local trampolineObject = col1:getObject()
            if ny <= 0 or trampolineObject.active then return end

            trampolineObject.currentAnimation = trampolineObject.animations.jump
            trampolineObject.currentAnimation.animation:gotoFrame(1)
            trampolineObject.currentAnimation.animation:resume()
            trampolineObject.active = true
            
            player.onGround = false
            player.doubeJump = false
            player.canDoubeJump = false
            player.wallJump = false
            col2:setLinearVelocity(0, 0)
            col2:applyLinearImpulse(0, -trampolineObject.strength)
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function trampoline:update(dt)
    self.currentAnimation.animation:update(dt)
    if self.active and self.currentAnimation.animation.status == "paused" then
        self.active = false
        self.currentAnimation = self.animations.idle
    end
end

function trampoline:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 27, y - 44, 0, 2, 2)
end

return trampoline