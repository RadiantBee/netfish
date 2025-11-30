local Button = require("src/ui/button")
local Entry = require("src/ui/entry")

local menu = {}
menu.isState = true
menu.changeTo = nil

menu.getMsg = function(msg) end
menu.sendMsg = nil

menu.ui = {}
menu.ui.nameEntry = Entry(340, 350, 120, 20)
menu.ui.ipEntry = Entry(340, 400, 120, 20)

menu.loadAutofill = function(self)
	print("[~] Loading autofill options...")
	local autofillFile = io.open("autofillData", "r")
	if not autofillFile then
		print("[!] Error! Wasn't able to open 'autofillData' file!")
		return
	end
	print("[+] File 'autofillData' accessed successfully!")
	print("[~] Reading from file...")
	local line = autofillFile:read("*l")
	if line then
		print("[*] Name: " .. line)
		self.ui.nameEntry.text = line
	else
		print("[!] Empty name line!")
		print("[~] Closing file...")
		autofillFile:close()
		print("[+] File closed!\n")
		return
	end
	line = autofillFile:read("*l")
	if line then
		print("[*] Target ip: " .. line)
		self.ui.ipEntry.text = line
	else
		print("[!] Empty ip line!")
		print("[~] Closing file...")
		autofillFile:close()
		print("[+] File closed!\n")
		return
	end
	print("[+] Options loaded successfully!")
	print("[~] Closing file...")
	autofillFile:close()
	print("[+] File closed!\n")
end

menu.saveAutofill = function(self)
	print("[~] Saving current options...")
	local autofillFile = io.open("autofillData", "w")
	if not autofillFile then
		print("[!] Error! Wasn't able to open 'autofillData' file!")
		return
	end
	print("[+] File 'autofillData' accessed successfully!")
	print("[~] Writing to file...")
	print("[*] " .. self.ui.nameEntry.text)
	autofillFile:write(self.ui.nameEntry.text .. "\n")
	print("[*] " .. self.ui.ipEntry.text)
	autofillFile:write(self.ui.ipEntry.text .. "\n")
	print("[+] Options saved successfully!")
	print("[~] Closing file...")
	autofillFile:close()
	print("[+] File closed!\n")
end

menu.connectFunc = function(self)
	self:saveAutofill()
end

menu.ui.connectButton = Button("Connect", menu.connectFunc, menu, 350, 450, 100, 20)

menu.ui.ipEntry.onEnterFunc = function(ui)
	ui.ipEntry.active = false
	ui.connectButton:activate()
end

menu.ui.ipEntry.onEnterFuncArgs = menu.ui

menu.ui.nameEntry.onEnterFunc = function(ui)
	ui.nameEntry.active = false
	ui.ipEntry.active = true
end
menu.ui.nameEntry.onEnterFuncArgs = menu.ui

menu.mousepressed = function(self, x, y)
	self.ui.connectButton:onClick(x, y)
	self.ui.ipEntry:onClick(x, y)
	self.ui.nameEntry:onClick(x, y)
end

menu.keypressed = function(self, key)
	self.ui.ipEntry:onKeyboardPress(key)
	self.ui.nameEntry:onKeyboardPress(key)
end

menu.load = function(self, changeTo)
	self.changeTo = changeTo
	self:loadAutofill()
end

menu.update = function(self, dt) end

menu.draw = function(self, mouseX, mouseY)
	love.graphics.print("Welcome to NetFiSh!", 10, 10)
	love.graphics.print("Client version: 0.0.1", 10, 30)
	love.graphics.print("Made by MaxPan", 10, 50)
	love.graphics.print("Name:", 295, 352)
	love.graphics.print("Target ip:", 280, 402)
	-- Size of further icons (50x50):
	--love.graphics.rectangle("line", 20, 100, 50, 50)
	-- Loading animation placeholder:
	love.graphics.rectangle("line", 550, 400, 100, 100)
	-- Icon placeholder:
	love.graphics.rectangle("line", 150, 50, 500, 250)
	self.ui.nameEntry:draw(nil, nil, 2, 2)
	self.ui.ipEntry:draw(nil, nil, 2, 2)
	self.ui.connectButton:draw(nil, nil, mouseX, mouseY, 23, 2)
end

return menu
