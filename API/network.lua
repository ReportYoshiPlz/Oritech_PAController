local network = { }

local logger = require("API.logger")
local graphics = require("API.graphics")
local config = require("config")

local modem

function network.init()

    local modem = peripheral.find("modem") or nil

        peripheral.find("modem", rednet.open)

    if modem then
        logger.log("SUCCESS", "Modem found", colors.lime)
        logger.log("SUCCESS", "Connected to network", colors.lime)
        graphics.setStatusColor("NETWORK", colors.lime)

    else 

        logger.log("ERROR", "No modem found!", colors.red)
        logger.log("ERROR", "Not connect to network!", colors.red)
        graphics.setStatusColor("NETWORK", colors.red)
        
    end
end


---BROADCAST MESSAGE to PROTOCOL
---@param payload string CONTENTS
---@param protocol string? PROTOCOL
function  network.broadcastMessage(payload, protocol)
    rednet.broadcast(payload, protocol or config.protocol)
end
 
return network