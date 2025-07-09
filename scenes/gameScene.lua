local function distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

local managerChannel = love.thread.getChannel("managerChannel")
local flux = require("libraries.flux")
local json = require("libraries.json")
local sti = require("libraries.sti")
local wf = require("libraries.windfield")
local player__ = require("entities.player")
local button__ = require("ui.button")
local fruit__ = require("fruits.fruit")

local TRAP_ID = {
    ["1"] = require("traps.fallingPlatform"),
    ["2"] = require("traps.fan"),
    ["3"] = require("traps.saw")
}
local FRUIT_SCORE = {
    ["1"] = 10,
    ["2"] = 15,
    ["3"] = 20,
    ["4"] = 25,
    ["5"] = 40,
    ["6"] = 50
}
local ENTITY_ID = {
    ["1"] = require("entities.mushroom"),
    ["2"] = require("entities.ghost"),
    ["3"] = require("entities.fatBird"),
    ["4"] = require("entities.plant")
}

local scene = {}

function scene:enter(previous, args)
    args = args or {}

    self.screenWidth, self.screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

    self.transition = args.transition or false
    self.transitionBackground = love.graphics.newImage("assets/Other/Transition.png")
    self.transitionScale = args.transitionScale or {0}
    self.transitionDir = args.transitionDir or 1
    if self.transitionDir == -1 then
        self.transitionDir = 1
        flux.to(self.transitionScale, 2, {0}):oncomplete(function()
            self.transition = false
        end)
    end

    self.map = sti(args.map)
    self.mapBackground = love.graphics.newImage("assets/Background/" .. self.map.properties.background .. ".png")

    self.world = wf.newWorld(0, 1600)
    self.world:addCollisionClass("platform")
    self.world:addCollisionClass("fallingPlatform")
    self.world:addCollisionClass("player")
    self.world:addCollisionClass("saw")
    self.world:addCollisionClass("fruit")
    self.world:addCollisionClass("enemy")
    self.world:addCollisionClass("bullet")
    for _, v in pairs(self.map.layers["Platform"].objects) do
        local object = self.world:newRectangleCollider(v.x*2, v.y*2 - 40, v.width*2, v.height*2)
        object:setType("static")
        object:setCollisionClass("platform")
    end

    self.traps = {}
    for _, v in pairs(self.map.layers["Trap"].objects) do
        if v.properties.id == "3" then
            local trap = TRAP_ID[v.properties.id]:new(v.polygon, self.world)
            table.insert(self.traps, trap)
        else
            local trap = TRAP_ID[v.properties.id]:new(v.x*2, v.y*2 - 40, self.world)
            table.insert(self.traps, trap)
        end
    end
    
    self.fruits = {}
    for _, v in pairs(self.map.layers["Fruit"].objects) do
        local fruit = fruit__:new(v.x*2, v.y*2 - 40, {id = v.properties.id, score = FRUIT_SCORE[v.properties.id]}, self.world)
        table.insert(self.fruits, fruit)
    end

    self.entities = {}
    for _, v in pairs(self.map.layers["Enemy"].objects) do
        local properties = v.properties
        local entity = ENTITY_ID[properties.id]:new(v.x*2, v.y*2 - 40, properties, self.world)
        table.insert(self.entities, entity)
    end
    
    local playerSpawnPoint = self.map.layers["Player"].objects[1]
    self.player = player__:new(playerSpawnPoint.x*2, playerSpawnPoint.y*2 - 40, self.world)

    local destination = self.map.layers["Destination"].objects[1]
    self.destination = {
        destination.x*2,
        destination.y*2 - 40
    }
    self.destinationShader = love.graphics.newShader("shaders/destinationShader.glsl")
    self.destinationShader:send("position", self.destination)
    self.destinationShader:send("maxDistance", 100)

    self.buttons = {}
    self.buttons.quit = button__:new(self.screenWidth - 51 - 10, 10, 51, 51, love.graphics.newImage("assets/Menu/Buttons/Previous.png"))
    self.buttons.quit.onClick = function()
        self.transition = true
        self.transitionScale = {0}
        flux.to(self.transitionScale, 1, {32}):oncomplete(function()
            managerChannel:push({
                scene = "level",
                args = {
                    transition = true,
                    transitionScale = {32},
                    transitionDir = -1
                }
            })
        end)
    end

    self.levelCompleted = false
    self.completedTitle = love.graphics.newText(love.graphics.getFont(), "LEVEL COMPLETED")
end

function scene:update(dt)
    if self.transition then return end

    if self.levelCompleted then
        for _, button in pairs(self.buttons) do
            button:update()
        end
        return 
    end

    self.world:update(dt)
    self.map:update(dt)

    self.player:update(dt)
    if distance(self.player.collider:getX(), self.player.collider:getY(), self.destination[1], self.destination[2]) <= 30 then
        self.levelCompleted = true
        self.buttons.quit.width, self.buttons.quit.height = 81, 82
        self.buttons.quit.x, self.buttons.quit.y = self.screenWidth/2 - 81/2, 145

        local levelData = json.decode(love.filesystem.read("levelData.json"))
        if #levelData.unlockedLevel < levelData.maxLevel then
            table.insert(levelData.unlockedLevel, #levelData.unlockedLevel + 1)
        end
        love.filesystem.write("levelData.json", json.encode(levelData))
        return
    end

    for i, v in pairs(self.traps) do
        if v.collider:isDestroyed() then
            v.collider:release()
            table.remove(self.traps, i)
        else
            if v.id == 2 then
                v:update(dt, self.player)
                goto continue
            end
            v:update(dt)
        end
        ::continue::
    end

    for i, v in pairs(self.fruits) do
        if v.collider:isDestroyed() then
            v.collider:release()
            table.remove(self.fruits, i)
        else
            v:update(dt)
        end
    end

    for i, v in pairs(self.entities) do
        if v.collider:isDestroyed() then
            v.collider:release()
            table.remove(self.entities, i)
        else
            v:update(dt)
        end
    end

    for _, button in pairs(self.buttons) do
        button:update()
    end
end

function scene:draw()
    if self.levelCompleted then love.graphics.setColor(0.5, 0.5, 0.5) end

    love.graphics.draw(self.mapBackground, 0, 0, 0, self.screenWidth/self.mapBackground:getWidth(), self.screenHeight/self.mapBackground:getHeight())
    self.map:draw(0, -20, 2, 2)

    love.graphics.setColor(0.5, 1.0, 0.5, 0.6)
    if self.levelCompleted then love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.setShader(self.destinationShader)
    love.graphics.rectangle("fill", self.destination[1] - 32, self.destination[2] - 200, 64, 200)
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1)
    if self.levelCompleted then love.graphics.setColor(0.5, 0.5, 0.5) end

    self.player:draw()

    for _, v in pairs(self.traps) do
        v:draw()
    end

    for _, v in pairs(self.fruits) do
        v:draw()
    end

    for _, v in pairs(self.entities) do
        v:draw()
    end

    if self.levelCompleted then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.completedTitle, self.screenWidth/2 - self.completedTitle:getWidth()/2, 100)
    end

    for _, button in pairs(self.buttons) do
        button:draw()
    end

    -- self.world:draw()
    
    -- love.graphics.print("Traps: " .. #self.traps .. " | Fruits: " .. #self.fruits .. " Entities: " .. #self.entities .. " | Draw Call: " .. love.graphics.getStats().drawcalls .. " | Fps: " .. love.timer.getFPS())

    if not self.transition then
        return
    end

    local img = self.transitionBackground
    local scale = self.transitionScale[1]
    local drawX = self.screenWidth/2 - (img:getWidth()*scale)/2
    local drawY = self.screenHeight/2 - (img:getHeight()*scale)/2

    love.graphics.draw(img, drawX, drawY, 0, scale, scale)
end

function scene:mousepressed(x, y, button, istouch, presses)
    if self.transition then return end

    for _, btn in pairs(self.buttons) do
        btn:mousepressed(x, y, button)
    end
    --[[
    self.transition = true
    self.transitionScale = {0}
    flux.to(self.transitionScale, 1, {32}):oncomplete(function()
        managerChannel:push({
            scene = "menu",
            args = {
                transition = true,
                transitionScale = {32},
                transitionDir = -1
            }
        })
    end)
    --]]
end

function scene:leave()
    self.screenWidth = nil
    self.screenHeight = nil
    self.transition = nil
    self.transitionBackground:release()
    self.transitionBackground = nil
    self.transitionScale = nil
    self.transitionDir = nil

    self.map = nil
    self.mapBackground:release()
    self.mapBackground = nil

    self.world:destroy()
    self.world = nil

    self.traps = {}
    self.fruits = {}
    self.entities = {}

    self.player = nil

    self.destination = nil
    self.destinationShader:release()
    self.destinationShader = nil

    for _, button in pairs(self.buttons) do
        button:release()
    end
    self.buttons = nil

    self.levelCompleted = nil
    collectgarbage("collect")

    -- print("Garbage Collected: Game")
end

return scene