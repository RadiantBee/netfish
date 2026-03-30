-- Importing ui element classes
local uiElement = require("src/ui/uiElement")
local Button = require("src/ui/button")
local ProgressBar = require("src/ui/progressBar")
local Entry = require("src/ui/entry")
local Slider = require("src/ui/slider")
local Label = require("src/ui/label")
local utils = require("src/utils")

local Overlay = setmetatable({}, uiElement)
Overlay.__index = Overlay

Overlay.new = function(self, x, y, width, height, isActive)
	local obj = {}
	assert(x, "Overlay x is nil")
	assert(y, "Overlay y is nil")
	assert(width, "Overlay width is nil")
	assert(height, "Overlay height is nil")
	obj.ox = x
	obj.oy = y
	obj.x = x
	obj.y = y
	obj.width = width
	obj.height = height
	obj.isActive = isActive or true
	obj.isHidden = false
	obj.bgColor = { 0, 0, 0 }
	obj.borderColor = { 1, 1, 1 }
	obj.isMouseInside = false
	obj.headerOffset = 0

	obj.elements = {}

	obj.mousepressWasProcessed = false
	obj.mousereleaseWasProcessed = false
	obj.keypressWasProcessed = false

	setmetatable(obj, self)
	return obj
end

Overlay.configureHeader = function(self, title, isMovable, isHidable, isCloseable)
	self.headerActive = true
	self.title = title or ""
	self.titleHeight = 20
	self.isMovable = isMovable or true
	self.isHidable = isHidable or true
	self.isCloseable = isCloseable or true
	self.headerOffset = 20
	local offsetCounter = 0

	if self.isCloseable then
		offsetCounter = offsetCounter + 20
		self.closeButton = self:newButton(self.width - 20, -20, 20, 20, "X", function(self)
			self.isActive = false
		end, self)
		self.closeButton.textX = 6
		self.closeButton.colorHighlighted = { 1, 0, 0 }
	end

	if self.isHidable then
		offsetCounter = offsetCounter + 20
		self.hideButton = self:newButton(self.width - 40, -20, 20, 20, "^", function(self)
			if self.isHidden then
				self.hideButton.text = "^"
				self.hideButton.textX = 5
			else
				self.hideButton.text = "V"
				self.hideButton.textX = 6
			end
			self.isHidden = not self.isHidden
		end, self)
		self.hideButton.textX = 5
	end

	self.titleBlock = self:newButton(0, -20, self.width - offsetCounter, 20, self.title)
	self.titleBlock.update = function(self, dt, mouseX, mouseY) end

	if self.isMovable then
		self.shouldMove = false
		self.titleBlock.mousepressed = function(self, mouseX, mouseY)
			if not self.hide and self:isHighlighted(mouseX, mouseY) then
				self.shouldMove = true
				return true
			end
			return false
		end

		self.titleBlock.mousereleased = function(self, mouseX, mouseY)
			if not self.hide and self.shouldMove then
				self.shouldMove = false
				return true
			end
			return false
		end
	end
end

Overlay.newButton = function(self, x, y, width, height, text, func, funcArgs)
	local button = Button:new(x, y, width, height, text, func, funcArgs)
	utils.addToList(self.elements, button)
	button.parent = self
	return button
end

Overlay.newSlider = function(self, x, y, width, height, maxValue, bWidth, bHeight, value, showText, color)
	local slider = Slider:new(x, y, width, height, maxValue, bWidth, bHeight, value, showText, color)
	utils.addToList(self.elements, slider)
	slider.parent = self
	return slider
end

Overlay.newProgressBar = function(self, x, y, width, height, maxValue, value, showText, color)
	local progressBar = ProgressBar:new(x, y, width, height, maxValue, value, showText, color)
	utils.addToList(self.elements, progressBar)
	progressBar.parent = self
	return progressBar
end
Overlay.newLabel = function(self, x, y, text)
	local label = Label:new(text, x, y)
	utils.addToList(self.elements, label)
	label.parent = self
	return label
end

Overlay.newEntry = function(self, x, y, width, height, onEnterFunc, onEnterFuncArgs)
	local entry = Entry:new(x, y, width, height, onEnterFunc, onEnterFuncArgs)
	utils.addToList(self.elements, entry)
	entry.parent = self
	return entry
end

Overlay.newElement = function(self)
	local elem = uiElement:new()
	utils.addToList(self.elements, elem)
	elem.parent = self
	return elem
end

Overlay.newOverlay = function(self, x, y, width, height, isActive)
	local ov = Overlay:new(x, y, width, height, isActive)
	utils.addToList(self.elements, ov)
	ov.parent = self
	return ov
end

Overlay.add = function(self, obj) -- preferably for overlays
	utils.addToList(self.elements, obj)
	obj.parent = self
	if obj.elements then -- safeguard in case it's not overlay
		for i = #obj.elements, 1, -1 do -- invoking load
			obj.elements[i]:load()
		end
	end
	return obj
end

Overlay.isInside = function(self, x, y)
	if x > self.x and y > self.y then
		if x < self.x + self.width and y < self.y + self.height then
			return true
		end
	end
	return false
end

Overlay.mousepressed = function(self, x, y, button)
	self.mousepressWasProcessed = false
	if not self.isActive then
		return self.mousepressWasProcessed
	end
	if self.isHidden then
		if self.isMovable then
			self.mousepressWasProcessed = self.titleBlock:mousepressed(x, y, button)
		end
		if self.isHidable and not self.mousepressWasProcessed then
			self.mousepressWasProcessed = self.hideButton:mousepressed(x, y, button)
		end
		if self.isCloseable and not self.mousepressWasProcessed then
			self.mousepressWasProcessed = self.closeButton:mousepressed(x, y, button)
		end
		return self.mousepressWasProcessed
	end
	if not self:isInside(x, y) then
		return self.mousepressWasProcessed
	end
	for i = #self.elements, 1, -1 do
		if self.mousepressWasProcessed then
			break
		end
		self.mousepressWasProcessed = self.elements[i]:mousepressed(x, y, button)
	end
	self.mousepressWasProcessed = true
	return self.mousepressWasProcessed
end
Overlay.mousereleased = function(self, x, y, button)
	self.mousereleaseWasProcessed = false
	if not self.isActive then
		return self.mousereleaseWasProcessed
	end
	if self.isHidden then
		if self.isMovable then
			self.mousereleaseWasProcessed = self.titleBlock:mousereleased(x, y, button)
		end
		if self.isHidable and not self.mousereleaseWasProcessed then
			self.mousereleaseWasProcessed = self.hideButton:mousereleased(x, y, button)
		end
		if self.isCloseable and not self.mousereleaseWasProcessed then
			self.mousereleaseWasProcessed = self.closeButton:mousereleased(x, y, button)
		end
		return self.mousereleaseWasProcessed
	end

	for i = #self.elements, 1, -1 do
		if self.mousereleaseWasProcessed then
			break
		end
		self.mousereleaseWasProcessed = self.elements[i]:mousereleased(x, y, button)
	end
	return self.mousereleaseWasProcessed
end
Overlay.keypressed = function(self, key)
	self.keypressWasProcessed = false
	if not self.isActive or self.isHidden then
		return self.keypressWasProcessed
	end
	for i = #self.elements, 1, -1 do
		if self.keypressWasProcessed then
			break
		end
		self.keypressWasProcessed = self.elements[i]:keypressed(key)
	end
	return self.keypressWasProcessed
end
Overlay.update = function(self, dt, mouseX, mouseY)
	if not self.isActive then
		return
	end
	if self.isMovable and self.titleBlock.shouldMove then
		self.ox = mouseX - self.width / 2
		self.oy = mouseY - self.titleHeight / 2
	end
	if self.isHidden then
		if self.isHidable then
			self.hideButton:update(dt, mouseX, mouseY)
		end
		if self.isCloseable then
			self.closeButton:update(dt, mouseX, mouseY)
		end
		return
	end
	for i = #self.elements, 1, -1 do
		self.elements[i]:update(dt, mouseX, mouseY)
	end
end
Overlay.draw = function(self, x, y)
	if not self.isActive then
		return
	end
	self.x = self.ox + x
	self.y = self.oy + y
	if self.isHidden then
		love.graphics.setColor(self.bgColor)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.titleHeight)
		self.titleBlock:draw(self.x, self.y + self.headerOffset)
		if self.isHidable then
			self.hideButton:draw(self.x, self.y + self.headerOffset)
		end
		if self.isCloseable then
			self.closeButton:draw(self.x, self.y + self.headerOffset)
		end
		return
	end
	love.graphics.setColor(self.bgColor)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1)

	for i = 1, #self.elements, 1 do -- NOTE: might be unreliable or even unsafe
		self.elements[i]:draw(self.x, self.y + self.headerOffset)
	end
	--[[
	for i = #self.elements, 1, -1 do
		self.elements[i]:draw()
	end
	--]]
end

return Overlay
