local managerChannel = love.thread.getChannel("managerChannel")
local flux = require("libraries.flux")
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
end

function scene:update(dt)
    if self.transition then
        flux.update(dt)
        return
    end
end

function scene:draw()
    love.graphics.print("Main")

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
end

function scene:leave()
    self.screenWidth = nil
    self.screenHeight = nil
    self.transition = nil
    self.transitionBackground:release()
    self.transitionBackground = nil
    self.transitionScale = nil
    self.transitionDir = nil
    collectgarbage("collect")

    -- print("Garbage Collected: Menu")
end

return scene