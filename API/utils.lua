local utils = { }


local mon = peripheral.find("monitor")

function utils.customSleep(time)
    local timerID = os.startTimer(time)
    repeat
        local eventInfo = { os.pullEvent("timer") }
    until eventInfo[2] == timerID
end



function utils.resetMonitor()
    mon.setTextScale(0.5)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end



function utils.convertEnergy(value, appendUnit, roundToInt)

    local units = { "", "K", "M", "G", "T", "P", "E", "Z", "Y" }
    local pot = 1
    local absValue = math.abs(value)
    
    -- figure out what letter to use
    while absValue >= (1000 ^ pot) do
        pot = pot + 1
    end
    
    -- convert number
    local converted = value / (1000 ^ (pot - 1))

    -- round to Int
    if roundToInt then
        converted = math.floor(converted + 0.5)
    end

    -- output the final string
    local output = tostring(converted)
    if appendUnit then
        output = output .. " " .. units[pot]
    end

    return output

end



function utils.roundTo(value, decimalPlaces)

    local mult = 10^(decimalPlaces or 0)
    return math.floor(value * mult + 0.5) / mult

end



--- FILE MODIFICATION
---@param data table TABLE to save
---@param tableName string? Optional: Der Name der lokalen Variable in der Datei (Standard: "data")
function utils.saveTable(path, data, tableName)
    local name = tableName or "data"
    local file = fs.open(path, "w")
    if file then
        file.write("local " .. name .. " = ")
        file.write(textutils.serialize(data))
        file.write("\n\nreturn " .. name)
        file.close()
        return true
    end
    return false
end

---LOADS A TABLE FROM .LUA-FILE
---@param path string FILE PATH
---@return table|nil
function utils.loadTable(path)
    if fs.exists(path) then
        local func, err = loadfile(path)
        if func then
            local success, result = pcall(func) -- pcall fängt Fehler beim Ausführen ab
            if success then
                return result
            else
                print("Laufzeitfehler in " .. path .. ": " .. tostring(result))
            end
        else
            print("Syntaxfehler in " .. path .. ": " .. tostring(err))
        end
    end
    return nil
end
 

return utils