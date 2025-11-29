local states = {}

states.offline = require("src/states/offline")

states.current = states.offline

states.changeTo = function(name)
	assert(states[name], "No state named '" .. name .. "' was found to change to!")
	assert(states[name].isState, "states." .. name .. " - is not a state!")
	states.current = states[name]
	collectgarbage()
	states.current:load(states.changeTo)
end

states.mouse = {}
states.mouse.x = 0
states.mouse.y = 0

states.mousepressed = function(self, x, y)
	self.current:mousepressed(x, y)
end

states.keypressed = function(self, key)
	self.current:keypressed(key)
end

states.load = function(self)
	self.current:load(self.changeTo)
end

states.update = function(self, dt)
	self.mouse.x, self.mouse.y = love.mouse.getPosition()
	self.current:update()
end

states.draw = function(self)
	self.current:draw(self.mouse.x, self.mouse.y)
end

return states
