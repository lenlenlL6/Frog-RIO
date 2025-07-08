math.randomseed(os.time())

local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local ghost = {}

local appearImage = love.graphics.newImage("assets/Enemies/Ghost/Appear (44x30).png")
local grid = anim8.newGrid(44, 30, appearImage:getWidth(), appearImage:getHeight())
local appearAnimation = anim8.newAnimation(grid("1-4", 1), 0.07, "pauseAtEnd"):flipH()

local desappearImage = love.graphics.newImage("assets/Enemies/Ghost/Desappear (44x30).png")
grid = anim8.newGrid(44, 30, desappearImage:getWidth(), desappearImage:getHeight())
local desappearAnimation = anim8.newAnimation(grid("1-4", 1), 0.07, "pauseAtEnd"):flipH()

local hitImage = love.graphics.newImage("assets/Enemies/Ghost/Hit (44x30).png")
grid = anim8.newGrid(44, 30, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-4", 1), 0.07, "pauseAtEnd"):flipH()

local idleImage = love.graphics.newImage("assets/Enemies/Ghost/Idle (44x30).png")
grid = anim8.newGrid(44, 30, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-10", 1), 0.1):flipH()

function ghost:new(x, y, options, world)
    local object = {
        id = options.id,
        world = world,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation
            },
            appear = {
                image = appearImage,
                animation = appearAnimation
            },
            desappear = {
                image = desappearImage,
                animation = desappearAnimation
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
        changeDirection = false,
        appear = true
    }
    object.currentAnimation = object.animations.idle

    object.collider = world:newRectangleCollider(x - 44, y, 44, 50)
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

    return setmetatable(object, {__index = self})
end

function ghost:update(dt)
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

            self.animations.appear.animation:pause()
            self.animations.appear.animation:gotoFrame(1)
            self.animations.desappear.animation:pause()
            self.animations.desappear.animation:gotoFrame(1)
            self.currentAnimation = self.animations.appear
            self.currentAnimation.animation:resume()
            self.appear = true
        end
    end

    self.currentAnimation.animation:update(dt)

    if self.death then
        self.currentAnimation = self.animations.hit
        if self.collider:getY() > love.graphics.getHeight() then self.collider:destroy() end
        return
    end

    if self.idleTimer == 0 and not self.moveFlux then
        self.moveFlux = flux.to(self, 4, {moveTimer = 0}):oncomplete(function()
            self.moveFlux = nil
            self.idleTimer = 2
            self.animations.desappear.animation:gotoFrame(1)
            self.currentAnimation = self.animations.desappear
            self.currentAnimation.animation:resume()
        end)
        self.appear = true
    end

    if self.moveTimer == 0 and not self.idleFlux then
        self.targetVX = math.random(-100, 100)
        if self.changeDirection then
            self.targetVX = (self.direction == 1) and math.random(-100, -50) or math.random(50, 100)
            self.changeDirection = false
        end
        self.idleFlux = flux.to(self, 4, {idleTimer = 0}):oncomplete(function()
            self.idleFlux = nil
            self.moveTimer = 2
            self.animations.appear.animation:gotoFrame(1)
            self.currentAnimation = self.animations.appear
            self.currentAnimation.animation:resume()
        end)
    end

    if self.currentAnimation == self.animations.desappear and self.currentAnimation.animation.position == 4 then
        self.appear = false
    end

    local _, vy = self.collider:getLinearVelocity()
    if self.idleTimer == 0 then
        if self.currentAnimation == self.animations.appear and self.currentAnimation.animation.position == 4 then
            self.currentAnimation = self.animations.idle
        end
        self.collider:setLinearVelocity(0, vy)
    elseif self.moveTimer == 0 then
        self.direction = (self.targetVX < 0) and -1 or 1
        self.collider:setLinearVelocity(self.targetVX, vy)
    end
end

function ghost:draw()
    if self.collider:isDestroyed() or not self.appear then return end

    local x, y = self.collider:getPosition()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-x, -y)
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 44, y - 34, 0, 2*self.direction, 2, (self.direction == 1) and 0 or 44)
    love.graphics.pop()
end

function ghost:kill()
    if self.death then return end
    self.appear = true
    self.death = true
    self.currentAnimation = self.animations.hit
    self.collider:setLinearVelocity(0, 0)
    self.collider:applyLinearImpulse(0, -2000)
    flux.to(self, 2, {rotation = math.rad(120)})
end

return ghost