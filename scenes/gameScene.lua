local managerChannel = love.thread.getChannel("managerChannel")
local flux = require("libraries.flux")
local sti = require("libraries.sti")
local wf = require("libraries.windfield")
local player__ = require("entities.player")
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
    ["1"] = require("entities.mushroom")
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
end

function scene:update(dt)
    if self.transition then
        flux.update(dt)
        return
    end

    self.world:update(dt)
    self.map:update(dt)

    self.player:update(dt)

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
end

function scene:draw()
    love.graphics.draw(self.mapBackground, 0, 0, 0, self.screenWidth/self.mapBackground:getWidth(), self.screenHeight/self.mapBackground:getHeight())
    self.map:draw(0, -20, 2, 2)
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

    self.world:draw()
    
    love.graphics.print("Traps: " .. #self.traps .. " | Fruits: " .. #self.fruits .. " Entities: " .. #self.entities .. " | Draw Call: " .. love.graphics.getStats().drawcalls .. " | Fps: " .. love.timer.getFPS())

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
    if self.transition then
        return
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
    self.world:release()
    self.world = nil

    self.traps = {}
    self.fruits = {}
    self.entities = {}

    self.player = nil
    collectgarbage("collect")

    -- print("Garbage Collected: Game")
end

return scene