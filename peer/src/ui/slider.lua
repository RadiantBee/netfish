local ProgressBar = require("src/ui/progressBar")
local Button = require("src/ui/button")

local Slider = setmetatable({}, ProgressBar)
Slider.__index = Slider

Slider.new = function(self, x, y, width, height, maxValue, bWidth, bHeight, value, showText, color)
	assert(x, "Slider x is nil")
	assert(y, "Slider y is nil")
	assert(width, "Slider width is nil")
	assert(height, "Slider height is nil")
	assert(maxValue, "Slider maxValue is nil")
	local obj = ProgressBar:new(x, y, width, height, maxValue, value, showText, color)

	obj.button = Button:new(
		obj.x - obj.width * 0.05,
		obj.y - obj.height * 0.25,
		bWidth or obj.width * 0.1,
		bHeight or obj.height * 1.5
	)
	obj.button.shouldMove = false

	obj.button.mousepressed = function(self, mouseX, mouseY)
		if not self.hide and self:isHighlighted(mouseX, mouseY) then
			self.shouldMove = true
			return true
		end
		return false
	end

	obj.button.mousereleased = function(self, mouseX, mouseY)
		if not self.hide and self.shouldMove then
			self.shouldMove = false
			return true
		end
		return false
	end

	setmetatable(obj, self)
	return obj
end

Slider.mousepressed = function(self, mouseX, mouseY)
	return self.button:mousepressed(mouseX, mouseY)
end
Slider.mousereleased = function(self, mouseX, mouseY)
	return self.button:mousereleased(mouseX, mouseY)
end

Slider.update = function(self, dt, mouseX, mouseY)
	self.button:update(dt, mouseX, mouseY)
	if self.button.shouldMove then
		if mouseX >= self.x and mouseX <= self.x + self.width then
			self.button.ox = mouseX - self.x + self.button.width
		end
	end
	self:setValue(((self.button.x + self.button.width / 2 - self.x) / self.width) * self.maxValue)
end

Slider.draw = function(self, x, y)
	ProgressBar.draw(self, x, y)
	self.button:draw(x, y)
end

return Slider
