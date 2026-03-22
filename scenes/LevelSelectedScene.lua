local Button = require("utils.Button")
local Background = require("utils.Background")
local Transition = require("utils.Transition")
local LevelSelectedScene = {}

local leaveImage = love.graphics.newImage("assets/Menu/Buttons/Previous.png")
local titleFont = love.graphics.newFont("assets/MinecraftRegular.otf", 45)
function LevelSelectedScene:enter(previous, args)
    self.transition = Transition:new(-20)
    self.transition.scale = 7
    self.background = Background:new(args.backgroundImage, args.backgroundDirection, 15)
    self.titleText = love.graphics.newText(titleFont, "SELECT LEVEL")
    self.buttons = {
        leave = Button:new(745, 5, 50, 50)
    }
    self.buttons.leave.style = function(button)
        if button.isHovered then love.graphics.setColor(0.7, 0.7, 0.7) end
        love.graphics.draw(leaveImage, button.x, button.y, 0, button.width / leaveImage:getWidth(), button.height / leaveImage:getHeight())
        love.graphics.setColor(1, 1, 1)
    end
    self.buttons.leave.onClick = function()
        self.transition.speed = 20
        self.transition.onComplete = function()
            manager:enter(scenes.menu)
        end
        self.transition.active = true
    end
    local maxLevel = GAME_DATA.maxLevel
    local levelSize = 120
    local totalWidth = 5 * levelSize + 20
    for i = 0, maxLevel - 1 do
        local y = math.floor(i / 5)
        local x = i - y * 5
        table.insert(self.buttons, Button:new((400 - totalWidth / 2) + x * (levelSize + 5), 200 + y * (levelSize + 5), levelSize, levelSize))
        local btn = self.buttons[#self.buttons]
        btn.index = i + 1
        btn.image = love.graphics.newImage(string.format("assets/Menu/Levels/%s.png", (i <= 8) and ("0" .. (i + 1)) or (i + 1)))
        btn.style = function(button)
            if button.isHovered then love.graphics.setColor(0.7, 0.7, 0.7) end
            if button.index > GAME_DATA.level then love.graphics.setColor(0.3, 0.3, 0.3) end
            love.graphics.draw(button.image, button.x, button.y, 0, button.width / button.image:getWidth(), button.height / button.image:getHeight())
            love.graphics.setColor(1, 1, 1)
        end
        btn.onClick = function(button)
            if button.index > GAME_DATA.level then return end
            self.transition.speed = 20
            self.transition.onComplete = function()
                manager:enter(scenes.level, {level = button.index})
            end
            self.transition.active = true
        end
    end
end

function LevelSelectedScene:update(dt)
    self.background:update(dt)
    for _, btn in pairs(self.buttons) do btn:update() end
    self.transition:update(dt)
end

function LevelSelectedScene:draw()
    self.background:draw()
    love.graphics.draw(self.titleText, 400 - self.titleText:getWidth() / 2, 100)
    for _, btn in pairs(self.buttons) do btn:draw() end

    self.transition:draw()
end

function LevelSelectedScene:leave(next)
    self.transition = nil
    self.background = nil
    self.titleText = nil
    self.buttons = nil
end

function LevelSelectedScene:mousepressed(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do btn:mousepressed(x, y, button) end
end

function LevelSelectedScene:mousereleased(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do btn:mousereleased(x, y) end
end

return LevelSelectedScene
