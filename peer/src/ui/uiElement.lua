local uiElement = {}
uiElement.__index = uiElement

uiElement.new = function(self)
	local obj = {}
	setmetatable(obj, self)
	return obj
end

uiElement.load = function(self) end
uiElement.mousepressed = function(self, x, y)
	return false
end
uiElement.mousereleased = function(self, x, y)
	return false
end
uiElement.keypressed = function(self, key)
	return false
end
uiElement.update = function(self, dt, mouseX, mouseY) end
uiElement.draw = function(self, x, y) end

return uiElement
