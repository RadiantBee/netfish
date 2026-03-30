local uiElement = require("src/ui/uiElement")

local Entry = setmetatable({}, uiElement)
Entry.__index = Entry

Entry.new = function(self, x, y, width, height, onEnterFunc, onEnterFuncArgs)
	assert(x, "Entry x is nil")
	assert(y, "Entry y is nil")
	assert(width, "Entry width is nil")
	assert(height, "Entry height is nil")
	local obj = {}
	obj.text = ""
	obj.ox = x
	obj.oy = y
	obj.x = x
	obj.y = y
	obj.width = width
	obj.height = height

	obj.onEnterFunc = onEnterFunc
	obj.onEnterFuncArgs = onEnterFuncArgs

	obj.onKeyPress = nil
	obj.onKeyPressArgs = nil

	obj.textX = 2
	obj.textY = 2

	obj.colorActive = { 1, 1, 1 }
	obj.colorPassive = { 0, 0, 0 }

	obj.colorTextCurrent = { 1, 1, 1 }
	obj.colorCurrent = { 0, 0, 0 }

	setmetatable(obj, self)
	return obj
end

Entry.mousepressed = function(self, mouseX, mouseY)
	if (mouseX > self.x) and (mouseX < self.x + self.width) then
		if (mouseY > self.y) and (mouseY < self.y + self.height) then
			self.active = not self.active
			return true
		end
	end
	self.active = false
	return false
end

Entry.keypressed = function(self, key)
	if self.active then
		if key:len() == 1 then
			if love.keyboard.isDown("lctrl") then
				if key == "c" then
					love.system.setClipboardText(self.text)
					return true
				elseif key == "v" then
					self.text = self.text .. love.system.getClipboardText()
					if self.onKeyPress then
						self:onKeyPress()
					end
					return true
				end
			elseif love.keyboard.isDown("lshift") then
				self.text = self.text .. string.upper(key)
				if self.onKeyPress then
					self:onKeyPress()
				end
				return true
			else
				self.text = self.text .. key
				if self.onKeyPress then
					self:onKeyPress()
				end
				return true
			end
		elseif key == "space" then
			self.text = self.text .. " "
			if self.onKeyPress then
				self:onKeyPress()
			end
			return true
		elseif key == "backspace" then
			self.text = self.text:sub(1, -2)
			if self.onKeyPress then
				self:onKeyPress()
			end
			return true
			--elseif key == "lalt" then
			--self.text = ""
		elseif key == "return" then
			if self.onEnterFunc then
				if self.onEnterFuncArgs then
					self:onEnterFunc(self.onEnterFuncArgs)
					return true
				else
					self:onEnterFunc()
					return true
				end
			end
		end
	end
	return false
end

Entry.draw = function(self, x, y)
	self.x = self.ox + x
	self.y = self.oy + y
	if self.active then
		self.colorCurrent = self.colorActive
		self.colorTextCurrent = self.colorPassive
	else
		self.colorCurrent = self.colorPassive
		self.colorTextCurrent = self.colorActive
	end

	love.graphics.setColor(self.colorCurrent)

	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(self.colorTextCurrent)

	if self.active then
		love.graphics.print(self.text .. "|", self.x + self.textX, self.y + self.textY)
	else
		love.graphics.print(self.text, self.x + self.textX, self.y + self.textY)
	end

	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	love.graphics.setColor(1, 1, 1)
end

return Entry
