local sqrt = math.sqrt
local function distance(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local Button = require("utils.Button")
local Background = require("utils.Background")
local Transition = require("utils.Transition")
local Player = require("entities.Player")
local Fruit = require("items.Fruit")
local anim8 = require("libraries.anim8")
local sti = require("libraries.sti")
local wf = require("libraries.windfield")
local LevelScene = {}

local leaveImage = love.graphics.newImage("assets/Menu/Buttons/Restart.png")
local titleFont = love.graphics.newFont("assets/MinecraftRegular.otf", 45)
local normalFont = love.graphics.newFont("assets/MinecraftRegular.otf", 25)
local checkpointImage = love.graphics.newImage("assets/Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png")
local grid = anim8.newGrid(64, 64, checkpointImage:getWidth(), checkpointImage:getHeight())
local checkpointAnimation = anim8.newAnimation(grid("1-10", 1), 0.07)
function LevelScene:enter(previous, args)
    self.level = args.level
    self.gameOver = false

    Player.resetAllAnimations()

    self.transition = Transition:new(-20)
    self.transition.scale = 7
    self.map = sti(string.format("levels/level_%d.lua", args.level))
    local backgroundImage = love.graphics.newImage(string.format("assets/Background/%s.png", self.map.properties.background))
    backgroundImage:setFilter("linear", "linear")
    backgroundImage:setWrap("repeat", "repeat")
    self.background = Background:new(backgroundImage, {self.map.properties.backgroundXDirection, self.map.properties.backgroundYDirection}, self.map.properties.backgroundSpeed)
    self.world = wf.newWorld(0, 1800, true)
    self.world:addCollisionClass("Player")
    self.world:addCollisionClass("Platform")
    self.world:addCollisionClass("Enemy")
    for _, object in ipairs(self.map.layers["Collider"].objects) do
        local collider = self.world:newRectangleCollider(object.x * 2, object.y * 2, object.width * 2, object.height * 2)
        collider:setType("static")
        collider:setObject(object.properties)
        collider:setCollisionClass("Platform")
    end
    local playerPosition = self.map.layers["Player"].objects[1]
    self.player = Player:new(playerPosition.x * 2, playerPosition.y * 2, self.world)

    self.traps = {}
    for _, trap in ipairs(self.map.layers["Trap"].objects) do
        local properties = trap.properties
        if properties.id == 1 then
            table.insert(self.traps, TRAP_ID[properties.id]:new(trap.x * 2, trap.y * 2, self.world, properties.angle, properties.strength))
        elseif properties.id == 2 then
            table.insert(self.traps, TRAP_ID[properties.id]:new(trap.x * 2, trap.y * 2, self.world, properties.delay))
        elseif properties.id == 3 then
            table.insert(self.traps, TRAP_ID[properties.id]:new(trap.x * 2, trap.y * 2, self.world))
        elseif properties.id == 4 then
            table.insert(self.traps, TRAP_ID[properties.id]:new(trap.x * 2, trap.y * 2, self.world, properties.delay))
        elseif properties.id == 5 then
            local chains = {}
            for __, vert in ipairs(trap.polygon) do table.insert(chains, {x = vert.x * 2, y = vert.y * 2}) end
            table.insert(self.traps, TRAP_ID[properties.id]:new(self.world, chains, properties.delay))
        elseif properties.id == 6 then
            table.insert(self.traps, TRAP_ID[properties.id]:new(trap.x * 2, trap.y * 2, self.world))
        elseif properties.id == 7 then
            table.insert(self.traps, TRAP_ID[properties.id]:new(trap.x * 2, trap.y * 2, self.world, properties.strength))
        elseif properties.id == 8 then
            table.insert(self.traps, TRAP_ID[properties.id]:new(trap.x * 2, trap.y * 2, self.world, properties.radius * 2, properties.range, properties.delay, properties.direction))
        end
    end

    self.fruits = {}
    for _, fruit in ipairs(self.map.layers["Fruit"].objects) do
        table.insert(self.fruits, Fruit:new(fruit.properties.id, fruit.x * 2, fruit.y * 2, self.world, fruit.properties.points))
    end

    self.enemies = {}
    for _, enemy in ipairs(self.map.layers["Enemy"].objects) do
        local properties = enemy.properties
        if properties.id == 1 then
            table.insert(self.enemies, ENEMY_ID[properties.id]:new(enemy.x * 2, enemy.y * 2, self.world, properties.direction, self.player))
        elseif properties.id == 2 then
            table.insert(self.enemies, ENEMY_ID[properties.id]:new(enemy.x * 2, enemy.y * 2, self.world, properties.height * 2, self.player))
        elseif properties.id == 3 then
            table.insert(self.enemies, ENEMY_ID[properties.id]:new(enemy.x * 2, enemy.y * 2, self.world, properties.delay, self.player))
        elseif properties.id == 4 then
            table.insert(self.enemies, ENEMY_ID[properties.id]:new(enemy.x * 2, enemy.y * 2, self.world, properties.width * 2, properties.direction))
        end
    end

    self.checkpointPosition = self.map.layers["Goal"].objects[1]
    self.checkpointPosition.x, self.checkpointPosition.y = self.checkpointPosition.x * 2, self.checkpointPosition.y * 2

    self.buttons = {}
    self.buttons.leave = Button:new(745, 5, 50, 50)
    self.buttons.leave.style = function(button)
        if button.isHovered then love.graphics.setColor(0.7, 0.7, 0.7) end
        love.graphics.draw(leaveImage, button.x, button.y, 0, button.width / leaveImage:getWidth(),
            button.height / leaveImage:getHeight())
        love.graphics.setColor(1, 1, 1)
    end
    self.buttons.leave.onClick = function()
        self.transition.speed = 20
        self.transition.onComplete = function()
            manager:enter(scenes.menu)
        end
        self.transition.active = true
    end

    self.gameOverText = love.graphics.newText(titleFont, "GAME OVER")
    self.pointsText = love.graphics.newText(normalFont, "Your points: ")
end

function LevelScene:update(dt)
    if self.gameOver then
        for _, btn in pairs(self.buttons) do btn:update(dt) end
        self.transition:update(dt)
       return
    end
    self.background:update(dt)
    self.player:update(dt)
    local playerX, playerY = self.player.collider:getPosition()
    if playerY > 650 then
        self.gameOver = true
        self.pointsText:set("Your points: " .. self.player.points)
        return
    end
    if distance(playerX, playerY, self.checkpointPosition.x, self.checkpointPosition.y) <= 35 then
        self.gameOver = true
        self.gameOverText:set("LEVEL COMPLETED")
        self.pointsText:set("Your points: " .. self.player.points)

        if self.level == GAME_DATA.level and GAME_DATA.level + 1 <= GAME_DATA.maxLevel then
            GAME_DATA.level = GAME_DATA + 1
        end
    end
    for i, trap in ipairs(self.traps) do
        trap:update(dt)
        if trap.canBeDestroy then
            trap.collider:destroy()
            table.remove(self.traps, i)
        end
    end
    for i, fruit in ipairs(self.fruits) do
        fruit:update(dt)
        if fruit.canBeDestroy then
            fruit.collider:destroy()
            table.remove(self.fruits, i)
        end
    end
    for i, enemy in ipairs(self.enemies) do
        enemy:update(dt)
        if enemy.collider:getY() > 750 then
            if enemy.bullets then
                for _, bul in ipairs(enemy.bullets) do
                    bul.collider:destroy()
                    bul.bulletParticle:release()
                end
                enemy.bullets = nil
            end
            enemy.collider:destroy()
            table.remove(self.enemies, i)
        end
    end
    checkpointAnimation:update(dt)
    for _, btn in pairs(self.buttons) do btn:update(dt) end
    self.world:update(dt)
    self.transition:update(dt)
end

function LevelScene:draw()
    if self.gameOver then love.graphics.setColor(0.5, 0.5, 0.5) end
    self.background:draw()
    self.map:draw(0, 0, 2, 2)
    self.player:draw()
    for _, trap in ipairs(self.traps) do trap:draw() end
    for _, fruit in ipairs(self.fruits) do fruit:draw() end
    for _, enemy in ipairs(self.enemies) do enemy:draw() end
    checkpointAnimation:draw(checkpointImage, self.checkpointPosition.x - 64, self.checkpointPosition.y - 126, 0, 2, 2)

    -- self.world:draw()

    for _, btn in pairs(self.buttons) do btn:draw() end

    love.graphics.setColor(1, 1, 1)
    if self.gameOver then
        love.graphics.draw(self.gameOverText, 400 - self.gameOverText:getWidth() / 2, 240)
        love.graphics.draw(self.pointsText, 400 - self.pointsText:getWidth() / 2, 300)
    end

    self.transition:draw()

    --[[
    love.graphics.print("Traps: " .. #self.traps, 0, 32)
    love.graphics.print("Fruits: " .. #self.fruits, 0, 48)
    love.graphics.print("Enemies: " .. #self.enemies, 0, 64)
    --]]
end

function LevelScene:keypressed(key, scancode, isrepeat)
    self.player:keypressed(key)
end

function LevelScene:keyreleased(key, scancode)
    self.player:keyreleased(key)
end

function LevelScene:mousepressed(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do btn:mousepressed(x, y, button) end
end

function LevelScene:mousereleased(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do btn:mousereleased(x, y) end
end

function LevelScene:leave(next)
    self.level = nil
    self.gameOver = nil
    self.transition = nil
    self.map = nil
    self.background = nil
    self.world:destroy()
    self.world = nil
    self.player = nil
    self.traps = nil
    self.fruits = nil
    self.enemies = nil
    self.checkpointPosition = nil
    self.buttons = nil
    self.gameOverText:release()
    self.gameOverText = nil
    self.pointsText:release()
    self.pointsText = nil
end

return LevelScene
