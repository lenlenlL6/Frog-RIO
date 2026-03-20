local anim8 = require("libraries.anim8")
local fruit = {}

local appleImage = love.graphics.newImage("assets/Items/Fruits/Apple.png")
local bananasImage = love.graphics.newImage("assets/Items/Fruits/Bananas.png")
local cherriesImage = love.graphics.newImage("assets/Items/Fruits/Cherries.png")
local kiwiImage = love.graphics.newImage("assets/Items/Fruits/Kiwi.png")
local melonImage = love.graphics.newImage("assets/Items/Fruits/Melon.png")
local orangeImage = love.graphics.newImage("assets/Items/Fruits/Orange.png")
local pineappleImage = love.graphics.newImage("assets/Items/Fruits/Pineapple.png")
local strawBerryImage = love.graphics.newImage("assets/Items/Fruits/Strawberry.png")
local collectedImage = love.graphics.newImage("assets/Items/Fruits/Collected.png")

local grid = anim8.newGrid(32, 32, appleImage:getWidth(), appleImage:getHeight())
local appleAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)
local bananasAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)
local cherriesAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)
local kiwiAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)
local melonAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)
local orangeAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)
local pineappleAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)
local strawBerryAnimation = anim8.newAnimation(grid("1-17", 1), 0.07)

grid = anim8.newGrid(32, 32, collectedImage:getWidth(), collectedImage:getHeight())
local collectedAnimation = anim8.newAnimation(grid("1-6", 1), 0.07, "pauseAtEnd")

local fruits = {
    {
        image = appleImage,
        animation = appleAnimation
    },
    {
        image = bananasImage,
        animation = bananasAnimation
    },
    {
        image = cherriesImage,
        animation = cherriesAnimation
    },
    {
        image = kiwiImage,
        animation = kiwiAnimation
    },
    {
        image = melonImage,
        animation = melonAnimation
    },
    {
        image = orangeImage,
        animation = orangeAnimation
    },
    {
        image = pineappleImage,
        animation = pineappleAnimation
    },
    {
        image = strawBerryImage,
        animation = strawBerryAnimation
    }
}

function fruit:new(id, x, y, world, points)
    local object = {
        points = points,
        animations = {
            idle = {
                image = fruits[id].image,
                animation = fruits[id].animation:clone()
            },
            collected = {
                image = collectedImage,
                animation = collectedAnimation:clone()
            }
        },
        canBeDestroy = false
    }
    object.currentAnimation = object.animations.idle
    object.collider = world:newRectangleCollider(x - 16, y - 16, 32, 32)
    object.collider:setType("static")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end

            local fruitObject = col1:getObject()
            if fruitObject.currentAnimation == fruitObject.animations.collected then return end
            player.points = player.points + fruitObject.points
            fruitObject.currentAnimation = fruitObject.animations.collected
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function fruit:update(dt)
    self.currentAnimation.animation:update(dt)

    if self.currentAnimation.animation.status == "paused" then self.canBeDestroy = true end
end

function fruit:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 32, y - 32, 0, 2, 2)
end

return fruit