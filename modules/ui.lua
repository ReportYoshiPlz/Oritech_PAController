local ui = {  }

local utils = require("API.utils")
local config = require("config")
local graphics = require("API.graphics")
local logger = require("API.logger")
local data = require("modules.data")
local logic= require("modules.logic")

local m = peripheral.find("monitor")
local realW, realH = m.getSize()
local h = realH - config.logHeight
local w = realW



--- STATIC UI ELEMENTS --- 
function ui.drawStatusLights()
    graphics.addStatusLight("HEARTBEAT", 44, 3, 44, 3, colors.gray, "HEARTBEAT")
    graphics.addStatusLight("NETWORK",44, 5, 44, 5, colors.gray, "NETWORK")
    graphics.addStatusLight("RING I",44, 7, 44, 7, colors.gray, "RING I")
    graphics.addStatusLight("RING II",44, 9, 44, 9, colors.gray, "RING II")
    graphics.addStatusLight("SHUTOFF",44, 11, 44, 11, colors.gray, "SHUTOFF")


    graphics.addStatusLight("WAITING", 3, 14, 10, 14, colors.orange, "WAITING", colors.white, colors.black, true)
    graphics.addStatusLight("START", 11, 14, 18, 14, colors.gray, "START", colors.white, colors.black, true)
    graphics.addStatusLight("REDIRECT", 19, 14, 28, 14, colors.gray, "REDIRECT", colors.white, colors.black, true)
    graphics.addStatusLight("INJECTION", 29, 14, 40, 14, colors.gray, "INJECTION", colors.white, colors.black, true)
end

function ui.drawButtons()
    --- RING 1 SPEED CONTROL
   graphics.addButton("decreaseRing1", 3, 3, 3, 3, 
    {label = "-", color = colors.lightGray, fgColor = colors.red},
    {label = "-", color = colors.gray, fgColor = colors.red, callback = logic.decreaseRing1Speed}, 0.2) 

   graphics.addButton("increaseRing1", 8, 3, 8, 3, 
    {label = "+", color = colors.lightGray, fgColor = colors.lime}, 
    {label = "+", color = colors.gray, fgColor = colors.lime, callback = logic.increaseRing1Speed}, 0.2)
    
    graphics.write(4, 3, " "..config.ring1Speed.." ", colors.gray, colors.white, 4)

    --- INJECTION SPEED CONTROL
    graphics.addButton("decreaseInjection", 10, 3, 10, 3, 
    {label = "-", color = colors.lightGray, fgColor = colors.red},
    {label = "-", color = colors.gray, fgColor = colors.red, callback = logic.decreaseInjectionSpeed}, 0.2) 

    graphics.addButton("increaseInjection", 15, 3, 15, 3, 
    {label = "+", color = colors.lightGray, fgColor = colors.lime}, 
    {label = "+", color = colors.gray, fgColor = colors.lime, callback = logic.increaseInjectionSpeed}, 0.2)

    graphics.write(11, 3, " "..config.injectionSpeed.." ", colors.gray, colors.purple, 4)


    --- OVERDRIVE
    graphics.addButton("decreaseOverdrive", 17, 3, 17, 3, 
    {label = "-", color = colors.lightGray, fgColor = colors.red},
    {label = "-", color = colors.gray, fgColor = colors.red, callback = logic.decreaseOverdrive}, 0.2) 

    graphics.addButton("increaseOverdrive", 22, 3, 22, 3, 
    {label = "+", color = colors.lightGray, fgColor = colors.lime}, 
    {label = "+", color = colors.gray, fgColor = colors.lime, callback = logic.increaseOverdrive}, 0.2)

    if config.overdriveMode == false then 
        graphics.write(18, 3, " "..config.overdrive.." ", colors.gray, colors.red, 4)
    else 
        graphics.write(18, 3, " "..config.overdrive.." ", colors.gray, colors.yellow, 4)
    end
    

    graphics.addButton("toggleOverdrive", 44, 13, 55, 15, 
    {label = "OVRDR. ON", color = colors.lime, fgColor = colors.black, callback = logic.toggleOverdrive}, 
    {label = "OVRDR. OFF", color = colors.red, fgColor = colors.black, callback = logic.toggleOverdrive})

    if config.overdriveMode then
        graphics.setButtonState("toggleOverdrive", true, true)
    end

end

function ui.drawBorder()
    graphics.drawBox(1, 1, w, h, colors.white)
    graphics.drawLine(w-15, 1, w-15, h, colors.white)
end

function ui.drawHeaders()
    graphics.write(4, 1, " PARTICLE ACCELERATOR ", colors.black, colors.white) -- MAIN HEADER
    graphics.write(45, 1, " STATUS ", colors.black, colors.white)
end

function ui.drawStaticUI()
    utils.resetMonitor()
    ui.drawBorder()
    ui.drawHeaders()
    ui.drawStatusLights()
end


--- DYNAMIC UI ELEMENTS --- 
function ui.drawLogAreas()
    logger.draw(1, h + 2, realW, realH) 
end

function ui.drawBarGraphs()
    graphics.drawBarGraph(3, 5, 40, 12, data.speedHistory, { colors.lime, colors. yellow, colors.red }, colors.black)
end

function ui.drawDynamicText()
    graphics.write(24, 3, "SPEED: " ..(data.speed/1000), colors.black, colors.white, 11)
    graphics.write(35, 3, " K m/s", colors.black, colors.white)
end

function ui.drawDynamicUI()
   ui.drawLogAreas()
   ui.drawBarGraphs()
   ui.drawDynamicText()
end



return ui