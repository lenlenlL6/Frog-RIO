local anim8 = require("libraries.anim8")
local fire = {}

local offImage = love.graphics.newImage("assets/Traps/Fire/Off.png")
local onImage =love.graphics.newImage("assets/Traps/Fire/On (16x32).png")

local grid = anim8.newGrid(16, 32, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 0.1, "pauseAtEnd")
grid = anim8.newGrid(16, 32, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-3", 1), 0.1)
function fire:new(x, y, world, delay)
    local object = {
        timer = 0,
        delay = delay,
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
        contact = false,
        isFire = true,
        canBeDestroy = false
    }
    object.currentAnimation = object.animations.on
    object.collider = world:newRectangleCollider(x, y - 32, 32, 32)
    object.collider:setType("static")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
    end)
    self.__index = self

    return setmetatable(object, self)
end

function fire:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.delay then
        self.timer = self.timer - self.delay
        self.currentAnimation = self.isFire and self.animations.off or self.animations.on
        self.isFire = not self.isFire
    end
    if self.collider:enter("Player") then
        self.contact = true
        self.player = self.collider:getEnterCollisionData("Player").collider:getObject()
    end
    if self.collider:exit("Player") then
        self.contact = false
        self.player = nil
    end
    if self.contact and self.isFire and not self.player.isDeath then
        self.player:kill()
    end
    self.currentAnimation.animation:update(dt)
end

function fire:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 16, y - 16, 0, 2, 2)
end

return fire