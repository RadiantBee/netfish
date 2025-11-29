local Button = require("src/ui/button")

local test = {}
test.isState = true

test.changeTo = nil

test.button = Button("change to test2", test.changeTo, "test2", nil, nil, 100, 50)

test.mousepressed = function(self, x, y)
	self.button:onClick(x, y)
end

test.load = function(self, changeFunction)
	self.changeTo = changeFunction
	self.button.func = self.changeTo
	print("state test1 ready")
end

test.update = function(self, dt) end

test.draw = function(self, mouseX, mouseY)
	self.button:draw(100, 50, mouseX, mouseY, 10, 10)
end

return test
