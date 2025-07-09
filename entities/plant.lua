local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")

local bulletImage = love.graphics.newImage("assets/Enemies/Plant/Bullet.png")
local bullet__ = {}

function bullet__:new(x, y, direction, world)
    local object = {
        direction = direction
    }
    object.collider = world:newRectangleCollider(x - 8, y - 8, 16, 16)
    object.collider:setGravityScale(0)
    object.collider:setCollisionClass("bullet")
    object.collider:setFixedRotation(true)
    object.collider:setBullet(true)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)

        if col2.collision_class == "player" or col2.collision_class == "platform" then
            object:kill()
            if col2.collision_class == "player" then
                col2:getObject():kill()
            end
        end
    end)
    return setmetatable(object, {__index = self})
end

function bullet__:update(dt)
    if self.collider:isDestroyed() then return end

    self.collider:setLinearVelocity(400*self.direction, 0)
end

function bullet__:draw()
    if self.collider:isDestroyed() then return end
    local x, y = self.collider:getPosition()

    love.graphics.draw(bulletImage, x - 15, y - 15, 0, 2, 2)
end

function bullet__:kill()
    self.collider:destroy()
end

local plant = {}

local idleImage = love.graphics.newImage("assets/Enemies/Plant/Idle (44x42).png")
local grid = anim8.newGrid(44, 42, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-11", 1), 0.1):flipH()

local attackImage = love.graphics.newImage("assets/Enemies/Plant/Attack (44x42).png")
grid = anim8.newGrid(44, 42, attackImage:getWidth(), attackImage:getHeight())
local attackAnimation = anim8.newAnimation(grid("1-8", 1), 0.07, "pauseAtEnd"):flipH()

local hitImage = love.graphics.newImage("assets/Enemies/Plant/Hit (44x42).png")
grid = anim8.newGrid(44, 42, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-5", 1), 0.07, "pauseAtEnd"):flipH()

function plant:new(x, y, options, world)
    local object = {
        id = options.id,
        world = world,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation
            },
            attack = {
                image = attackImage,
                animation = attackAnimation
            },
            hit = {
                image = hitImage,
                animation = hitAnimation
            }
        },
        direction = options.direction,
        attackTimer = 1,
        attackCooldown = 0,
        canSpawn = true,
        death = false,
        rotation = 0
    }
    object.currentAnimation = object.animations.idle

    object.collider = world:newRectangleCollider(x - 16, y - 42, 32, 68)
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

    object.bullets = {}

    return setmetatable(object, {__index = self})
end

function plant:update(dt)
    for i, bullet in pairs(self.bullets) do
        if bullet.collider:isDestroyed() then
            bullet.collider:release()
            table.remove(self.bullets, i)
        else
            bullet:update(dt)
        end
    end

    self.currentAnimation.animation:update(dt)
    if self.death then return end

    if not self.attackFlux and self.attackCooldown == 0 then
        self.attackFlux = flux.to(self, 0, {attackTimer = 0}):ease("linear"):oncomplete(function()
            local x, y = self.collider:getPosition()
            local colliders = self.world:queryRectangleArea(0, y - 68/2, love.graphics.getWidth(), 68, {"player"})
            if #colliders > 0 then
                local player = colliders[1]:getObject()
                self.direction = (player.collider:getX() - x > 0) and 1 or -1

                self.currentAnimation = self.animations.attack
                self.currentAnimation.animation:gotoFrame(1)
                self.currentAnimation.animation:resume()
                
                self.canSpawn = true
            end

            self.attackCooldown = 1
            self.attackFlux = nil
        end)
    end

    if not self.cooldownFlux and self.attackCooldown == 1 then
        self.cooldownFlux = flux.to(self, 1.5, {attackCooldown = 0}):ease("linear"):oncomplete(function()
            self.attackTimer = 1
            self.cooldownFlux = nil
        end)
    end

    if self.currentAnimation ~= self.animations.attack then
        self.currentAnimation = self.animations.idle
    elseif self.currentAnimation.animation.position == 8 then
        self.currentAnimation = self.animations.idle
    elseif self.currentAnimation.animation.position == 5 and self.canSpawn then
        self.canSpawn = false
        table.insert(self.bullets, bullet__:new(self.collider:getX() + 48*self.direction, self.collider:getY() - 13, self.direction, self.world))
    end
end

function plant:draw()
    local x, y = self.collider:getPosition()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-x, -y)
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 34, y - 50, 0, 2*self.direction, 2, (self.direction == 1) and 0 or 34)
    love.graphics.pop()

    for _, bullet in pairs(self.bullets) do
        bullet:draw()
    end
    -- love.graphics.print(#self.bullets)
    -- love.graphics.circle("fill", x + 48*self.direction, y - 13, 3)
end

function plant:kill()
    if self.death then return end
    self.death = true
    self.currentAnimation = self.animations.hit
    self.collider:setLinearVelocity(0, 0)
    self.collider:applyLinearImpulse(0, -2000)
    flux.to(self, 2, {rotation = math.rad(120)})
    if self.attackFlux then
        self.attackFlux:stop()
        self.attackFlux = nil
    end

    if self.cooldownFlux then
        self.cooldownFlux:stop()
        self.cooldownFlux = nil
    end
end

return plant