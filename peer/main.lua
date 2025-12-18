local states = require("src/states")
local netThread = love.thread.newThread("src/network.lua")
local netComms = love.thread.getChannel("NET")

function love.load()
	print("[*] Welcome to NetFiSh!")
	print("[*] Client version: 0.0.1")
	print("[*] Made by MaxPan\n")
	netThread:start()
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
