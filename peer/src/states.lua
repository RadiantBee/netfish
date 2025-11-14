local states = {}

states.current = nil

states.mouse = {}
states.mouse.x = 0
states.mouse.y = 0

states.load = function(self) end
states.update = function(self, dt) end
states.draw = function(self) end

return states
