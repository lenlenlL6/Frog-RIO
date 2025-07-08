local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")
local fatBird = {}

local idleImage = love.graphics.newImage("assets/Enemies/FatBird/Idle (40x48).png")
local grid = anim8.newGrid(40, 48, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-8", 1), 0.07)

local fallImage = love.graphics.newImage("assets/Enemies/FatBird/Fall (40x48).png")
grid = anim8.newGrid(40, 48, fallImage:getWidth(), fallImage:getHeight())
local fallAnimation = anim8.newAnimation(grid("1-4", 1), 0.07, "pauseAtEnd")

local groundImage = love.graphics.newImage("assets/Enemies/FatBird/Ground (40x48).png")
grid = anim8.newGrid(40, 48, groundImage:getWidth(), groundImage:getHeight())
local groundAnimation = anim8.newAnimation(grid("1-3", 1), 0.07, "pauseAtEnd")

local hitImage = love.graphics.newImage("assets/Enemies/FatBird/Hit (40x48).png")
grid = anim8.newGrid(40, 48, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-5", 1), 0.07, "pauseAtEnd")

function fatBird:new(x, y, options, world)
    local object = {
        id = options.id,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation
            },
            fall = {
                image = fallImage,
                animation = fallAnimation
            },
            ground = {
                image = groundImage,
                animation = groundAnimation
            },
            hit = {
                image = hitImage,
                animation = hitAnimation
            }
        },
        floatingY = 0,
        floatingTimer = 4,
        floating = true,
        groundedTimer = 3,
        groundedY = 0,
        grounded = false,
        death = false,
        rotation = 0
    }
    object.currentAnimation = object.animations.idle

    object.collider = world:newRectangleCollider(x - 40, y, 80, 48)
    object.collider:setFixedRotation(true)
    object.collider:setCollisionClass("enemy")
    object.collider:setObject(object)
    object.collider:setGravityScale(0)
    object.collider:setPreSolve(function(col1, col2, contact)
        local _, ny = contact:getNormal()
        local bird = col1:getObject()

        if bird.death then
            contact:setEnabled(false)
            return
        end

        if col2.collision_class == "player" then
            contact:setEnabled(false)

            local player = col2:getObject()
            if ny < 0 and bird.grounded and not player.death then
                bird:kill()
            else
                player:kill()
            end
            return
        end

        if col2.collision_class == "platform" then
            if ny < 0 and not bird.grounded then
                bird.grounded = true

                bird.currentAnimation = bird.animations.ground
                bird.currentAnimation.animation:gotoFrame(1)
                bird.currentAnimation.animation:resume()
                
                bird.groundedY = col1:getY()
                return
            end
        end

        if not bird.grounded then
            contact:setEnabled(false)
        end
    end)

    object.baseY = object.collider:getY()
    print(object.baseY)

    return setmetatable(object, {__index = self})
end

function fatBird:update(dt)
    self.currentAnimation.animation:update(dt)

    if self.collider:exit("platform") then
        self.grounded = false
    end

    if self.death then
        self.currentAnimation = self.animations.hit
        if self.collider:getY() > love.graphics.getHeight() then self.collider:destroy() end
        return
    end

    if self.floating then
        self.floatingTimer = self.floatingTimer - dt
        if self.floatingTimer <= 0 then
            self.floatingTimer = 4
            self.floating = false

            self.currentAnimation = self.animations.fall
            self.currentAnimation.animation:gotoFrame(1)
            self.currentAnimation.animation:resume()

            self.collider:setGravityScale(1)
            self.collider:setLinearVelocity(0, 1)

            if self.upFlux then
                self.upFlux:stop()
                self.upFlux = nil
            end
            return
        end

        if not self.upFlux then
            self.upFlux = flux.to(self, 2, {floatingY = -50}):ease("backinout"):after(self, 1, {floatingY = 20}):ease("linear"):oncomplete(function()
                self.upFlux = nil
            end)
        end

        self.collider:setY(self.baseY + self.floatingY)
        return
    end

    self.groundedTimer = self.groundedTimer - dt
    if self.groundedTimer <= 0 then
        self.collider:setGravityScale(0)
        self.collider:setY(self.groundedY)
        if self.groundedY == self.baseY then
            self.groundedTimer = 3
            self.floatingY = 0
            self.floating = true
            return
        end
        self.currentAnimation = self.animations.idle
        if not self.groundFlux then
            self.groundFlux = flux.to(self, 1, {groundedY = self.baseY}):oncomplete(function()
                self.groundFlux = nil
            end)
        end
    end
end

function fatBird:draw()
    if self.collider:isDestroyed() then return end

    local x, y = self.collider:getPosition()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-x, -y)
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 40, y - 65, 0, 2, 2)
    love.graphics.pop()

    -- love.graphics.print(self.floatingY)
end

function fatBird:kill()
    if self.death then return end
    self.death = true
    self.currentAnimation = self.animations.hit
    self.collider:setLinearVelocity(0, 0)
    self.collider:applyLinearImpulse(0, -2000)
    flux.to(self, 2, {rotation = math.rad(120)})
end

return fatBird