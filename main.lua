love.graphics.setDefaultFilter("nearest", "nearest")
local flux = require("libraries.flux")
local manager = require("libraries.roomy").new()
local managerChannel = love.thread.getChannel("managerChannel")
local scenes = {
    menu = require("scenes.menuScene"),
    game = require("scenes.gameScene")
}

local font = love.graphics.newFont("fonts/MinecraftRegular-Bmg3.otf", 28)
love.graphics.setFont(font)

function love.load()
    local icon = love.image.newImageData("icon.png")
    love.window.setTitle("Frog:RIO")
    love.window.setIcon(icon)

    -- love._openConsole()
    manager:enter(scenes.game, {
        map = "maps/map1.lua"
    })
end

function love.update(dt)
    local message = managerChannel:pop()
    if message then
        manager:enter(scenes[message.scene], message.args)
    end

    flux.update(dt)
    manager:emit("update", dt)
end

function love.draw()
    manager:emit("draw")
end

function love.mousepressed(x, y, button, istouch, presses)
    manager:emit("mousepressed", x, y, button, istouch, presses)
end