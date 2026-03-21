local sqrt = math.sqrt
local atan = math.atan
local function normalized(x, y)
    local length = sqrt(x ^ 2 + y ^ 2)
    return x / length, y / length
end

local anim8 = require("libraries.anim8")
local flux = require("libraries.flux")

local bullet = {}

local bulletImage = love.graphics.newImage("assets/Enemies/Bee/Bullet.png")
local bulletPieceImageData = love.image.newImageData("assets/Enemies/Bee/Bullet Pieces.png")
local bulletPieceImageCData = love.image.newImageData(16, 16)
for i = 0, 15 do
    for s = 0, 15 do
        bulletPieceImageCData:setPixel(s, i, bulletPieceImageData:getPixel(s, i))
    end
end
bulletPieceImageData:release()
bulletPieceImageData = nil
local bulletPieceImage = love.graphics.newImage(bulletPieceImageCData)
function bullet:new(x, y, world, direction, speed, angle)
    local object = {
        direction = direction,
        speed = speed,
        angle = angle + math.pi / 2,
        bulletParticle = love.graphics.newParticleSystem(bulletPieceImage)
    }
    object.bulletParticle:setEmissionRate(2.5)
    object.bulletParticle:setParticleLifetime(0.7, 0.8)
    object.bulletParticle:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    object.bulletParticle:setSizes(2)
    object.bulletParticle:setRotation(-math.pi / 2, math.pi / 2)
    object.collider = world:newRectangleCollider(x - 16, y - 16, 30, 30)
    object.collider:setType("kinematic")
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        if col2.collision_class == "Player" then
            local player = col2:getObject()
            if player.isDeath then return end

            player:kill()
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function bullet:update(dt)
    self.collider:setLinearVelocity(self.direction.x * self.speed, self.direction.y * self.speed)
    self.bulletParticle:setPosition(self.collider:getPosition())
    self.bulletParticle:update(dt)
end

function bullet:draw()
    local x, y = self.collider:getPosition()
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.angle)
    love.graphics.translate(-x, -y)
	love.graphics.draw(bulletImage, x - 16, y - 16, 0, 2, 2)
    love.graphics.pop()

    love.graphics.draw(self.bulletParticle)
end

local bee = {}

local idleImage = love.graphics.newImage("assets/Enemies/Bee/Idle (36x34).png")
local attackImage = love.graphics.newImage("assets/Enemies/Bee/Attack (36x34).png")
local hitImage = love.graphics.newImage("assets/Enemies/Bee/Hit (36x34).png")

local grid = anim8.newGrid(36, 34, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-6", 1), 0.07)
grid = anim8.newGrid(36, 34, attackImage:getWidth(), attackImage:getHeight())
local attackAnimation = anim8.newAnimation(grid("1-8", 1), 0.07, "pauseAtEnd")
grid = anim8.newGrid(36, 34, hitImage:getWidth(), hitImage:getHeight())
local hitAnimation = anim8.newAnimation(grid("1-5", 1), 0.07, "pauseAtEnd")
function bee:new(x, y, world, delay, player)
    local object = {
        bullets = {},
        world = world,
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation:clone()
            },
            attack = {
                image = attackImage,
                animation = attackAnimation:clone()
            },
            hit = {
                image = hitImage,
                animation = hitAnimation:clone()
            }
        },
        delay = delay,
        player = player,
        canSpawnBullet = false,
        fluxValue = 0,
        isDeath = false
    }
    object.currentAnimation = object.animations.idle
    object.collider = world:newRectangleCollider(x - 36, y - 34, 60, 68)
    object.collider:setGravityScale(0)
    object.collider:setObject(object)
    object.collider:setPreSolve(function(col1, col2, contact)
        contact:setEnabled(false)
        local beeObject = col1:getObject()
        if beeObject.isDeath then return end
        if col2.collision_class == "Player" then
            --- @diagnostic disable-next-line
            local player = col2:getObject()
            shack:setShake(20)
            beeObject:kill()
            player.collider:setLinearVelocity(0, 0)
            player.collider:applyLinearImpulse(0, -player.jumpStrength)
        end
    end)
    self.__index = self

    return setmetatable(object, self)
end

function bee:update(dt)
    self.currentAnimation.animation:update(dt)
    if not self.bulletFlux and not self.canSpawnBullet then
        self.bulletFlux = flux.to(self, self.delay, { fluxValue = 1 }):ease("linear"):oncomplete(function()
            self.fluxValue = 0
            self.bulletFlux = nil

            self.canSpawnBullet = true
            self.currentAnimation = self.animations.attack
            self.currentAnimation.animation:gotoFrame(1)
            self.currentAnimation.animation:resume()
        end)
    end

    if self.currentAnimation == self.animations.attack and self.currentAnimation.animation.position == 6 and self.canSpawnBullet then
        local playerX, playerY = self.player.collider:getPosition()
        local x, y = self.collider:getPosition()
        local norx, nory = normalized(playerX - x, playerY - y)
        table.insert(self.bullets, bullet:new(self.collider:getX(), self.collider:getY() + 30, self.world, {x = norx, y = nory}, 150, atan(nory / norx)))
        self.canSpawnBullet = false
    elseif self.currentAnimation.animation.status == "paused" then
        self.currentAnimation = self.animations.idle
    end

    for i, bul in ipairs(self.bullets) do
        local x, y = bul.collider:getPosition()
        if x < -10 or x > 810 or y < -10 or y > 610 then
            bul.collider:destroy()
            bul.bulletParticle:release()
            table.remove(self.bullets, i)
        else
            bul:update(dt)
        end
    end
end

function bee:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 36, y - 34, 0, 2, 2)

    -- love.graphics.print("Bullets: " .. #self.bullets, x + 32, y)

    for _, bul in ipairs(self.bullets) do
        bul:draw()
    end
end

function bee:kill()
    self.isDeath = true
    self.collider:setGravityScale(1)
    self.currentAnimation = self.animations.hit
    self.currentAnimation.animation:resume()
end

return bee
