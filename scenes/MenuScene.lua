local Button = require("utils.Button")
local Background = require("utils.Background")
local CharacterShowcase = require("utils.CharacterShowcase")
local Transition = require("utils.Transition")
local MenuScene = {}

local titleFont = love.graphics.newFont("assets/MinecraftRegular.otf", 45)
local normalFont = love.graphics.newFont("assets/MinecraftRegular.otf", 25)
local backgrounds = {
    love.graphics.newImage("assets/Background/Blue.png"),
    love.graphics.newImage("assets/Background/Brown.png"),
    love.graphics.newImage("assets/Background/Gray.png"),
    love.graphics.newImage("assets/Background/Green.png"),
    love.graphics.newImage("assets/Background/Pink.png"),
    love.graphics.newImage("assets/Background/Purple.png"),
    love.graphics.newImage("assets/Background/Yellow.png")
}
for _, background in ipairs(backgrounds) do
    background:setFilter("linear", "linear")
    background:setWrap("repeat", "repeat")
end
local playImage = love.graphics.newImage("assets/Menu/Buttons/Play.png")
function MenuScene:enter(previous)
    self.transition = Transition:new(-20)
    self.transition.scale = 7
    local backgroundImage = backgrounds[love.math.random(1, #backgrounds)]
    local temp = {-1, 1}
    local backgroundDirection = {temp[love.math.random(1, 2)], temp[love.math.random(1, 2)]}
    temp = nil
    self.background = Background:new(backgroundImage, backgroundDirection, 15)
    self.titleText = love.graphics.newText(titleFont, "FROG:RIO")
    self.characterText = love.graphics.newText(normalFont, "CHOOSE YOUR CHARACTER!")
    self.characterShowcase = CharacterShowcase:new(GAME_DATA.characterId, 368, 250)
    self.buttons = {
        characterShowcase = Button:new(350, 232, 100, 100),
        play = Button:new(300, 380, 200, 200)
    }
    self.buttons.characterShowcase.style = function() end
    self.buttons.characterShowcase.onClick = function()
        self.characterShowcase.characterId = self.characterShowcase.characterId + 1
        if self.characterShowcase.characterId > 4 then self.characterShowcase.characterId = 1 end
        self.characterShowcase:updateCharacter()
        GAME_DATA.characterId = self.characterShowcase.characterId
    end
    self.buttons.play.style = function(button)
        if button.isHovered then love.graphics.setColor(0.7, 0.7, 0.7) end
        love.graphics.draw(playImage, button.x, button.y, 0, button.width / playImage:getWidth(), button.height / playImage:getHeight())
        love.graphics.setColor(1, 1, 1)
    end
    self.buttons.play.onClick = function()
        self.transition.speed = 20
        self.transition.onComplete = function()
            manager:enter(scenes.levelSelected, {backgroundImage = backgroundImage, backgroundDirection = backgroundDirection})
        end
        self.transition.active = true
    end
end

function MenuScene:update(dt)
    self.background:update(dt)
    self.characterShowcase:update(dt)
    for _, btn in pairs(self.buttons) do btn:update() end
    self.transition:update(dt)
end

function MenuScene:draw()
    self.background:draw()
    love.graphics.draw(self.titleText, 400 - self.titleText:getWidth() / 2, 100)
    love.graphics.draw(self.characterText, 400 - self.characterText:getWidth() / 2, 210)
    self.characterShowcase:draw()
    for _, btn in pairs(self.buttons) do btn:draw() end
    love.graphics.rectangle("fill", 200, 330, 400, 2)

    self.transition:draw()
end

function MenuScene:leave(next)
    self.transition = nil
    self.background = nil
    self.titleText = nil
    self.characterText = nil
    self.characterShowcase = nil
    self.buttons = nil
end

function MenuScene:mousepressed(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do btn:mousepressed(x, y, button) end
end

function MenuScene:mousereleased(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do btn:mousereleased(x, y) end
end

return MenuScene