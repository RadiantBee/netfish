local states = require("src/states")

function love.load()
	print("[*] Welcome to NetFiSh!")
	print("[*] Client version: 0.0.1")
	print("[*] Made by MaxPan\n")
	states:load()
end

function love.mousepressed(x, y)
	states:mousepressed(x, y)
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
