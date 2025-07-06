local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local saw = {}

local chainImage = love.graphics.newImage("assets/Traps/Saw/Chain.png")
local offImage = love.graphics.newImage("assets/Traps/Saw/Off.png")
local grid = anim8.newGrid(38, 38, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 1, "pauseAtEnd")
local onImage = love.graphics.newImage("assets/Traps/Saw/On (38x38).png")
grid = anim8.newGrid(38, 38, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-8", 1), 0.06)

function saw:new(points, world)
    local object = {
        points = points,
        batch = love.graphics.newSpriteBatch(chainImage),
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
        targetDirection = 1,
        targetPoint = 2,
        targetReady = true
    }
    object.currentAnimation = object.animations.on

    object.collider = world:newRectangleCollider(points[1].x*2 - 38, points[1].y*2 - 40 - 38, 38*2, 38*2)
    object.collider:setCollisionClass("saw")
    object.collider:setType("static")
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "player" then
            col2:getObject():kill()
        end
    end)
    object.currentPosition = {x = object.collider:getX(), y = object.collider:getY()}

    for _, v in pairs(points) do
        object.batch:add(v.x*2 - 8, v.y*2 - 40 - 8, 0, 2, 2)
    end
    return setmetatable(object, {__index = self})
end

function saw:update(dt)
    if self.targetReady then
        self.targetReady = false

        flux.to(self.currentPosition, 1, {x = self.points[self.targetPoint].x*2, y = self.points[self.targetPoint].y*2 - 40}):ease("linear"):oncomplete(function()
            self.targetPoint = self.targetPoint + 1*self.targetDirection
            if self.targetPoint == 1 or self.targetPoint == #self.points then
                self.targetDirection = -self.targetDirection
            end

            self.targetReady = true
        end)
    end

    flux.update(dt)
    self.currentAnimation.animation:update(dt)
    self.collider:setX(self.currentPosition.x)
    self.collider:setY(self.currentPosition.y)
end

function saw:draw()
    love.graphics.draw(self.batch)

    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 38, y - 38, 0, 2, 2)
end

return saw