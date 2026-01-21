local logic = {
    flag_1 = false,
    flag_2 = false
 }

local data = require("modules.data")
local logger = require("API.logger")
local graphics = require("API.graphics")
local utils = require("API.utils")



function logic.increaseRing1Speed()
    if config.ring1Speed < 15 then 
        config.ring1Speed = config.ring1Speed + 1 
        utils.saveTable("config.lua", config, "config")
    end
    graphics.write(4, 3, " "..config.ring1Speed.." ", colors.gray, colors.white, 4)
end

function logic.decreaseRing1Speed()
    if config.ring1Speed > 0 then 
        config.ring1Speed = config.ring1Speed - 1 
        utils.saveTable("config.lua", config, "config")
    end
    graphics.write(4, 3, " "..config.ring1Speed.." ", colors.gray, colors.white, 4)
end

function logic.increaseInjectionSpeed()
    if config.injectionSpeed < 15 then 
        config.injectionSpeed = config.injectionSpeed + 1 
        utils.saveTable("config.lua", config, "config")
    end
    graphics.write(11, 3, " "..config.injectionSpeed.." ", colors.gray, colors.orange, 4)
end

function logic.decreaseInjectionSpeed()
    if config.injectionSpeed > 0 then 
        config.injectionSpeed = config.injectionSpeed - 1 
        utils.saveTable("config.lua", config, "config")
    end
    graphics.write(11, 3, " "..config.injectionSpeed.." ", colors.gray, colors.orange, 4)
end



--- OVERDRIVE MODE ---

function logic.increaseOverdrive()
    if config.overdrive < 98 then 
        config.overdrive = config.overdrive + 1 
        utils.saveTable("config.lua", config, "config")
    end
    graphics.write(18, 3, " "..config.overdrive.." ", colors.gray, colors.yellow, 4)
end

function logic.decreaseOverdrive()
    if config.overdrive > 0 then 
        config.overdrive = config.overdrive - 1 
        utils.saveTable("config.lua", config, "config")
    end
    graphics.write(18, 3, " "..config.overdrive.." ", colors.gray, colors.yellow, 4)
end

function logic.toggleOverdrive()
    if config.overdriveMode then 
        config.overdriveMode = false
        graphics.write(18, 3, " "..config.overdrive.." ", colors.gray, colors.red, 4)
        utils.saveTable("config.lua", config, "config")
    else config.overdriveMode = true 
        graphics.write(18, 3, " "..config.overdrive.." ", colors.gray, colors.yellow, 4)
        utils.saveTable("config.lua", config, "config")
    end
end


--- REDIRECTION LOGIC ---

function logic.evaluateSpeed()
    
    -- RING 1
    if data.lastSignal >= config.ring1Speed and logic.flag_1 == false then
        rednet.broadcast("SWITCH 1", config.protocol)
        logger.log("INFO", "Rerouting to Ring 2")
        graphics.setStatusColor("RING I", colors.gray)
        graphics.setStatusColor("RING II", colors.lime)
        graphics.setStatusColor("START", colors.gray)
        graphics.setStatusColor("REDIRECT", colors.orange)
        logic.flag_1 = true
    end

    
    if data.lastSignal >= config.injectionSpeed and logic.flag_1 == true and logic.flag_2 == false then
        if config.overdriveMode == false then
            logic.startInjection()
        elseif config.overdriveMode == true and data.overdriveActive == false then
            data.injectionTimer = os.startTimer(config.overdrive)
            logger.log("INFO", "OVERDRIVE ENGAGED: "..config.overdrive.." s", colors.pink)
            graphics.setStatusColor("REDIRECT", colors.pink)
            graphics.setStatusColor("RING II", colors.pink)
            data.overdriveActive = true
        end
    end
end


-- INJECTION
function logic.startInjection()
    logger.log("INFO", "Injection sequence started")
    graphics.setStatusColor("REDIRECT", colors.gray)
    graphics.setStatusColor("INJECTION", colors.purple)
    redstone.setOutput(config.secondaryInjectionSide, true)
    logger.log("INFO", "Item injected!")
    logic.flag_2 = true
end
   




return logic