print("[~] Starting network thread...")

print("[~] Setting up 'NET' communication channel...")
local netComms = love.thread.getChannel("NET")

local isActive = true
local signalApp = nil
local signalLis = nil

print("[~] Starting listener thread and 'HEAR' communication channel...")
local listener = love.thread.newThread("src/network/listener.lua")
local lisComms = love.thread.newChannel("HEAR")

print("[+] Network thread mainloop is up and running!")
while isActive do
	signalApp = netComms:pop()
	if signalApp then
		print("[*] Signal from application recieved: " .. signalApp)
	end
	signalLis = lisComms:pop()
	if signalLis then
		print("[*] Signal from listener recieved: " .. signalApp)
	end
end
