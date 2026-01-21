local data = {
    speed = 0,
    lastSignal = 0,
    speedHistory = {  },
    lookupSpeed =  {
        0,
        10, 
        50,
        75,
        100, 
        150, 
        250, 
        500,
        750,
        1000,
        2500,
        5000,
        7500,
        10000,
        15000
     }, 
     injectionTimer = nil,
     overdriveActive = false
}

local config = require("config")
local utils = require("API.utils")
local maxSignal = 15

local speed = 0
local lastSignal = 0

---GATHER SENOR DATA
---@param sensorSide string? 
function data.getSensorData(sensorSide)

        local signal = rs.getAnalogInput(sensorSide or config.sensorSide)
        
        if signal > 0 then 
            data.speed = data.lookupSpeed[signal]
            if signal >= data.lastSignal then
                data.lastSignal = signal
            end
        end


    return data.speed
end 

--- GATHER GRAPH DATA
function data.gatherGraphData()
    if data.lastSignal > 0 then
        table.insert(data.speedHistory, data.lastSignal/15)
        if #data.speedHistory > 20 then
            table.remove(data.speedHistory, 1)
        end
    end
end


return data