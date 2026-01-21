local graphics = { }



local m = peripheral.find("monitor")
local colorArray = {  }

function graphics.getDynamicColor(percent, colorArray)
    if not colorArray or #colorArray == 0 then return colors.white end
    -- Berechne Index (1 bis Anzahl der Farben)
    local index = math.ceil(percent * #colorArray)
    index = math.max(1, math.min(index, #colorArray)) -- Clamp zwischen 1 und Max
    return colorArray[index]
end


---LINE
---@param x1 number start X
---@param y1 number start Y
---@param x2 number end X
---@param y2 number end Y
---@param color string line color; default: white
function graphics.drawLine(x1, y1, x2, y2, color)
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = (x1 < x2) and 1 or -1
    local sy = (y1 < y2) and 1 or -1
    local err = dx - dy

    m.setBackgroundColor(color or colors.white)

    while true do
        m.setCursorPos(x1, y1)
        m.write(" ")

        if x1 == x2 and y1 == y2 then break end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end
end

---BOX (HOLLOW)
---@param x1 number start X
---@param y1 number start Y
---@param x2 number end X
---@param y2 number end Y
---@param color string box color; default: white
function graphics.drawBox(x1, y1, x2, y2, color)
    local startX = math.min(x1, x2)
    local startY = math.min(y1, y2)
    local endX = math.max(x1, x2)
    local endY = math.max(y1, y2)

    graphics.drawLine(startX, startY, endX, startY, color)
    graphics.drawLine(startX, endY, endX, endY, color)
    graphics.drawLine(startX, startY, startX, endY, color)
    graphics.drawLine(endX, startY, endX, endY, color)
end


---WRITE TO MONITOR
---@param x1 number start x
---@param y1 number start y
---@param text string body content
---@param bg string background color; default: black
---@param fg string text color; default: white
---@param width number? optional FIXED WIDTH
function graphics.write(x1, y1, text, bg, fg, width)
    m.setBackgroundColor(bg or colors.black)
    m.setTextColor(fg or colors.white)
    m.setCursorPos(x1, y1)
    
    if width then
        local formattedText = string.format("%-" .. width .. "s", tostring(text))
        m.write(formattedText)
    else
        m.write(text)
    end
end



---BOX (FILLED)
---@param x1 number start X
---@param y1 number start Y
---@param x2 number end X
---@param y2 number end Y
---@param color string Farbe der Fläche
function graphics.drawFilledBox(x1, y1, x2, y2, color)
    local startX = math.min(x1, x2)
    local startY = math.min(y1, y2)
    local endX = math.max(x1, x2)
    local endY = math.max(y1, y2)

    m.setBackgroundColor(color or colors.white)
    for i = startY, endY do
        m.setCursorPos(startX, i)
        m.write(string.rep(" ", endX - startX + 1))
    end
end

---PROGRESS BAR (HORIZONTAL)
---@param x1 number start x
---@param y1 number start y
---@param x2 number end x
---@param y2 number end y
---@param percent number Prozentangabe (zwischen 0 und 1)
---@param colorArray any colors to use (Input as Array) 
---@param bgColor string bg 
function graphics.drawProgressH(x1, y1, x2, y2, percent, colorArray, bgColor)
    local width = x2 - x1 + 1
    local fillWidth = math.floor(width * math.max(0, math.min(1, percent)))
    local barColor = graphics.getDynamicColor(percent, colorArray)
    
    if fillWidth > 0 then
        graphics.drawFilledBox(x1, y1, x1 + fillWidth - 1, y2, barColor)
    end
    if fillWidth < width then
        graphics.drawFilledBox(x1 + fillWidth, y1, x2, y2, bgColor or colors.gray)
    end
end

---PROGRESS BAR (VERTICAL)
---@param x1 number start x
---@param y1 number start y
---@param x2 number end x
---@param y2 number end y
---@param percent number value (0 – 1)
---@param colorArray any colors (Array)
---@param bgColor string color bg
function graphics.drawProgressV(x1, y1, x2, y2, percent, colorArray, bgColor)
    local height = y2 - y1 + 1
    local fillHeight = math.floor(height * math.max(0, math.min(1, percent)))
    local barColor = graphics.getDynamicColor(percent, colorArray)
    
    if fillHeight < height then
        graphics.drawFilledBox(x1, y1, x2, y1 + (height - fillHeight) - 1, bgColor or colors.gray)
    end
    if fillHeight > 0 then
        graphics.drawFilledBox(x1, y2 - fillHeight + 1, x2, y2, barColor)
    end
end

---BAR DIAGRAMM
---@param x1 number start X
---@param y1 number start Y
---@param x2 number end X
---@param y2 number end Y
---@param data table value (bars; Array)
---@param colorArray table colors (bars; Array)
---@param bgColor string color (bg)
function graphics.drawBarGraph(x1, y1, x2, y2, data, colorArray, bgColor)
    local width = x2 - x1 + 1
    local height = y2 - y1 + 1
    local numBars = #data
    
    graphics.drawFilledBox(x1, y1, x2, y2, bgColor or colors.black)
    
    if numBars == 0 then return end

    local spacePerBar = width / numBars
    local barWidth = math.floor(spacePerBar - 1)
    if barWidth < 1 then barWidth = 1 end
    
    local totalUsedWidth = (numBars * barWidth) + (numBars - 1)
    local currentX = x1 + math.floor((width - totalUsedWidth) / 2)

    for i = 1, numBars do

        local drawX1 = math.max(currentX, x1)
        local drawX2 = math.min(currentX + barWidth - 1, x2)

        if drawX1 <= x2 and drawX2 >= x1 then
            local percent = math.max(0, math.min(1, data[i]))
            local fillHeight = math.floor(height * percent)
            local barColor = graphics.getDynamicColor(percent, colorArray)
            
            if fillHeight > 0 then
                graphics.drawFilledBox(drawX1, y2 - fillHeight + 1, drawX2, y2, barColor)
            end
        end
        
        currentX = currentX + barWidth + 1
    end
end




local statusLights = {  }

---STATUS LIGHT
---@param id string|number ID
---@param x1 number start x
---@param y1 number start y
---@param x2 number end x
---@param y2 number end y
---@param color string COLOR (default)
---@param label string? LABEL
---@param labelFgColor string? LABEL FG COLOR (default: white) 
---@param labelBgColor string? LABEL BG COLOR (default: black)
---@param altLabelMode boolean? ALTERNATE LOCATION FOR LABEL (below status light)
function graphics.addStatusLight(id, x1, y1, x2, y2, color, label, labelFgColor, labelBgColor, altLabelMode)
    statusLights[id] = {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        label = label,
        labelFgColor = labelFgColor or colors.white,
        labelBgColor = labelBgColor or colors.black,
        altLabelMode = altLabelMode or false
    }
    graphics.setStatusColor(id, color)
end

---Change COLOR of STATUS LAMP
---@param id string|number ID
---@param color string change LIGHT COLOR
---@param labelFgColor string?  change TEXT COLOR
function graphics.setStatusColor(id, color, labelFgColor)
    local light = statusLights[id]
    if light then
        graphics.drawFilledBox(light.x1, light.y1, light.x2, light.y2, color)

        if light.label then
            local fg = labelFgColor or light.labelFgColor
            
            if light.altLabelMode then 
                local boxCenter = (light.x1 + light.x2) / 2
                local textStartX = math.floor(boxCenter - (#light.label / 2) + 0.5)
                graphics.write(textStartX, light.y2 + 2, light.label, light.labelBgColor, fg)
            else
                graphics.write(light.x2 + 2, light.y1, light.label, light.labelBgColor, fg)
            end
        end
    end
end


--- BUTTONS --- 
local buttons = {  }

---ADD BUTTON 
---@param id string|number ID
---@param x1 number Start X
---@param y1 number Start Y
---@param x2 number End X
---@param y2 number End Y
---@param activeConfig table {label, color, fgColor, callback} -- callback als Referenz e.example; falls Variablen weitergegeben müssen: function () e.example(5) end
---@param inactiveConfig table {label, color, fgColor, callback} -- callback als Referenz e.example; falls Variablen weitergegeben müssen: function () e.example(5) end
---@param flashDuration number? OPTIONAL FLASH NUMBERS (duration in seconds)
function graphics.addButton(id, x1, y1, x2, y2, activeConfig, inactiveConfig, flashDuration)
    buttons[id] = {
        x1 = x1, y1 = y1, x2 = x2, y2 = y2,
        active = activeConfig,
        inactive = inactiveConfig,
        state = false,
        flashDuration = flashDuration,
        timerID = nil
    }
    graphics.drawButton(id)
end


---DRAW BUTTON
---@param id string|number BUTTON ID
function graphics.drawButton(id)
    local button = buttons[id]
    if not button then return end

    local cfg = button.state and button.active or button.inactive
    
    graphics.drawFilledBox(button.x1, button.y1, button.x2, button.y2, cfg.color)
    
    if cfg.label then
        local text = tostring(cfg.label)
        local btnWidth = button.x2 - button.x1 + 1
        local btnHeight = button.y2 - button.y1 + 1
        
        local labelX = math.floor(button.x1 + (btnWidth / 2) - (#text / 2))
        local labelY = math.floor(button.y1 + (btnHeight / 2))
        
        graphics.write(labelX, labelY, text, cfg.color, cfg.fgColor or colors.white)
    end
end


---CHANGE BUTTON STATE
function graphics.setButtonState(id, state, silent)
    local button = buttons[id]
    if not button then return end

    if button.timerID then button.timerID = nil end

    button.state = state
    graphics.drawButton(id)
    
    if not silent then
        local cfg = state and button.active or button.inactive
        if cfg.callback and type(cfg.callback) == "function" then 
            cfg.callback() 
        end
    end

    if state and button.flashDuration and button.flashDuration > 0 then
        button.timerID = os.startTimer(button.flashDuration)
    end
end



---BUTTON EVENT-HANDLER
function graphics.handleEvent(event, p1, p2, p3)
    if event == "monitor_touch" then
        local touchX, touchY = p2, p3
        for id, button in pairs(buttons) do
            if touchX >= button.x1 and touchX <= button.x2 and 
               touchY >= button.y1 and touchY <= button.y2 then
                
                if button.flashDuration then
                    if not button.state then graphics.setButtonState(id, true) end
                else
                    graphics.setButtonState(id, not button.state)
                end
                return id
            end
        end
    elseif event == "timer" then
        local timerID = p1
        for id, button in pairs(buttons) do
            if button.timerID == timerID then
                button.timerID = nil
                graphics.setButtonState(id, false)
            end
        end
    end
    return nil
end

return graphics