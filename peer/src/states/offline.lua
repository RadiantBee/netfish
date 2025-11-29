local Button = require("src/ui/button")
local Entry = require("src/ui/entry")

local menu = {}
menu.isState = true
menu.changeTo = nil

menu.getMsg = nil
menu.sendMsg = nil

menu.ui = {}
menu.ui.connectButton = Button("Connect", nil, nil, 350, 400, 100, 20)
menu.ui.ipEntry = Entry(340, 350, 120, 20)

menu.mousepressed = function(self, x, y)
	self.ui.connectButton:onClick(x, y)
	self.ui.ipEntry:onClick(x, y)
end

menu.keypressed = function(self, key)
	self.ui.ipEntry:onKeyboardPress(key)
end

menu.load = function(self, changeTo)
	self.changeTo = changeTo
end

menu.update = function(self, dt) end

menu.draw = function(self, mouseX, mouseY)
	love.graphics.print("Welcome to NetFiSh!", 10, 10)
	love.graphics.print("Client version: 0.0.1", 10, 30)
	love.graphics.print("Made by MaxPan", 10, 50)
	love.graphics.print("Port:", 310, 352)
	-- Size of further icons (50x50):
	--love.graphics.rectangle("line", 20, 100, 50, 50)
	-- Loading animation placeholder:
	love.graphics.rectangle("line", 550, 400, 100, 100)
	-- Icon placeholder:
	love.graphics.rectangle("line", 150, 50, 500, 250)
	self.ui.ipEntry:draw(nil, nil, 2, 2)
	self.ui.connectButton:draw(nil, nil, mouseX, mouseY, 23, 2)
end

return menu
