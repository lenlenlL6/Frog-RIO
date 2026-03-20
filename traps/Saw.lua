local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local saw = {}

local chainImage = love.graphics.newImage("assets/Traps/Saw/Chain.png")
local onImage = love.graphics.newImage("assets/Traps/Saw/On (38x38).png")
local offImage = love.graphics.newImage("assets/Traps/Saw/Off.png")

local grid = anim8.newGrid(38, 38, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-8", 1), 0.07)
grid = anim8.newGrid(38, 38, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 0.1, "pauseAtEnd")
function saw:new(world, chains, delay)
    local object = {
        chains = chains,
        delay = delay,
        batch = love.graphics.newSpriteBatch(chainImage),
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
        currentIndex = 2,
        indexDirection = 1
    }
    object.currentAnimation = object.animations.on
    object.collider = world:newRectangleCollider(object.chains[1].x - 38, object.chains[1].y - 38, 76, 76)
    object.collider:setType("kinematic")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end

            player:kill()
        end
    end)
    object.x, object.y = object.collider:getPosition()
    for _, chain in ipairs(object.chains) do
        object.batch:add(chain.x - 8, chain.y - 8, 0, 2, 2)
    end
    self.__index = self

    return setmetatable(object, self)
end

function saw:update(dt)
    self.currentAnimation.animation:update(dt)
    if not self.moveFlux then
        self.moveFlux = flux.to(self, 1, {x = self.chains[self.currentIndex].x, y = self.chains[self.currentIndex].y}):ease("linear"):oncomplete(function()
            self.currentIndex = self.currentIndex + self.indexDirection
            if self.currentIndex < 1 then
                self.currentIndex = 1
                self.indexDirection = -self.indexDirection
            elseif self.currentIndex > #self.chains then
                self.currentIndex = #self.chains
                self.indexDirection = -self.indexDirection
            end
            self.moveFlux = nil
        end):delay(self.delay)
    end
    self.collider:setPosition(self.x, self.y)
end

function saw:draw()
    love.graphics.draw(self.batch)
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 38, y - 38, 0, 2, 2)
end

return saw