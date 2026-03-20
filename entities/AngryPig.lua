local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local angryPig = {}

local idleImage = love.graphics.newImage("assets/Enemies/AngryPig/Idle (36x30).png")
local hitImage = love.graphics.newImage("assets/Enemies/AngryPig/Hit 1 (36x30).png")
local walkImage = love.graphics.newImage("assets/Enemies/AngryPig/Walk (36x30).png")
local runImage = love.graphics.newImage("assets/Enemies/AngryPig/Run (36x30).png")

local grid = anim8.newGrid(36, 30, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-9", 1), 0.07)
grid = anim8.newGrid(36, 30, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-5", 1), 0.07, "pauseAtEnd")
grid = anim8.newGrid(36, 30, walkImage:getWidth(), walkImage:getHeight())
local walkAnimation = anim8.newAnimation(grid("1-16", 1), 0.07)
grid = anim8.newGrid(36, 30, runImage:getWidth(), runImage:getHeight())
local runAnimation = anim8.newAnimation(grid("1-12", 1), 0.07)

function angryPig:new(x, y, world, direction, player)
    local object = {
        direction = direction,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation:clone()
            },
            walk = {
                image = walkImage,
                animation = walkAnimation:clone()
            },
            run = {
                image = runImage,
                animation = runAnimation:clone()
            },
            hit = {
                image = hitImage,
                animation = hitAnimation:clone()
            }
        },
        fluxValue = 0,
        speed = 0,
        player = player,
        isAngry = false,
        isDeath = false
    }
    object.currentAnimation = object.animations.idle
    object.collider = world:newRectangleCollider(x - 36, y - 30, 72, 60)
    object.collider:setFixedRotation(true)
    object.collider:setCollisionClass("Enemy")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        local angryPigObject = col1:getObject()
        if angryPigObject.isDeath then contact:setEnabled(false); return end
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end
            if angryPigObject.isAngry then contact:setEnabled(false); player:kill(); return end
            local _, ny = contact:getNormal()
            if ny > 0 then
                contact:setEnabled(false)
                shack:setShake(20)
                angryPigObject:kill()
                player.collider:setLinearVelocity(0, 0)
                player.collider:applyLinearImpulse(0, -player.jumpStrength)
                return
            end
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function angryPig:update(dt)
    self.currentAnimation.animation:update(dt)
    if self.isDeath then return end
    if self.collider:enter("Platform") then
        local collision_data = self.collider:getEnterCollisionData("Platform")
        local nx, _ = collision_data.contact:getNormal()
        if nx ~= 0 then self.direction = -self.direction end
    end

    if not self.randomFlux and not self.isAngry then
        self.randomFlux = flux.to(self, love.math.random(1, 4), {fluxValue = 1}):ease("linear"):oncomplete(function()
            self.fluxValue = 0
            self.speed = (self.speed == 0) and 50 or 0
            self.currentAnimation = (self.speed > 0) and self.animations.walk or self.animations.idle
            self.randomFlux = nil
        end)
    end

    local _, vy = self.collider:getLinearVelocity()
    self.collider:setLinearVelocity(self.direction * self.speed, vy)

    local playerX, playerY = self.player.collider:getPosition()
    local x, y = self.collider:getPosition()
    if playerY < y then
        if self.isAngry then
            self.speed = 50
            self.isAngry = false
            self.currentAnimation = self.animations.walk
        end
        return
    end

    if self.direction == -1 and playerX < x then
        self.isAngry = true
        if self.randomFlux then self.randomFlux:stop(); self.randomFlux = nil end

        self.speed = 200
        self.currentAnimation = self.animations.run
    elseif self.direction == 1 and playerX > x then
        self.isAngry = true
        if self.randomFlux then self.randomFlux:stop(); self.randomFlux = nil end

        self.speed = 200
        self.currentAnimation = self.animations.run
    else
        self.speed = 50
        self.isAngry = false
        self.currentAnimation = self.animations.walk
    end
end

function angryPig:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 36, y - 30, 0, -2 * self.direction, 2, (self.direction == 1) and 36 or 0)
end

function angryPig:kill()
    self.isDeath = true
    self.collider:setLinearVelocity(0, 0)
    self.collider:applyLinearImpulse(0, -1500)
    self.currentAnimation = self.animations.hit
    self.currentAnimation.animation:resume()
end

return angryPig