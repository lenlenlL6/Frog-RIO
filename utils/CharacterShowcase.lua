local anim8 = require("libraries.anim8")
local CharacterShowcase = {}

local characterImages = {
    love.graphics.newImage("assets/Main Characters/Mask Dude/Idle (32x32).png"),
    love.graphics.newImage("assets/Main Characters/Ninja Frog/Idle (32x32).png"),
    love.graphics.newImage("assets/Main Characters/Pink Man/Idle (32x32).png"),
    love.graphics.newImage("assets/Main Characters/Virtual Guy/Idle (32x32).png")
}
local grid = anim8.newGrid(32, 32, characterImages[1]:getWidth(), characterImages[1]:getHeight())
local animation = anim8.newAnimation(grid("1-11", 1), 0.1)

function CharacterShowcase:new(characterId, x, y)
    local object = {
        characterId = characterId,
        image = characterImages[characterId],
        animation = animation:clone(),
        x = x, y = y
    }
    self.__index = self

    return setmetatable(object, self)
end

function CharacterShowcase:update(dt)
    self.animation:update(dt)
end

function CharacterShowcase:draw()
    self.animation:draw(self.image, self.x, self.y, 0, 2, 2)
end

function CharacterShowcase:updateCharacter()
    self.image = characterImages[self.characterId]
end

return CharacterShowcase