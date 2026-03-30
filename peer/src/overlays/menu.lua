local Overlay = require("src/ui/overlay")
local anim8 = require("lib/anim8")

local function split(s, delimiter)
	local result = {}
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

local netComms = love.thread.getChannel("NET")

local infoText = "\n[*] Welcome to " .. love.window.getTitle() .. "!\n[*] Client version: 0.0.1\n[*] Made by MaxPan"

-- UI part:
local menu = Overlay:new(0, 0, 800, 600)

print(infoText)

local infoLab = menu:newLabel(10, 0, infoText)

local placeholders = menu:newElement()
placeholders.draw = function(self)
	-- Size of further icons (50x50):
	--love.graphics.rectangle("line", 20, 100, 50, 50)
	-- Loading animation placeholder:
	love.graphics.rectangle("line", 550, 400, 100, 100)
	-- Icon placeholder:
	love.graphics.rectangle("line", 150, 50, 500, 250)
end

menu.nameEntry = menu:newEntry(340, 350, 120, 20)
menu.ipEntry = menu:newEntry(340, 375, 120, 20)

menu:newLabel(297, 352, "Name:")
menu:newLabel(390, 452, "or")
menu:newLabel(280, 377, "Target ip:")

menu.connectButton = menu:newButton(350, 425, 100, 20, "Connect")
menu.connectButton.textX = 23
menu.listenButton = menu:newButton(350, 475, 100, 20, "Listen")
menu.listenButton.textX = 30

menu:newLabel(300, 505, "Status: ")
menu.statusLab = menu:newLabel(350, 505, "idle")

-- Logic part:
menu.autofillElement = menu:newElement()
menu.autofillElement.load = function(self)
	print("\n[~] Loading autofill options...")
	local autofillFile = io.open("autofillData", "r")
	if not autofillFile then
		print("[!] Error! Wasn't able to open 'autofillData' file!")
		return
	end
	print("[+] File 'autofillData' accessed successfully!")
	print("[~] Reading from file...")
	local line = autofillFile:read("*l") -- getting name
	if line then
		print("[*] Name: " .. line)
		menu.nameEntry.text = line
	else
		print("[!] Empty name line!")
		print("[~] Closing file...")
		autofillFile:close()
		print("[+] File closed!")
		return
	end
	line = autofillFile:read("*l") -- getting target ip
	if line then
		print("[*] Target ip: " .. line)
		menu.ipEntry.text = line
	else
		print("[!] Empty ip line!")
		print("[~] Closing file...")
		autofillFile:close()
		print("[+] File closed!")
		return
	end
	print("[+] Options loaded successfully!")
	print("[~] Closing file...")
	autofillFile:close()
	print("[+] File closed!")
end

menu.saveAutofill = function(self)
	print("\n[~] Saving current options...")
	local autofillFile = io.open("autofillData", "w")
	if not autofillFile then
		print("[!] Error! Wasn't able to open 'autofillData' file!")
		return
	end
	print("[+] File 'autofillData' accessed successfully!")
	print("[~] Writing to file...")
	print("[*] " .. self.nameEntry.text)
	autofillFile:write(self.nameEntry.text .. "\n")
	print("[*] " .. self.ipEntry.text)
	autofillFile:write(self.ipEntry.text .. "\n")
	print("[+] Options saved successfully!")
	print("[~] Closing file...")
	autofillFile:close()
	print("[+] File closed!")
end

menu.connectButton.func = function(self)
	menu:saveAutofill()
	if menu.ipEntry.text ~= "" and menu.nameEntry.text ~= "" then
		netComms:push("c|" .. menu.nameEntry.text .. "|" .. menu.ipEntry.text)
	end
end

menu.ipEntry.onEnterFunc = function(self)
	self.parent.ipEntry.active = false
	self.parent.connectButton:activate()
end

menu.nameEntry.onEnterFunc = function(self)
	self.parent.nameEntry.active = false
	self.parent.ipEntry.active = true
end

return menu
