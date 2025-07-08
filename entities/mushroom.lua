local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local mushroom = {}

local idleImage = love.graphics.newImage("assets/Enemies/Mushroom/Idle (32x32).png")
local grid = anim8.newGrid(32, 32, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-14", 1), 0.1):flipH()

local runImage = love.graphics.newImage("assets/Enemies/Mushroom/Run (32x32).png")
grid = anim8.newGrid(32, 32, runImage:getWidth(), runImage:getHeight())
local runAnimation = anim8.newAnimation(grid("1-16", 1), 0.07):flipH()

local hitImage = love.graphics.newImage("assets/Enemies/Mushroom/Hit.png")
grid = anim8.newGrid(32, 32, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-5", 1), 0.07, "pauseAtEnd"):flipH()

function mushroom:new(x, y, options, world)
    local object = {
        id = options.id,
        world = world,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation
            },
            run = {
                image = runImage,
                animation = runAnimation
            },
            hit = {
                image = hitImage,
                animation = hitAnimation
            }
        },
        direction = options.direction,
        rotation = 0,
        death = false,
        moveTimer = 2,
        idleTimer = 0,
        targetVX = 0,
        changeDirection = false
    }
    object.currentAnimation = object.animations.idle

    object.collider = world:newRectangleCollider(x - 32, y, 64, 32)
    object.collider:setFixedRotation(true)
    object.collider:setCollisionClass("enemy")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        if col1:getObject().death then
            contact:setEnabled(false)
            return
        end

        local nx, ny = contact:getNormal()

        if col2.collision_class == "player" and not col2:getObject().death then
            if ny < 0 then
                col1:getObject():kill()
                contact:setEnabled(false)
            else
                col2:getObject():kill()
            end
            return
        end
    end)

    local dustImage = love.graphics.newImage("assets/Other/Dust Particle.png")
    object.pSystem = love.graphics.newParticleSystem(dustImage)
    object.pSystem:setParticleLifetime(0.5, 0.8)
    object.pSystem:setEmissionRate(2)
    object.pSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    -- object.pSystem:setLinearAcceleration(10, -250, 50, 0)
    return setmetatable(object, {__index = self})
end

function mushroom:update(dt)
    if self.collider:enter("platform") then
        local contact = self.collider:getEnterCollisionData("platform").contact

        local nx, _ = contact:getNormal()
        if nx ~= 0 and not self.changeDirection then
            if self.idleFlux then self.idleFlux:stop() end
            if self.moveFlux then self.moveFlux:stop() end
            self.idleFlux = nil
            self.moveFlux = nil

            self.idleTimer = 0
            self.moveTimer = 2

            self.changeDirection = true
        end
    end

    self.currentAnimation.animation:update(dt)
    self.pSystem:update(dt)

    if self.death then
        self.currentAnimation = self.animations.hit
        if self.collider:getY() > love.graphics.getHeight() then self.collider:destroy() end
        return
    end

    if self.idleTimer == 0 and not self.moveFlux then
        self.moveFlux = flux.to(self, 4, {moveTimer = 0}):oncomplete(function()
            self.moveFlux = nil
            self.idleTimer = 2
        end)
    end

    if self.moveTimer == 0 and not self.idleFlux then
        self.targetVX = love.math.random(-100, 100)
        if self.changeDirection then
            self.targetVX = (self.direction == 1) and love.math.random(-100, -50) or love.math.random(50, 100)
            self.changeDirection = false
        end
        self.idleFlux = flux.to(self, 4, {idleTimer = 0}):oncomplete(function()
            self.idleFlux = nil
            self.moveTimer = 2
        end)
    end

    local _, vy = self.collider:getLinearVelocity()
    if self.idleTimer == 0 then
        self.currentAnimation = self.animations.idle
        self.collider:setLinearVelocity(0, vy)

        self.pSystem:stop()
    elseif self.moveTimer == 0 then
        self.direction = (self.targetVX < 0) and -1 or 1
        self.currentAnimation = self.animations.run
        self.collider:setLinearVelocity(self.targetVX, vy)

        self.pSystem:setPosition(self.collider:getX(), self.collider:getY() + 16)
        if self.direction == 1 then
            self.pSystem:setLinearAcceleration(-200, -50, -100, -30)
        else
            self.pSystem:setLinearAcceleration(100, -50, 200, -30)
        end
        self.pSystem:start()
    end
end

function mushroom:draw()
    love.graphics.draw(self.pSystem)
    if self.collider:isDestroyed() then return end

    local x, y = self.collider:getPosition()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-x, -y)
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 32, y - 48, 0, 2*self.direction, 2, (self.direction == 1) and 0 or 32)
    love.graphics.pop()

    -- love.graphics.print(self.idleTimer .. " | " .. self.moveTimer, 0, 300)
end

function mushroom:kill()
    if self.death then return end
    self.death = true
    self.currentAnimation = self.animations.hit
    self.collider:setLinearVelocity(0, 0)
    self.collider:applyLinearImpulse(0, -2000)
    flux.to(self, 2, {rotation = math.rad(120)})
end

return mushroom
