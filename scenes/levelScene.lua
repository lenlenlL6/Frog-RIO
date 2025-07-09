local managerChannel = love.thread.getChannel("managerChannel")
local sti = require("libraries.sti")
local json = require("libraries.json")
local flux = require("libraries.flux")
local button__ = require("ui.button")
local slider__ = require("ui.slider")
local scene = {}

function scene:enter(previous, args)
    args = args or {}
    love.graphics.setBackgroundColor(0.18, 0.18, 0.18)

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

    self.map = sti("maps/menu.lua")

    self.buttons = {}
    self.buttons.quit = button__:new(10, self.screenHeight - 52 - 10, 51, 52, love.graphics.newImage("assets/Menu/Buttons/Restart.png"))
    self.buttons.quit.onClick = function()
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
    end
    self.buttons.volume = slider__:new(self.screenWidth - 51 - 10, self.screenHeight - 52 - 10, 51, 52, love.graphics.newImage("assets/Menu/Buttons/Volume.png"), 51, 100)
    
    self.levelData = json.decode(love.filesystem.read("levelData.json"))

    self.levels = {}
    local maxLevel = self.levelData.maxLevel
    local levelPerCell = 4
    local totalWidth = levelPerCell*89 + (levelPerCell - 1)*10
    local startX, startY = self.screenWidth/2 - totalWidth/2, 250
    for i = 0, maxLevel - 1 do
        local button = button__:new(startX + (i%levelPerCell)*89 + (i%levelPerCell)*10, startY + (math.floor(i/levelPerCell))*87 + (math.floor(i/levelPerCell))*10, 89, 87,
                                    love.graphics.newImage("assets/Menu/Levels/" .. ((i + 1 < 10) and ("0"..(i + 1)) or (i + 1)) .. ".png"))
        button.onClick = function()
            if i + 1 > #self.levelData.unlockedLevel then return end

            self.transition = true
            self.transitionScale = {0}
            flux.to(self.transitionScale, 1, {32}):oncomplete(function()
                managerChannel:push({
                    scene = "game",
                    args = {
                        transition = true,
                        transitionScale = {32},
                        transitionDir = -1,
                        map = "maps/map" .. (i + 1) .. ".lua"
                    }
                })
            end)
        end
        table.insert(self.levels, button)
    end

    self.title = love.graphics.newText(love.graphics.getFont(), "SELECT LEVEL")
    self.titleAlpha = 1
end

function scene:update(dt)
    if self.transition then return end
    
    if not self.decreaseFlux then
        self.decreaseFlux = flux.to(self, 2, {titleAlpha = 0}):after(self, 2, {titleAlpha = 1}):oncomplete(function()
            self.decreaseFlux = nil
        end)
    end

    for _, button in pairs(self.buttons) do
        button:update()
    end
    for _, button in pairs(self.levels) do
        button:update()
    end
end

function scene:draw()
    self.map:draw(0, -20, 2, 2)

    for i, button in pairs(self.buttons) do
        button:draw()
    end

    for i, button in pairs(self.levels) do
        button:draw(i > #self.levelData.unlockedLevel and {1, 1, 1, 0.5} or nil)
    end
    love.graphics.setColor(1, 1, 1, self.titleAlpha)
    love.graphics.draw(self.title, self.screenWidth/2 - self.title:getWidth()/2, 100)
    love.graphics.setColor(1, 1, 1)

    if not self.transition then return end

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

    for _, btn in pairs(self.buttons) do
        btn:mousepressed(x, y, button)
    end

    for _, btn in pairs(self.levels) do
        btn:mousepressed(x, y, button)
    end

    --[[
    self.transition = true
    self.transitionScale = {0}
    flux.to(self.transitionScale, 1, {32}):oncomplete(function()
        managerChannel:push({
            scene = "game",
            args = {
                transition = true,
                transitionScale = {32},
                transitionDir = -1
            }
        })
    end)
    --]]
end

function scene:mousereleased(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do
        btn:mousereleased(x, y, button)
    end
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

    for _, button in pairs(self.buttons) do
        button:release()
    end
    self.buttons = nil

    self.levelData = nil
    for _, button in pairs(self.levels) do
        button:release()
    end
    self.levels = nil

    self.title:release()
    self.title = nil
    self.titleAlpha = nil
    if self.decreaseFlux then self.decreaseFlux:stop() end
    self.decreaseFlux = nil
    collectgarbage("collect")

    -- print("Garbage Collected: Level")
end

return scene