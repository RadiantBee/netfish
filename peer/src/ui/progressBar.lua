local uiElement = require("src/ui/uiElement")

local ProgressBar = setmetatable({}, uiElement)
ProgressBar.__index = ProgressBar

ProgressBar.new = function(self, x, y, width, height, maxValue, value, showText, color)
	assert(x, "ProgressBar x is nil")
	assert(y, "ProgressBar y is nil")
	assert(width, "ProgressBar width is nil")
	assert(height, "ProgressBar height is nil")
	assert(maxValue, "ProgressBar maxValue is nil")
	local obj = {}
	obj.ox = x
	obj.oy = y
	obj.x = x
	obj.y = y
	obj.width = width
	obj.height = height
	obj.maxValue = maxValue
	obj.value = value or 0
	obj.textX = 5
	obj.textY = 3

	obj.showText = showText or false

	obj.color = color or { 1, 1, 1 }
	obj.textColor = { 0, 0, 0 }

	setmetatable(obj, self)
	return obj
end

ProgressBar.addValue = function(self, value)
	if self.value + value >= self.maxValue then
		self.value = self.maxValue
	elseif self.value + value <= 0 then
		self.value = 0
	else
		self.value = self.value + value
	end
end
ProgressBar.setValue = function(self, value)
	if value >= self.maxValue then
		self.value = self.maxValue
	elseif value <= 0 then
		self.value = 0
	else
		self.value = value
	end
end
ProgressBar.isFull = function(self)
	return self.value == self.maxValue
end

ProgressBar.ifEmpty = function(self)
	return self.value == 0
end
ProgressBar.showTextToggle = function(self)
	self.showText = not self.showText
end

ProgressBar.draw = function(self, x, y)
	self.x = self.ox + x
	self.y = self.oy + y
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.x, self.y, self.width * (self.value / self.maxValue), self.height)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	if self.showText then
		if self.value / self.maxValue >= 0.10 then --NOTE: treshold for coloring text
			love.graphics.setColor(self.textColor)
		else
			love.graphics.setColor(self.color)
		end
		love.graphics.print(self.value, self.x + self.textX, self.y + self.textY)
		love.graphics.setColor(1, 1, 1)
	end
end
return ProgressBar
