local states = require("src/states")

function love.load()
	states:load()
end

function love.mousepressed(x, y)
	states:mousepressed(x, y)
end

function love.update(dt)
	states:update(dt)
end

function love.draw()
	states:draw()
end
