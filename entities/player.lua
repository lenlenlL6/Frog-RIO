local anim8 = require("libraries.anim8")
local baton = require("libraries.baton")
local flux = require("libraries.flux")
local player = {}

local idleImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Idle (32x32).png")
local grid = anim8.newGrid(32, 32, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-11", 1), 0.1)
local runImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Run (32x32).png")
grid = anim8.newGrid(32, 32, runImage:getWidth(), runImage:getHeight())
local runAnimation = anim8.newAnimation(grid("1-12", 1), 0.07)
local jumpImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Jump (32x32).png")
grid = anim8.newGrid(32, 32, jumpImage:getWidth(), jumpImage:getHeight())
local jumpAnimation = anim8.newAnimation(grid("1-1", 1), 1, "pauseAtEnd")
local fallImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Fall (32x32).png")
grid = anim8.newGrid(32, 32, fallImage:getWidth(), fallImage:getHeight())
local fallAnimation = anim8.newAnimation(grid("1-1", 1), 1, "pauseAtEnd")
local wallImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Wall Jump (32x32).png")
grid = anim8.newGrid(32, 32, wallImage:getWidth(), wallImage:getHeight())
local wallAnimation = anim8.newAnimation(grid("1-5", 1), 0.1)
local hitImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Hit (32x32).png")
grid = anim8.newGrid(32, 32, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-7", 1), 0.08, "pauseAtEnd")

function player:new(x, y, world)
    local object = {
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation
            },
            run = {
                image = runImage,
                animation = runAnimation
            },
            jump = {
                image = jumpImage,
                animation = jumpAnimation
            },
            fall = {
                image = fallImage,
                animation = fallAnimation
            },
            wall = {
                image = wallImage,
                animation = wallAnimation
            },
            hit = {
                image = hitImage,
                animation = hitAnimation
            }
        },
        direction = 1,
        input = baton.new({
            controls = {
                left = {"key:a"},
                right = {"key:d"},
                jump = {"key:w"}
            }
        }),
        onGround = false,
        onWall = false,
        speed = 200,
        death = false,
        rotation = 0,
        score = 0
    }
    local dustImage = love.graphics.newImage("assets/Other/Dust Particle.png")
    object.pSystem = love.graphics.newParticleSystem(dustImage)
    object.pSystem:setParticleLifetime(0.2, 0.4)
    object.pSystem:setEmissionRate(0)
    object.pSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    object.pSystem:setEmissionArea("normal", 15, 2, 0, true)
    object.pSystem:setLinearAcceleration(10, -250, 50, 0)

    object.currentAnimation = object.animations.idle
    object.collider = world:newRectangleCollider(x - 16, y + 16, 32, 48)
    object.collider:setFixedRotation(true)
    object.collider:setCollisionClass("player")
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        if col1:getObject().death then
            contact:setEnabled(false)
            return
        end

        local nx, ny = contact:getNormal()

        if col2.collision_class == "fallingPlatform" and nx ~= 0 then
            contact:setEnabled(false)
            return
        end

        if (col2.collision_class == "platform" or col2.collision_class == "fallingPlatform") and ny < 0 then
            local object = col1:getObject()
            if not object.onGround then
                object.onGround = true
                object.onWall = false

                object.pSystem:start()
                object.pSystem:emit(10)
                object.pSystem:pause()
                
                if col2.collision_class == "fallingPlatform" then
                    col2:getObject().standing = true
                end
            end
            return
        end

        if col2.collision_class == "platform" and nx ~= 0 then
            local object = col1:getObject()
            if object.onGround then
                return
            end

            object.onWall = -math.ceil(nx)
            object.currentAnimation = object.animations.wall
            return
        end
    end)

    return setmetatable(object, {__index = self})
end

function player:update(dt)
    self.currentAnimation.animation:update(dt)
    self.pSystem:update(dt)

    if self.death then return end
    self.pSystem:setPosition(self.collider:getX(), self.collider:getY() + 48/2)

    if self.collider:exit("platform") or self.collider:exit("fallingPlatform") then
        self.onGround = false
    end

    self.input:update()

    if self.input:get("jump") ~= 0 and self.onGround then
        self.onGround = false
        self.collider:applyLinearImpulse(0, -800)
    end
    local vx, vy = self.collider:getLinearVelocity()
    
    if not self.onGround and not self.onWall then
        if vy > 0 then
            self.currentAnimation = self.animations.fall
        else
            self.currentAnimation = self.animations.jump
        end
    end

    local left, right = self.input:get("left"), self.input:get("right")
    local move = (right - left) ~= 0
    self.direction = move and (right - left) or self.direction

    if self.onWall then
        self.collider:setLinearVelocity(0, 0)

        if move and self.direction ~= self.onWall then
            self.collider:applyLinearImpulse(2500*-self.onWall, -1500)
            self.collider:setGravityScale(1)
            self.onWall = false
        end
        return
    end

    if move then
        self.collider:setLinearVelocity(self.speed*self.direction, vy)
        if self.onGround then
            self.currentAnimation = self.animations.run
        end
    elseif self.onGround then
        self.collider:setLinearVelocity(0, vy)
        self.currentAnimation = self.animations.idle
    end
end

function player:draw()
    love.graphics.draw(self.pSystem)

    local x, y = self.collider:getPosition()

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-x, -y)
    self.currentAnimation.animation:draw(self.currentAnimation.image, x, y - 40, 0, 2*self.direction, 2, 16)
    love.graphics.pop()

    --[[
    local vx, vy = self.collider:getLinearVelocity()
    love.graphics.print(tostring(vy))
    --]]
end

function player:kill()
    if self.death then return end
    self.death = true
    self.currentAnimation = self.animations.hit
    self.collider:setLinearVelocity(0, 0)
    self.collider:applyLinearImpulse(0, -2000)
    flux.to(self, 2, {rotation = math.rad(120)})
end

return player