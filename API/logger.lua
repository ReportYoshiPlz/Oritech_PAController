local logger = {}

local m = peripheral.find("monitor")
local logBuffer = {}

-- Konfiguration der Tag-Farben
local tagColors = {
    ["CLOCK"] = colors.gray,
    ["INFO"] = colors.white,
    ["WARN"] = colors.yellow,
    ["ERROR"] = colors.red,
    ["SUCCESS"] = colors.lime

}

-- Hilfsfunktion: Ermittelt die Länge des längsten Tags
local function getPaddingLength()
    local maxLen = 0
    for tag, _ in pairs(tagColors) do
        maxLen = math.max(maxLen, #tag)
    end
    return maxLen
end

-- Hilfsfunktion: Füllt das Tag mit Leerzeichen auf
local function getPaddedTag(tag)
    local targetLen = getPaddingLength()
    local currentLen = #tag
    if currentLen < targetLen then
        return tag .. string.rep(" ", targetLen - currentLen)
    end
    return tag
end

---draws the log area
---@param x1 number start X
---@param y1 number start Y
---@param x2 number end X
---@param y2 number end Y
function logger.draw(x1, y1, x2, y2)
    local maxLines = y2 - y1 + 1
    local width = x2 - x1 + 1
    local padLen = getPaddingLength()

    -- Bereich leeren
    for i = 0, maxLines - 1 do
        m.setCursorPos(x1, y1 + i)
        m.setBackgroundColor(colors.black)
        m.write(string.rep(" ", width))
    end

    local startIdx = math.max(1, #logBuffer - maxLines + 1)
    local lineOffset = 0

    for i = startIdx, #logBuffer do
        local entry = logBuffer[i]
        local currentY = y1 + lineOffset
        m.setCursorPos(x1, currentY)
        
        m.setTextColor(colors.lightGray)
        m.write("[" .. entry.time .. "]")
        
        m.setTextColor(tagColors[entry.tag] or colors.white)
        m.write("[" .. getPaddedTag(entry.tag) .. "]: ")
    
        m.setTextColor(entry.bodyColor or colors.white)

        local messageSpace = width - (10 + padLen + 2 + 2)
        m.write(string.sub(entry.message, 1, math.max(0, messageSpace)))
        
        lineOffset = lineOffset + 1
    end
end

---adds log message
function logger.log(tag, message, bodyColor)
    local time = os.date("%H:%M:%S")
    table.insert(logBuffer, {
        tag = tag,
        time = time,
        message = message,
        bodyColor = bodyColor
    })
    if #logBuffer > 50 then table.remove(logBuffer, 1) end
end

return logger