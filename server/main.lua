-- Name of the node:
local name = "firebat"

local function isUnique(t, ip)
	for _, element in pairs(t) do
		if element.ip == ip then
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

--[[
[~] - process started
[*] - something happened/info
[+] - process complete successfully
[-] - process completion failed
[!] - Error/something important
--]]

--[[
*type*|*related data*
Data bandle types:

discovery packet:
<- d|name
<- d|name|ip

-> d|name
-> d|name|ip 

handshake:
<- h|nickname|color
Response to client:
-> h|nickname1|color1 (and the same for every user)
Response to other clients:
-> h|nickname|color

(for current usecase) game update:
<- g|userID|gameData

For Immediate Broadcasting:
 Update all other players:
 -> g|userID|gameData
For bundled tick-based update:
 *Every player will recieve the same gamestate update*

Quitting the server:
<- q|userID
-> q|userID
--]]

local socket = require("socket")

local udp
local port = 54813

local thread = love.thread.newThread("consoleInput.lua")
local channel = love.thread.getChannel("command")

local net = {}
local data, senderIp
local parcedData
local commandID

function love.load()
	print("[~] Launching server")
	print("[~] Setting up UPD socket for *:" .. port)
	udp = socket.udp()
	udp:setsockname("*", port)
	udp:settimeout(0)
	print("[+] UDP socket is ready!")
	thread:start()
	print("[+] Thread active!")
	print("[+] Initialisation complete!")
end

function love.update(dt)
	-- Woking with the CLI thread
	commandID = channel:pop()

	if commandID then
		if commandID == 1 then
			if #net == 0 then
				print("[*] There are no peers chnnected to the server!")
			else
				print("[*] Peer list:")
				for id, peer in pairs(net) do
					print("[" .. id .. "] " .. peer.nickname .. ":")
					print("  - ip: " .. peer.ip)
					print("  - port: " .. peer.port)
				end
			end
		end
		if commandID == 2 then
			print("[~] Restarting...")
			love.event.quit("restart")
		end
		if commandID == 3 then
			print("[~] Quitting...")
			love.event.quit(0)
		end
	end

	-- Getting data
	data, senderIp = udp:receivefrom()
	if data then -- if server recieves data
		print("\n[*] Received: " .. data .. " from " .. senderIp)
		parcedData = split(data, "|")

		-- Processing discovery packet
		if parcedData[1] == "d" then
			if isUnique(net, parcedData[3] or senderIp) then
				-- adding new peer to the rounting list:
				table.insert(net, {})
				net[#net].ip = parcedData[3] or senderIp
				net[#net].name = parcedData[2]
				net[#net].nextHop = senderIp
				print("\n[*] " .. net[#net].name .. "#" .. #net .. " joined:")
				print("  - ip: " .. net[#net].ip)
				print("  - nextHop: " .. net[#net].nextHop)
				udp:sendto("d|" .. name, senderIp, port)
			end
			-- spread the discovery packet
			-- TODO:...

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
					udp:sendto(data, player.ip, port)
				end
			end
		elseif parcedData[1] == "q" then
			print("[*] Peer #" .. parcedData[2] .. " " .. net[tonumber(parcedData[2])].nickname .. " has left!")
			table.remove(net, tonumber(parcedData[2]))
			for _, player in ipairs(net) do
				udp:sendto(data, player.ip, port)
			end
		end
	end
	socket.sleep(0.01)
end
