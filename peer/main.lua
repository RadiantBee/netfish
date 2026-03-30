local main = require("src/overlays/main")

local mouseIdle = love.mouse.newCursor("img/cursor.png", 2, 2)
local mouseActive = love.mouse.newCursor("img/cursorClick.png", 2, 2)

local mouseX = 0
local mouseY = 0

function love.load()
	love.mouse.setCursor(mouseIdle)
end

function love.mousepressed(x, y, button)
	love.mouse.setCursor(mouseActive)
	main:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	love.mouse.setCursor(mouseIdle)
	main:mousereleased(x, y, button)
end

function love.keypressed(key)
	main:keypressed(key)
end

function love.update(dt)
	mouseX = love.mouse.getX()
	mouseY = love.mouse.getY()
	main:update(dt, mouseX, mouseY)
end

function love.draw()
	main:draw(0, 0)
end
