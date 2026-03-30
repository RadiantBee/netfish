local uiElement = require("src/ui/uiElement")

local Button = setmetatable({}, uiElement)
Button.__index = Button

Button.new = function(self, x, y, width, height, text, func, funcArgs)
	assert(x, "Button x is nil")
	assert(y, "Button y is nil")
	assert(width, "Button width is nil")
	assert(height, "Button height is nil")
	local obj = {}
	obj.ox = x
	obj.oy = y
	obj.x = x
	obj.y = y
	obj.width = width
	obj.height = height

	obj.text = text or ""
	obj.func = func
	obj.funcArgs = funcArgs

	obj.textX = 2
	obj.textY = 2

	obj.active = true -- can be pressed
	obj.hide = false -- should be disabled and hidden

	obj.colorIdle = { 1, 1, 1 }
	obj.colorTextIdle = { 1, 1, 1 }
	obj.modeIdle = "line"

	obj.colorHighlighted = { 0.4, 0.4, 0.4 }
	obj.colorTextHighlighted = { 1, 1, 1 }
	obj.modeHighlighted = "fill"

	obj.colorActive = { 1, 1, 1 }
	obj.colorTextActive = { 0, 0, 0 }
	obj.modeActive = "fill"

	obj.colorCurrent = obj.colorIdle
	obj.colorTextCurrent = obj.colorTextIdle
	obj.modeCurrent = obj.modeIdle

	setmetatable(obj, self)
	return obj
end

Button.activate = function(self)
	if self.funcArgs then
		self.func(self.funcArgs)
	else
		self.func()
	end
end

Button.isHighlighted = function(self, mouseX, mouseY)
	if (mouseX > self.x) and (mouseX < self.x + self.width) then
		if (mouseY > self.y) and (mouseY < self.y + self.height) then
			return self.active
		end
	end
	return false
end

Button.mousepressed = function(self, mouseX, mouseY)
	if not self.hide and self:isHighlighted(mouseX, mouseY) then
		self:activate()
		return true
	end
	return false
end

Button.update = function(self, dt, mouseX, mouseY)
	if self.hide or not self.active then
		return
	end
	if not self:isHighlighted(mouseX, mouseY) then
		self.colorCurrent = self.colorIdle
		self.colorTextCurrent = self.colorTextIdle
		self.modeCurrent = self.modeIdle
	else
		if not love.mouse.isDown(1) then
			self.colorCurrent = self.colorHighlighted
			self.colorTextCurrent = self.colorTextHighlighted
			self.modeCurrent = self.modeHighlighted
		else
			self.colorCurrent = self.colorActive
			self.colorTextCurrent = self.colorTextActive
			self.modeCurrent = self.modeActive
		end
	end
end

Button.draw = function(self, x, y)
	self.x = self.ox + x
	self.y = self.oy + y
	if self.hide then
		return
	end
	love.graphics.setColor(self.colorCurrent)
	love.graphics.rectangle(self.modeCurrent, self.x, self.y, self.width, self.height)
	love.graphics.setColor(self.colorTextCurrent)
	love.graphics.print(self.text, self.x + self.textX, self.y + self.textY)
	love.graphics.setColor(self.colorIdle)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1)
end

return Button
