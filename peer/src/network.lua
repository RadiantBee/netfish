local function isUnique(t, name, ip)
	for _, element in pairs(t) do
		if element.ip == ip and element.name == name then
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
print("\n[~] Starting network thread...")

print("[~] Setting up 'NET' and 'APP' communication channel...")
local netComms = love.thread.getChannel("NET")
local appComms = love.thread.getChannel("APP")
print("[+] 'NET' and 'APP' comms are up!")

local isActive = true
local signalApp = nil

local socket = require("socket")

local udp
local port = 54813 -- trademark "SABLE" port
local ip = nil

local name
local parentIp = nil
local net = {} -- routing table

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

local data, senderIp
local parcedData

local listen = false

print("[~] Setting up UPD socket for *:" .. port)
udp = socket.udp()
assert(udp:setsockname("*", port), "[!] Was not able to initialize udp socket on *:" .. port)
udp:settimeout(0)
print("[+] UDP socket is ready!")

print("[+] Network thread mainloop is up and running!")
while isActive do
	repeat
		-- Processing app signal
		signalApp = netComms:pop()
		if signalApp then
			print("\n[*] Signal from application received: " .. signalApp)
			parcedData = split(signalApp, "|")
			if parcedData[1] == "c" then
				name = parcedData[2]
				print("[*] Net name set to " .. name)
				parentIp = parcedData[3]
				print("[*] Net parentIp set to " .. parentIp)
				print("[~] Sending: d|" .. name .. " to " .. parcedData[3] .. ":" .. port)
				udp:sendto("d|" .. name, parcedData[3], port)
			end
		end
	until not signalApp

	repeat
		-- Getting data
		data, senderIp = udp:receivefrom()
		if data then
			print("\n[*] Data from " .. senderIp .. " received: " .. data)
			parcedData = split(data, "|")
			-- Processing discovery packet:
			if parcedData[1] == "d" then
				if #parcedData == 2 then -- if initial discovery packet
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
				if not ip then -- no communication established
					if parentIp == senderIp then
						ip = parcedData[5] -- establishing ip used for communication
					end
				end
				-- if client is the requestor of discovery
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
