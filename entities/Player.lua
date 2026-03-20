local anim8 = require("libraries.anim8")
local baton = require("libraries.baton")
local flux = require("libraries.flux")
local Player = {}

local maskDudeIdleImage = love.graphics.newImage("assets/Main Characters/Mask Dude/Idle (32x32).png")
local ninjaFrogIdleImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Idle (32x32).png")
local pinkManIdleImage = love.graphics.newImage("assets/Main Characters/Pink Man/Idle (32x32).png")
local virtualGuyIdleImage = love.graphics.newImage("assets/Main Characters/Virtual Guy/Idle (32x32).png")

local maskDudeRunImage = love.graphics.newImage("assets/Main Characters/Mask Dude/Run (32x32).png")
local ninjaFrogRunImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Run (32x32).png")
local pinkManRunImage = love.graphics.newImage("assets/Main Characters/Pink Man/Run (32x32).png")
local virtualGuyRunImage = love.graphics.newImage("assets/Main Characters/Virtual Guy/Run (32x32).png")

local maskDudeJumpImage = love.graphics.newImage("assets/Main Characters/Mask Dude/Jump (32x32).png")
local ninjaFrogJumpImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Jump (32x32).png")
local pinkManJumpImage = love.graphics.newImage("assets/Main Characters/Pink Man/Jump (32x32).png")
local virtualGuyJumpImage = love.graphics.newImage("assets/Main Characters/Virtual Guy/Jump (32x32).png")

local maskDudeDoubleJumpImage = love.graphics.newImage("assets/Main Characters/Mask Dude/Double Jump (32x32).png")
local ninjaFrogDoubleJumpImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Double Jump (32x32).png")
local pinkManDoubleJumpImage = love.graphics.newImage("assets/Main Characters/Pink Man/Double Jump (32x32).png")
local virtualGuyDoubleJumpImage = love.graphics.newImage("assets/Main Characters/Virtual Guy/Double Jump (32x32).png")

local maskDudeWallJumpImage = love.graphics.newImage("assets/Main Characters/Mask Dude/Wall Jump (32x32).png")
local ninjaFrogWallJumpImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Wall Jump (32x32).png")
local pinkManWallJumpImage = love.graphics.newImage("assets/Main Characters/Pink Man/Wall Jump (32x32).png")
local virtualGuyWallJumpImage = love.graphics.newImage("assets/Main Characters/Virtual Guy/Wall Jump (32x32).png")

local maskDudeFallImage = love.graphics.newImage("assets/Main Characters/Mask Dude/Fall (32x32).png")
local ninjaFrogFallImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Fall (32x32).png")
local pinkManFallImage = love.graphics.newImage("assets/Main Characters/Pink Man/Fall (32x32).png")
local virtualGuyFallImage = love.graphics.newImage("assets/Main Characters/Virtual Guy/Fall (32x32).png")

local maskDudeHitImage = love.graphics.newImage("assets/Main Characters/Mask Dude/Hit (32x32).png")
local ninjaFrogHitImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Hit (32x32).png")
local pinkManHitImage = love.graphics.newImage("assets/Main Characters/Pink Man/Hit (32x32).png")
local virtualGuyHitImage = love.graphics.newImage("assets/Main Characters/Virtual Guy/Hit (32x32).png")

local idleGrid = anim8.newGrid(32, 32, maskDudeIdleImage:getWidth(), maskDudeIdleImage:getHeight())
local runGrid = anim8.newGrid(32, 32, maskDudeRunImage:getWidth(), maskDudeRunImage:getHeight())
local jumpGrid = anim8.newGrid(32, 32, maskDudeJumpImage:getWidth(), maskDudeJumpImage:getHeight())
local doubleJumpGrid = anim8.newGrid(32, 32, maskDudeDoubleJumpImage:getWidth(), maskDudeDoubleJumpImage:getHeight())
local wallJumpGrid = anim8.newGrid(32, 32, maskDudeWallJumpImage:getWidth(), maskDudeWallJumpImage:getHeight())
local fallGrid = anim8.newGrid(32, 32, maskDudeFallImage:getWidth(), maskDudeFallImage:getHeight())
local hitGrid = anim8.newGrid(32, 32, maskDudeHitImage:getWidth(), maskDudeHitImage:getHeight())

local maskDudeIdleAnimation = anim8.newAnimation(idleGrid("1-11", 1), 0.1)
local ninjaFrogIdleAnimation = anim8.newAnimation(idleGrid("1-11", 1), 0.1)
local pinkManIdleAnimation = anim8.newAnimation(idleGrid("1-11", 1), 0.1)
local virtualGuyIdleAnimation = anim8.newAnimation(idleGrid("1-11", 1), 0.1)

local maskDudeRunAnimation = anim8.newAnimation(runGrid("1-12", 1), 0.05)
local ninjaFrogRunAnimation = anim8.newAnimation(runGrid("1-12", 1), 0.05)
local pinkManRunAnimation = anim8.newAnimation(runGrid("1-12", 1), 0.05)
local virtualGuyRunAnimation = anim8.newAnimation(runGrid("1-12", 1), 0.05)

local maskDudeJumpAnimation = anim8.newAnimation(jumpGrid("1-1", 1), 0.1, "pauseAtEnd")
local ninjaFrogJumpAnimation = anim8.newAnimation(jumpGrid("1-1", 1), 0.1, "pauseAtEnd")
local pinkManJumpAnimation = anim8.newAnimation(jumpGrid("1-1", 1), 0.1, "pauseAtEnd")
local virtualGuyJumpAnimation = anim8.newAnimation(jumpGrid("1-1", 1), 0.1, "pauseAtEnd")

local maskDudeDoubleJumpAnimation = anim8.newAnimation(doubleJumpGrid("1-6", 1), 0.05, "pauseAtEnd")
local ninjaFrogDoubleJumpAnimation = anim8.newAnimation(doubleJumpGrid("1-6", 1), 0.05, "pauseAtEnd")
local pinkManDoubleJumpAnimation = anim8.newAnimation(doubleJumpGrid("1-6", 1), 0.05, "pauseAtEnd")
local virtualGuyDoubleJumpAnimation = anim8.newAnimation(doubleJumpGrid("1-6", 1), 0.05, "pauseAtEnd")

local maskDudeWallJumpAnimation = anim8.newAnimation(wallJumpGrid("1-5", 1), 0.1)
local ninjaFrogWallJumpAnimation = anim8.newAnimation(wallJumpGrid("1-5", 1), 0.1)
local pinkManWallJumpAnimation = anim8.newAnimation(wallJumpGrid("1-5", 1), 0.1)
local virtualGuyWallJumpAnimation = anim8.newAnimation(wallJumpGrid("1-5", 1), 0.1)

local maskDudeFallAnimation = anim8.newAnimation(fallGrid("1-1", 1), 0.1, "pauseAtEnd")
local ninjaFrogFallAnimation = anim8.newAnimation(fallGrid("1-1", 1), 0.1, "pauseAtEnd")
local pinkManFallAnimation = anim8.newAnimation(fallGrid("1-1", 1), 0.1, "pauseAtEnd")
local virtualGuyFallAnimation = anim8.newAnimation(fallGrid("1-1", 1), 0.1, "pauseAtEnd")

local maskDudeHitAnimation = anim8.newAnimation(hitGrid("1-7", 1), 0.08, "pauseAtEnd")
local ninjaFrogHitAnimation = anim8.newAnimation(hitGrid("1-7", 1), 0.08, "pauseAtEnd")
local pinkManHitAnimation = anim8.newAnimation(hitGrid("1-7", 1), 0.08, "pauseAtEnd")
local virtualGuyHitAnimation = anim8.newAnimation(hitGrid("1-7", 1), 0.08, "pauseAtEnd")
function Player:new(x, y, world, options)
    options = options or {}
    local object = {
        movementSpeed = options.movementSpeed or 200,
        jumpStrength = options.jumpStrength or 1500,
        wallJumpStrength = options.wallJumpStrength or 800,
        direction = 1,
        angle = 0,
        moveDirection = 0,
        onGround = false,
        doubleJump = false,
        canDoubleJump = false,
        wallJump = false,
        isDeath = false,
        points = 0
    }
    if GAME_DATA.characterId == 1 then
        object.animations = {
            idle = {
                image = maskDudeIdleImage,
                animation = maskDudeIdleAnimation
            },
            run = {
                image = maskDudeRunImage,
                animation = maskDudeRunAnimation
            },
            jump = {
                image = maskDudeJumpImage,
                animation = maskDudeJumpAnimation
            },
            doubleJump = {
                image = maskDudeDoubleJumpImage,
                animation = maskDudeDoubleJumpAnimation
            },
            wallJump = {
                image = maskDudeWallJumpImage,
                animation = maskDudeWallJumpAnimation
            },
            fall = {
                image = maskDudeFallImage,
                animation = maskDudeFallAnimation
            },
            hit = {
                image = maskDudeHitImage,
                animation = maskDudeHitAnimation
            }
        }
    elseif GAME_DATA.characterId == 2 then
        object.animations = {
            idle = {
                image = ninjaFrogIdleImage,
                animation = ninjaFrogIdleAnimation
            },
            run = {
                image = ninjaFrogRunImage,
                animation = ninjaFrogRunAnimation
            },
            jump = {
                image = ninjaFrogJumpImage,
                animation = ninjaFrogJumpAnimation
            },
            doubleJump = {
                image = ninjaFrogDoubleJumpImage,
                animation = ninjaFrogDoubleJumpAnimation
            },
            wallJump = {
                image = ninjaFrogWallJumpImage,
                animation = ninjaFrogWallJumpAnimation
            },
            fall = {
                image = ninjaFrogFallImage,
                animation = ninjaFrogFallAnimation
            },
            hit = {
                image = ninjaFrogHitImage,
                animation = ninjaFrogHitAnimation
            }
        }
    elseif GAME_DATA.characterId == 3 then
        object.animations = {
            idle = {
                image = pinkManIdleImage,
                animation = pinkManIdleAnimation
            },
            run = {
                image = pinkManRunImage,
                animation = pinkManRunAnimation
            },
            jump = {
                image = pinkManJumpImage,
                animation = pinkManJumpAnimation
            },
            doubleJump = {
                image = pinkManDoubleJumpImage,
                animation = pinkManDoubleJumpAnimation
            },
            wallJump = {
                image = pinkManWallJumpImage,
                animation = pinkManWallJumpAnimation
            },
            fall = {
                image = pinkManFallImage,
                animation = pinkManFallAnimation
            },
            hit = {
                image = pinkManHitImage,
                animation = pinkManHitAnimation
            }
        }
    elseif GAME_DATA.characterId == 4 then
        object.animations = {
            idle = {
                image = virtualGuyIdleImage,
                animation = virtualGuyIdleAnimation
            },
            run = {
                image = virtualGuyRunImage,
                animation = virtualGuyRunAnimation
            },
            jump = {
                image = virtualGuyJumpImage,
                animation = virtualGuyJumpAnimation
            },
            doubleJump = {
                image = virtualGuyDoubleJumpImage,
                animation = virtualGuyDoubleJumpAnimation
            },
            wallJump = {
                image = virtualGuyWallJumpImage,
                animation = virtualGuyWallJumpAnimation
            },
            fall = {
                image = virtualGuyFallImage,
                animation = virtualGuyFallAnimation
            },
            hit = {
                image = virtualGuyHitImage,
                animation = virtualGuyHitAnimation
            }
        }
    end
    object.currentAnimation = object.animations.idle
    object.collider = world:newRectangleCollider(x - 16, y - 24, 32, 48)
    object.collider:setFixedRotation(true)
    object.collider:setObject(object)
    object.collider:setCollisionClass("Player")
    object.collider:setPreSolve(function(col1, col2, contact)
        if col1:getObject().isDeath then
            contact:setEnabled(false)
        end
    end)
    object.collider:setPostSolve(function(col1, col2, contact)
        local nx, ny = contact:getNormal()
        if col2.collision_class == "Platform" and (ny < 0 or (ny > 0 and col2:getObject().delay)) then
            local player = col1:getObject()
            if not player.onGround then
                player.onGround = true
                player.doubleJump = false
                player.canDoubleJump = false
                player.wallJump = false
            end
        end
        if col2.collision_class == "Platform" and nx ~= 0 then
            if not col2:getObject().canWallJump then return end

            local player = col1:getObject()
            if player.wallJump then return end
            if player.onGround then player.wallJump = false; return end
            player.canDoubleJump = false
            player.doubleJump = false
            player.wallJump = -nx / math.abs(nx)
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function Player:update(dt)
    self.currentAnimation.animation:update(dt)
    if self.isDeath then self.angle = self.angle + dt; return end
    if self.collider:exit("Platform") then
        self.onGround = false
        if self.wallJump then
            self.collider:applyLinearImpulse(0, -self.jumpStrength)
        end
        self.wallJump = false
    end

    local vx, vy = self.collider:getLinearVelocity()
    if self.moveDirection ~= 0 then
        self.currentAnimation = self.animations.run
    else
        self.currentAnimation = self.animations.idle
    end
    if not self.onGround and not self.doubleJump then
        self.currentAnimation = (vy > 0) and self.animations.fall or self.animations.jump
    elseif self.doubleJump then
        self.currentAnimation = self.animations.doubleJump
    end
    if self.wallJump then
        self.currentAnimation = self.animations.wallJump
        self.collider:setLinearVelocity(vx, 0)
    else
        self.collider:setLinearVelocity(self.moveDirection * self.movementSpeed, vy)
    end
end

function Player:draw()
    local x, y = self.collider:getPosition()
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.angle)
    love.graphics.translate(-x, -y)
    self.currentAnimation.animation:draw(self.currentAnimation.image, x, y - 40, 0, 2 * self.direction, 2, 16)
    love.graphics.pop()

    love.graphics.print("onGround: " .. tostring(self.onGround), x + 32, y - 16)
    love.graphics.print("doubleJumpAnim: " .. tostring(self.doubleJump), x + 32, y)
    love.graphics.print("canDoubleJump: " .. tostring(self.canDoubleJump), x + 32, y + 16)
    love.graphics.print("wallJump: " .. tostring(self.wallJump), x + 32, y + 32)
end

function Player:keypressed(key)
    if key == "w" and (self.onGround or self.canDoubleJump) then
        self.canDoubleJump = not self.canDoubleJump
        self.doubleJump = not self.canDoubleJump
        if self.doubleJump then
            self.animations.doubleJump.animation:gotoFrame(1)
            self.animations.doubleJump.animation:resume()
            self.currentAnimation = self.animations.doubleJump
        end
        local vx, _ = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, 0)
        self.collider:applyLinearImpulse(0, -self.jumpStrength)
    end
    if key == "a" then
        self.moveDirection = self.moveDirection - 1
    end
    if key == "d" then
        self.moveDirection = self.moveDirection + 1
    end
    if self.moveDirection ~= 0 then
        self.direction = self.moveDirection
        if not self.wallJump then return end

        if self.wallJump ~= self.direction then
            self.collider:setLinearVelocity(0, 0)
            self.collider:applyLinearImpulse(self.direction * self.wallJumpStrength, 0)
        end
    end
end

function Player:keyreleased(key)
    if key == "a" then
        self.moveDirection = self.moveDirection + 1
    end
    if key == "d" then
        self.moveDirection = self.moveDirection - 1
    end
    if self.moveDirection ~= 0 then
        self.direction = self.moveDirection
        if not self.wallJump then return end

        if self.wallJump ~= self.direction then
            self.collider:setLinearVelocity(0, 0)
            self.collider:applyLinearImpulse(self.direction * self.wallJumpStrength, 0)
        end
    end
end

function Player:kill()
    self.isDeath = true
    self.collider:setLinearVelocity(0, 0)
    self.collider:applyLinearImpulse(0, -self.jumpStrength)
    self.currentAnimation = self.animations.hit
    self.currentAnimation.animation:resume()
end

function Player.resetAllAnimations()
    maskDudeIdleAnimation:gotoFrame(1)
    ninjaFrogIdleAnimation:gotoFrame(1)
    pinkManIdleAnimation:gotoFrame(1)
    virtualGuyIdleAnimation:gotoFrame(1)
    maskDudeRunAnimation:gotoFrame(1)
    ninjaFrogRunAnimation:gotoFrame(1)
    pinkManRunAnimation:gotoFrame(1)
    virtualGuyRunAnimation:gotoFrame(1)
    maskDudeJumpAnimation:gotoFrame(1)
    ninjaFrogJumpAnimation:gotoFrame(1)
    pinkManJumpAnimation:gotoFrame(1)
    virtualGuyJumpAnimation:gotoFrame(1)
    maskDudeDoubleJumpAnimation:gotoFrame(1)
    ninjaFrogDoubleJumpAnimation:gotoFrame(1)
    pinkManDoubleJumpAnimation:gotoFrame(1)
    virtualGuyDoubleJumpAnimation:gotoFrame(1)
    maskDudeWallJumpAnimation:gotoFrame(1)
    ninjaFrogWallJumpAnimation:gotoFrame(1)
    pinkManWallJumpAnimation:gotoFrame(1)
    virtualGuyWallJumpAnimation:gotoFrame(1)
    maskDudeFallAnimation:gotoFrame(1)
    ninjaFrogFallAnimation:gotoFrame(1)
    pinkManFallAnimation:gotoFrame(1)
    virtualGuyFallAnimation:gotoFrame(1)
    maskDudeHitAnimation:gotoFrame(1)
    ninjaFrogHitAnimation:gotoFrame(1)
    pinkManHitAnimation:gotoFrame(1)
    virtualGuyHitAnimation:gotoFrame(1)
end

return Player