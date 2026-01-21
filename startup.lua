local graphics = require("API.graphics")
local config = require("config")
local utils = require("API.utils")
local logger = require("API.logger")
local network = require("API.network")
local ui = require("modules.ui")
local logic = require("modules.logic") 
local data = require("modules.data")

local config = utils.loadTable("config.lua") or require("config")
_G.config = config -- Optional: Global machen, damit alle Module darauf zugreifen können

local m = peripheral.find("monitor")
local realW, realH = m.getSize()
local h = realH - config.logHeight
local w = realW


local function resetProgram()
    --Reset Terminal
    term.clear()
    term.setCursorPos(1, 1)

    -- Reset Network
    rednet.broadcast("RESET", config.protocol)

    -- Reset Redstone
    redstone.setOutput(config.primaryInjectionSide, false) 
    redstone.setOutput(config.secondaryInjectionSide, false) 

    -- Reset Monitor
    utils.resetMonitor()
    ui.drawStaticUI()
    ui.drawDynamicUI()
    ui.drawButtons()
end

--- MAIN --- 
resetProgram()

logger.log("SUCCESS", "UI initialized ...", colors.lime)

local refreshTimer1 = os.startTimer(config.refreshRate)
local refreshTimer2
local heartbeat = true
local firstCycle = true
local terminationSequenceActive = false

while true do

    local eventData = { os.pullEvent() }
    local event = eventData[1]
    graphics.handleEvent(unpack(eventData))

    if event == "timer" and eventData[2] == refreshTimer1 then

        if firstCycle then 
            network.init()
            network.broadcastMessage("PING")
            firstCycle = false
        end

        if redstone.getInput(config.activationSide) then
            redstone.setOutput(config.primaryInjectionSide, true) 
            graphics.setStatusColor("WAITING", colors.gray)
            graphics.setStatusColor("START", colors.lightBlue)
        end
        
        --- MAIN REFRESH --- 
        
        data.gatherGraphData()
        logic.evaluateSpeed()
        ui.drawDynamicUI()
        
        if heartbeat then 
            graphics.setStatusColor("HEARTBEAT", colors.lightBlue)
            heartbeat = false
        else 
            graphics.setStatusColor("HEARTBEAT", colors.gray)
            heartbeat = true
        end

        if logic.flag_1 == true and logic.flag_2 == true and terminationSequenceActive == false then
            refreshTimer2 = os.startTimer(2)
            graphics.setStatusColor("SHUTOFF", colors.yellow)
            terminationSequenceActive = true
        end

        refreshTimer1 = os.startTimer(config.refreshRate)

    elseif event == "timer" and eventData[2] == data.injectionTimer then
        logic.startInjection()

    elseif event == "timer" and eventData[2] == refreshTimer2 then
        print("Test")
        os.reboot()
    end


    if event == "rednet_message" and eventData[4] == config.protocol then
        local message = eventData[3]
        
        if message == "SWITCH 1 ready" then
            graphics.setStatusColor("RING I", colors.lime)
            graphics.setStatusColor("RING II", colors.gray)
        end

    end

    if event == "redstone" then
        if redstone.getAnalogInput(config.sensorSide) > 0 then
            data.getSensorData(config.sensorSide)
            logic.evaluateSpeed()
        end

        if redstone.getInput(config.activationSide) then
            redstone.setOutput(config.primaryInjectionSide, true) 
            graphics.setStatusColor("WAITING", colors.gray)
            graphics.setStatusColor("START", colors.lightBlue)
        end
    end
end

