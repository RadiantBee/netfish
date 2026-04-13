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
local net = {} -- routing table
local dir = {} -- list of direct connection
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
	-- Processing app signal
	signalApp = netComms:pop()
	if signalApp then
		print("\n[*] Signal from application recieved: " .. signalApp)
		parcedData = split(signalApp, "|")
		if parcedData[1] == "l" then
			listen = not listen
		elseif parcedData[1] == "c" then
			name = parcedData[2]
			print("[*] Self name set to " .. name)
			udp:sendto("d|" .. name, parcedData[3], port)
			print("[*] Sending: d|" .. name .. " to " .. parcedData[3] .. ":" .. port)
		end
	end
	-- Getting data
	data, senderIp = udp:receivefrom()
	if data then -- if server recieves data
		print("\n[*] Received: " .. data .. " from " .. senderIp)
		parcedData = split(data, "|")

		-- Processing discovery packet
		if parcedData[1] == "d" and isUnique(net, parcedData[3] or senderIp) then
			if isUnique(net, parcedData[3] or senderIp) then
				table.insert(net, {})
				net[#net].ip = parcedData[3] or senderIp
				net[#net].name = parcedData[2]
				net[#net].nextHop = senderIp
				print("[*] " .. net[#net].name .. "#" .. #net .. " joined:")
				print("  - ip: " .. net[#net].ip)
				print("  - nextHop: " .. net[#net].nextHop)
				udp:sendto("d|" .. name, senderIp)
			end
		-- spread the discovery packet
		-- TODO: ...

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
			print("[*] Peer #" .. parcedData[2] .. " " .. net[tonumber(parcedData[2])].name .. " has left!")
			table.remove(net, tonumber(parcedData[2]))
			for _, peer in ipairs(net) do
				udp:sendto(data, peer.ip, port)
			end
		end
	end
end
