local VERSION = "2.0.2"

_G.love = love

love.graphics.setDefaultFilter("nearest", "nearest")
love.math.setRandomSeed(os.time())
local bitser = require("libraries.bitser")
local flux = require("libraries.flux")
local roomy = require("libraries.roomy")
_G.shack = require("libraries.shack")
_G.manager = roomy.new()
_G.scenes = {
    menu = require("scenes.MenuScene"),
    levelSelected = require("scenes.LevelSelectedScene"),
    level = require("scenes.LevelScene")
}
_G.CHARACTER_ID = {
    "Mask Dude",
    "Ninja Frog",
    "Pink Man",
    "Virtual Guy"
}
_G.TRAP_ID = {
    require("traps.Arrow"),
    require("traps.FallingPlatform"),
    require("traps.Fan"),
    require("traps.Fire"),
    require("traps.Saw"),
    require("traps.Spike"),
    require("traps.Trampoline"),
    require("traps.SpikedBall")
}
_G.ENEMY_ID = {
    require("entities.AngryPig"),
    require("entities.Bat"),
    require("entities.Bee"),
    require("entities.BlueBird")
}
_G.GAME_DATA = {}

function love.load()
    -- love._openConsole()
    love.keyboard.setKeyRepeat(false)
    love.window.setTitle("Frog:RIO")
    shack:setDimensions(800, 600)
    if not love.filesystem.getInfo("gameData") then
        bitser.dumpLoveFile("gameData", {
            characterId = 1,
            level = 1,
            maxLevel = 3
        })
    end
    GAME_DATA = bitser.loadLoveFile("gameData")
    manager:enter(scenes.menu)
end

function love.update(dt)
    flux.update(dt)
    manager:emit("update", dt)
    shack:update(dt)
end

function love.draw()
    shack:apply()
    manager:emit("draw")
    love.graphics.print("v" .. VERSION, 0, 586)

    --[[
    love.graphics.print("FPS: " .. love.timer.getFPS())
    love.graphics.print("Draw Calls: " .. love.graphics.getStats().drawcalls, 0, 16)
    --]]
end

function love.mousepressed(x, y, button, istouch, presses)
    manager:emit("mousepressed", x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    manager:emit("mousereleased", x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isrepeat)
    manager:emit("keypressed", key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    manager:emit("keyreleased", key, scancode)
end

function love.quit()
    bitser.dumpLoveFile("gameData", GAME_DATA)
end
