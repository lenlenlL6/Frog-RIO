local anim8 = require("libraries.anim8")
local fruit = {}

local collectedImage = love.graphics.newImage("assets/Items/Fruits/Collected.png")
local grid = anim8.newGrid(32, 32, collectedImage:getWidth(), collectedImage:getHeight())
local collectedAnimation = anim8.newAnimation(grid("1-6", 1), 0.05, "pauseAtEnd")

local appleImage = love.graphics.newImage("assets/Items/Fruits/Apple.png")
grid = anim8.newGrid(32, 32, appleImage:getWidth(), appleImage:getHeight())
local appleAnimation = anim8.newAnimation(grid("1-17", 1), 0.05)

local bananasImage = love.graphics.newImage("assets/Items/Fruits/Bananas.png")
grid = anim8.newGrid(32, 32, bananasImage:getWidth(), bananasImage:getHeight())
local bananasAnimation = anim8.newAnimation(grid("1-17", 1), 0.05)

local cherriesImage = love.graphics.newImage("assets/Items/Fruits/Cherries.png")
grid = anim8.newGrid(32, 32, cherriesImage:getWidth(), cherriesImage:getHeight())
local cherriesAnimation = anim8.newAnimation(grid("1-17", 1), 0.05)

local kiwiImage = love.graphics.newImage("assets/Items/Fruits/Kiwi.png")
grid = anim8.newGrid(32, 32, kiwiImage:getWidth(), kiwiImage:getHeight())
local kiwiAnimation = anim8.newAnimation(grid("1-17", 1), 0.05)

local melonImage = love.graphics.newImage("assets/Items/Fruits/Melon.png")
grid = anim8.newGrid(32, 32, melonImage:getWidth(), melonImage:getHeight())
local melonAnimation = anim8.newAnimation(grid("1-17", 1), 0.05)

local orangeImage = love.graphics.newImage("assets/Items/Fruits/Orange.png")
grid = anim8.newGrid(32, 32, orangeImage:getWidth(), orangeImage:getHeight())
local orangeAnimation = anim8.newAnimation(grid("1-17", 1), 0.05)

local animations = {
    ["1"] = {
        image = appleImage,
        animation = appleAnimation
    },
    ["2"] = {
        image = bananasImage,
        animation = bananasAnimation
    },
    ["3"] = {
        image = cherriesImage,
        animation = cherriesAnimation
    },
    ["4"] = {
        image = kiwiImage,
        animation = kiwiAnimation
    },
    ["5"] = {
        image = melonImage,
        animation = melonAnimation
    },
    ["6"] = {
        image = orangeImage,
        animation = orangeAnimation
    }
}

function fruit:new(x, y, options, world)
    local object = {
        id = options.id,
        x = x,
        y = y,
        score = options.score,
        currentAnimation = {
            image = animations[options.id].image,
            animation = animations[options.id].animation:clone()
        },
        collected = false
    }
    object.collider = world:newRectangleCollider(x - 16, y - 16, 32, 32)
    object.collider:setType("static")
    object.collider:setCollisionClass("fruit")
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "player" and not object.collected then
            object.collected = true
            object.currentAnimation = {
                image = collectedImage,
                animation = collectedAnimation:clone()
            }
            col2:getObject().score = col2:getObject().score + object.score
        end
    end)

    return setmetatable(object, {__index = self})
end

function fruit:update(dt)
    if self.collider:isDestroyed() then return end

    self.currentAnimation.animation:update(dt)

    if self.collected and self.currentAnimation.animation.status == "paused" then
        self.collider:destroy()
    end
end

function fruit:draw()
    if self.collider:isDestroyed() then return end

    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 32, y - 32, 0, 2, 2)
end

return fruit