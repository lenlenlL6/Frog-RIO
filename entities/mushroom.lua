math.randomseed(os.time())

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
        targetVX = 0
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

        if col2.collision_class == "player" then
            contact:setEnabled(false)

            if ny < 0 then
                col1:getObject():kill()
            else
                col2:getObject():kill()
            end
            return
        end

        if col2.collision_class == "platform" and nx ~= 0 and object.moveTimer == 0 then
            local object = col1:getObject()
            if object.idleFlux then object.idleFlux:stop() end
            if object.moveFlux then object.moveFlux:stop() end
            object.idleFlux = nil
            object.moveFlux = nil

            object.idleTimer = 0
            object.moveTimer = 2
        end
    end)
    object.currentX = object.collider:getX()

    return setmetatable(object, {__index = self})
end

function mushroom:update(dt)
    self.currentAnimation.animation:update(dt)
    flux.update(dt)

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
        self.targetVX = math.random(-100, 100)
        self.idleFlux = flux.to(self, 4, {idleTimer = 0}):oncomplete(function()
            self.idleFlux = nil
            self.moveTimer = 2
        end)
    end

    local _, vy = self.collider:getLinearVelocity()
    if self.idleTimer == 0 then
        self.currentAnimation = self.animations.idle
        self.collider:setLinearVelocity(0, vy)
    elseif self.moveTimer == 0 then
        self.direction = (self.targetVX < 0) and -1 or 1
        self.currentAnimation = self.animations.run
        self.collider:setLinearVelocity(self.targetVX, vy)
    end
end

function mushroom:draw()
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