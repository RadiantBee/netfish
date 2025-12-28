local function isUnique(t, ip, port)
	for _, element in pairs(t) do
		if element.ip == ip and element.port == port then
			return false
		end
	end
	return true
end

local function split(s, delimiter)
	local result = {}
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

print("\n[~] Starting network thread...")

print("[~] Setting up 'NET' and 'APP' communication channel...")
local netComms = love.thread.getChannel("NET")
local appComms = love.thread.getChannel("APP")
print("[+] 'NET' and 'APP' comms are up!")

local isActive = true
local signalApp = nil

local socket = require("socket")

local udp
local port = 54813

local name
local net = {}
local data, senderIp, senderPort
local parcedData

print("[~] Setting up UPD socket for *:" .. port)
udp = socket.udp()
assert(udp:setsockname("*", port), "[!] Was not able to initialize udp socket on *:" .. port)
udp:settimeout(0)
print("[+] UDP socket is ready!")

print("[+] Network thread mainloop is up and running!")
while isActive do
	-- Processing app signal
	signalApp = netComms:pop()
	if signalApp then
		print("[*] Signal from application recieved: " .. signalApp)
		parcedData = split(signalApp, "|")
	end
	-- Getting data
	data, senderIp, senderPort = udp:receivefrom()
	if data then -- if server recieves data
		parcedData = split(data, "|")
		-- Processing handshake
		if parcedData[1] == "h" and isUnique(net, senderIp, senderPort) then
			data = "h"
			for id, player in ipairs(net) do
				-- collecting data from every connected player to get new user up to date
				data = data
					.. "|"
					.. player.nickname
					.. "|"
					.. player.colorR
					.. "|"
					.. player.colorG
					.. "|"
					.. player.colorB
				-- sending every player data about our new user
				udp:sendto(
					"h|" .. parcedData[2] .. "|" .. parcedData[3] .. "|" .. parcedData[4] .. "|" .. parcedData[5],
					player.ip,
					player.port
				)
			end
			table.insert(net, {})
			net[#net].ip = senderIp
			net[#net].port = senderPort
			net[#net].nickname = parcedData[2]
			net[#net].colorR = parcedData[3]
			net[#net].colorG = parcedData[4]
			net[#net].colorB = parcedData[5]
			net[#net].state = 1
			net[#net].x = 0
			net[#net].y = 0
			print("[*] " .. net[#net].nickname .. "#" .. #net .. " joined:")
			print("  - ip: " .. net[#net].ip)
			print("  - port: " .. net[#net].port)
			udp:sendto(data, senderIp, senderPort)
		-- Processing client data
		elseif parcedData[1] == "g" then
			if tonumber(parcedData[2]) <= #net then
				net[tonumber(parcedData[2])].x = parcedData[3]
				net[tonumber(parcedData[2])].y = parcedData[4]
				net[tonumber(parcedData[2])].state = parcedData[5]
			end
			-- Updating every other player
			for id, player in ipairs(net) do
				if id ~= tonumber(parcedData[2]) then
					udp:sendto(data, player.ip, player.port)
				end
			end
		elseif parcedData[1] == "q" then
			print("[*] Player #" .. parcedData[2] .. " " .. net[tonumber(parcedData[2])].nickname .. " has left!")
			table.remove(net, tonumber(parcedData[2]))
			for _, player in ipairs(net) do
				udp:sendto(data, player.ip, player.port)
			end
		end
	end
end
