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
-- Communication protocol:
-- Discovery packets:
-- d|name| - initial discovery packet
-- d|name|ip - discovery packet from *name* at *ip*
-- d|from name|from ip|to name|to ip - discovery packet response to requestor
--]]

local socket = require("socket")

local udp
local port = 54813
local ip = nil

local thread = love.thread.newThread("consoleInput.lua")
local channel = love.thread.getChannel("command")

local net = {}
local data, senderIp
local parcedData
local commandID

local function sendRouting(packet, name, ip)
	for _, node in ipairs(net) do
		if node.ip == ip and node.name == name then
			udp:sendto(packet, node.nextHop, port)
		end
	end
end

local function addRoute(name, ip, nextHop)
	table.insert(net, {})
	net[#net].ip = ip
	net[#net].name = name
	net[#net].nextHop = nextHop
end

local function broadcast(packet) -- sends to all direct connections
	for _, node in ipairs(net) do
		if node.ip == node.nextHop then
			udp:sendto(packet, node.ip, port)
		end
	end
end

local function broadcastExcept(packet, ip)
	for _, node in ipairs(net) do
		if node.ip ~= ip and node.ip == node.nextHop then
			udp:sendto(packet, node.ip, port)
		end
	end
end

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
				print("[*] There are no peers discovered!")
			else
				print("[*] Peer list:")
				for id, peer in pairs(net) do
					print("[" .. id .. "] " .. peer.name .. ":")
					print("  - ip: " .. peer.ip)
					print("  - nextHop: " .. peer.ip)
				end
			end
		elseif commandID == 2 then
			print("[~] Restarting...")
			love.event.quit("restart")
		elseif commandID == 3 then
			print("[~] Quitting...")
			love.event.quit(0)
		elseif commandID == 4 then
			print("[~] Quitting...")
			broadcast("d|" .. name)
		end
	end

	repeat
		-- Getting data
		data, senderIp = udp:receivefrom()
		if data then
			print("\n[*] Data from " .. senderIp .. " received: " .. data)
			parcedData = split(data, "|")
			-- Processing discovery packet:
			if parcedData[1] == "d" then
				if #parcedData == 2 then -- if initial discovery packet
					if not ip then -- no communication established
						ip = parcedData[5] -- establishing ip used for communication
						print("[*] Communication ip established: " .. ip)
					end
					-- redirect completed packet to direct connections
					broadcast(data .. "|" .. senderIp)

					if isUnique(net, parcedData[2], senderIp) then
						addRoute(parcedData[2], senderIp, senderIp)
						print("[*] " .. net[#net].name .. "#" .. #net .. " was discovered:")
						print("  - ip: " .. net[#net].ip)
						print("  - nextHop: " .. net[#net].nextHop)
					end
					udp:sendto("d|" .. name .. "|" .. ip .. "|" .. parcedData[2] .. "|" .. senderIp, senderIp, port) -- send discovery response
				elseif #parcedData == 3 then -- if complete discovery packet
					if isUnique(net, parcedData[2], parcedData[3]) then
						addRoute(parcedData[2], parcedData[3], senderIp)
						print("[*] " .. net[#net].name .. "#" .. #net .. " was discovered:")
						print("  - ip: " .. net[#net].ip)
						print("  - nextHop: " .. net[#net].nextHop)
					end
					broadcastExcept(data, senderIp)
					sendRouting(
						"d|" .. name .. "|" .. ip .. "|" .. parcedData[2] .. "|" .. parcedData[3],
						parcedData[2],
						parcedData[3]
					) -- sending discovery response
				end
			elseif #parcedData == 5 then -- if discovery packet response
				-- if server is the requestor of discovery
				if parcedData[4] == name and parcedData[5] == ip then
					if isUnique(net, parcedData[2], parcedData[3]) then
						addRoute(parcedData[2], parcedData[3], senderIp)
						print("[*] " .. net[#net].name .. "#" .. #net .. " was discovered:")
						print("  - ip: " .. net[#net].ip)
						print("  - nextHop: " .. net[#net].nextHop)
					end
				else
					sendRouting(data, parcedData[2], parcedData[3])
				end
			end
		end
	until not data
	socket.sleep(0.01)
end
