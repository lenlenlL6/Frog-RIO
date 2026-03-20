local sqrt = math.sqrt
local function normalized(x, y)
    local length = sqrt(x ^ 2 + y ^ 2)
    return x / length, y / length
end
local function distance(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local bat = {}

local ceilingInImage = love.graphics.newImage("assets/Enemies/Bat/Ceiling In (46x30).png")
local ceilingOutImage = love.graphics.newImage("assets/Enemies/Bat/Ceiling Out (46x30).png")
local flyingImage = love.graphics.newImage("assets/Enemies/Bat/Flying (46x30).png")
local hitImage = love.graphics.newImage("assets/Enemies/Bat/Hit (46x30).png")

local grid = anim8.newGrid(46, 30, ceilingInImage:getWidth(), ceilingInImage:getHeight())
local ceilingInAnimation = anim8.newAnimation(grid("1-7", 1), 0.07, "pauseAtEnd")
grid = anim8.newGrid(46, 30, ceilingOutImage:getWidth(), ceilingOutImage:getHeight())
local ceilingOutAnimation = anim8.newAnimation(grid("1-7", 1), 0.07, "pauseAtEnd")
grid = anim8.newGrid(46, 30, flyingImage:getWidth(), flyingImage:getHeight())
local flyingAnimation = anim8.newAnimation(grid("1-7", 1), 0.07)
grid = anim8.newGrid(46, 30, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-5", 1), 0.07, "pauseAtEnd")

function bat:new(x, y, world, height, player)
    local object = {
        player = player,
        animations = {
            ceilingIn = {
                image = ceilingInImage,
                animation = ceilingInAnimation:clone()
            },
            ceilingOut = {
                image = ceilingOutImage,
                animation = ceilingOutAnimation:clone()
            },
            flying = {
                image = flyingImage,
                animation = flyingAnimation:clone()
            },
            hit = {
                image = hitImage,
                animation = hitAnimation:clone()
            }
        },
        height = height,
        speed = 150,
        direction = 1,
        isDeath = false,
        isAngry = false,
        fluxValue = 0
    }
    object.currentAnimation = object.animations.ceilingIn
    object.currentAnimation.animation:gotoFrame(7)
    object.collider = world:newRectangleCollider(x - 32, y - 30, 64, 60)
    object.collider:setGravityScale(0)
    object.collider:setFixedRotation(true)
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        local batObject = col1:getObject()
        if batObject.isDeath then contact:setEnabled(false); return end
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end
            
            local _, ny = contact:getNormal()
            if ny > 0 then
                contact:setEnabled(false)
                shack:setShake(20)
                batObject:kill()
                player.collider:setLinearVelocity(0, 0)
                player.collider:applyLinearImpulse(0, -player.jumpStrength)
                return
            end
            player:kill()
        end
    end)
    object.defaultX, object.defaultY = object.collider:getPosition()
    object.defaultY = object.defaultY + 30
    self.__index = self

    return setmetatable(object, self)
end

function bat:update(dt)
    self.currentAnimation.animation:update(dt)

    if self.isDeath then return end

    local playerX, playerY = self.player.collider:getPosition()
    local x, y = self.collider:getPosition()
    if playerX >= x - 80 and playerX <= x + 80 and playerY >= y - 30 and playerY <= y - 30 + self.height then
        if self.angryFlux then self.angryFlux:stop(); self.fluxValue = 0; self.angryFlux = nil end
        if self.currentAnimation == self.animations.ceilingIn then
            self.currentAnimation = self.animations.ceilingOut
        end
        if self.currentAnimation == self.animations.flying then
            local norx, nory = normalized(playerX - x, playerY - y)
            self.collider:setLinearVelocity(norx * self.speed, nory * self.speed)
        end
        self.isAngry = true
    else
        self.collider:setLinearVelocity(0, 0)
        if not self.angryFlux and self.isAngry then
            self.angryFlux = flux.to(self, 2, {fluxValue = 1}):ease("linear"):oncomplete(function()
                self.fluxValue = 0
                self.isAngry = false
                self.angryFlux = nil
            end)
        end
    end

    if not self.isAngry and (x ~= self.defaultX or y ~= self.defaultY) then
        if distance(x, y, self.defaultX, self.defaultY) <= 10 and self.currentAnimation ~= self.animations.ceilingIn then
            self.collider:setPosition(self.defaultX, self.defaultY)
            self.currentAnimation = self.animations.ceilingIn
            self.currentAnimation.animation:gotoFrame(1)
            self.currentAnimation.animation:resume()

            self.animations.ceilingOut.animation:gotoFrame(1)
            self.animations.ceilingOut.animation:resume()
            return
        end
        local norx, nory = normalized(self.defaultX - x, self.defaultY - y)
        self.collider:setLinearVelocity(norx * self.speed, nory * self.speed)
    else
        if self.currentAnimation == self.animations.ceilingOut and self.currentAnimation.animation.status == "paused" then self.currentAnimation = self.animations.flying end
    end
end

function bat:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 46, y - 30, 0, -2 * self.direction, 2, (self.direction == 1) and 46 or 0)

    -- love.graphics.rectangle("line", x - 80, y - 30, 160, self.height)
end

function bat:kill()
    self.isDeath = true
    self.collider:setLinearVelocity(0, 0)
    self.collider:setGravityScale(1)
    self.collider:applyLinearImpulse(0, -1500)
    self.currentAnimation = self.animations.hit
    self.currentAnimation.animation:resume()
end

return bat