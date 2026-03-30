local Overlay = require("src/ui/overlay")
local netThread = love.thread.newThread("src/network.lua")
local main = Overlay:new(0, 0, 800, 600)

main.menu = main:add(require("src/overlays/menu"))

netThread:start()

return main
