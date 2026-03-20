local anim8 = require("libraries.anim8")
local arrow = {}

local idleImage = love.graphics.newImage("assets/Traps/Arrow/Idle (18x18).png")
local hitImage = love.graphics.newImage("assets/Traps/Arrow/Hit (18x18).png")

local grid = anim8.newGrid(18, 18, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-10", 1), 0.07)
grid = anim8.newGrid(18, 18, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-4", 1), 0.07, "pauseAtEnd")
function arrow:new(x, y, world, angle, strength)
    local object = {
        x = x, y = y,
        angle = math.rad(angle),
        strength = strength,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation:clone()
            },
            hit = {
                image = hitImage,
                animation = hitAnimation:clone()
            }
        },
        active = false,
        canBeDestroy = false
    }
    object.currentAnimation = object.animations.idle
    object.collider = world:newRectangleCollider(x - 16, y - 16, 32, 32)
    object.collider:setType("static")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "Player" then
            local arrowObject = col1:getObject()
            if arrowObject.active then return end
            local player = col2:getObject()
            player.onGround = false
            player.doubleJump = false
            player.canDoubleJump = false
            player.wallJump = false
            local angle = arrowObject.angle
            arrowObject.active = true
            arrowObject.currentAnimation = arrowObject.animations.hit
            col2:setLinearVelocity(0, 0)
            col2:applyLinearImpulse(math.sin(angle) * arrowObject.strength, -math.cos(angle) * arrowObject.strength)
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function arrow:update(dt)
    if self.canBeDestroy then return end
    self.canBeDestroy = self.active and self.currentAnimation.animation.status == "paused"
    self.currentAnimation.animation:update(dt)
end

function arrow:draw()
    if self.canBeDestroy then return end
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.translate(-self.x, -self.y)
    self.currentAnimation.animation:draw(self.currentAnimation.image, self.x - 18, self.y - 18, 0, 2, 2)
    love.graphics.pop()
end

return arrow