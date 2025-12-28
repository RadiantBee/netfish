local states = require("src/states")
local netThread = love.thread.newThread("src/network.lua")

local mouseIdle = love.mouse.newCursor("img/cursor.png", 2, 2)
local mouseActive = love.mouse.newCursor("img/cursorClick.png", 2, 2)

function love.load()
	love.mouse.setCursor(mouseIdle)
	print("[*] Welcome to NetFiSh!")
	print("[*] Client version: 0.0.1")
	print("[*] Made by MaxPan")
	netThread:start()
	states:load()
end

function love.mousepressed(x, y)
	love.mouse.setCursor(mouseActive)
	states:mousepressed(x, y)
end

function love.mousereleased()
	love.mouse.setCursor(mouseIdle)
end

function love.keypressed(key)
	states:keypressed(key)
end

function love.update(dt)
	states:update(dt)
end

function love.draw()
	states:draw()
end
