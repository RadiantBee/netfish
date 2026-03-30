local uiElement = require("src/ui/uiElement")

local Label = setmetatable({}, uiElement)
Label.__index = Label

Label.new = function(self, text, x, y)
	assert(x, "Label x is nil")
	assert(y, "Label y is nil")
	local obj = {}
	obj.ox = x
	obj.oy = y
	obj.x = x
	obj.y = y
	obj.text = text or ""
	obj.hide = false
	setmetatable(obj, self)
	return obj
end

Label.dynamicText = nil

Label.draw = function(self, x, y)
	self.x = self.ox + x
	self.y = self.oy + y
	if self.hide then
		return
	end
	if self.dynamicText then
		self:dynamicText()
	end
	love.graphics.print(self.text, self.x, self.y)
end

return Label
