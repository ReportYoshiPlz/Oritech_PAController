--- SWITCH ---
local networkProtocol = "Collider 1"
local outputSideGate, outputSideLamp = "top", "front"
local switchPosition = "SWITCH 1"
local modem = peripheral.find("modem")

local function reset()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.orange)
    print("[INFO   ] Redirect inactive")
    redstone.setOutput(outputSideGate, false)
    redstone.setOutput(outputSideLamp, false)
end

local function initNetwork()

    if modem then
        term.clear()
        term.setCursorPos(1, 1)
        peripheral.find("modem", rednet.open)
        term.setTextColor(colors.white)
        print("[INFO   ] Modem found")
        term.setTextColor(colors.lime)
        print("[SUCCESS] Connected to network")
        term.setTextColor(colors.white)
        print("[INFO   ] Network Protocol: " .. networkProtocol)
        rednet.broadcast(switchPosition .. " ready", networkProtocol)
    else 
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.red)
        print("[ERROR  ] No modem detected")
    end 
   

end


--- MAIN ---.
initNetwork()

while true do
    local eventData = { os.pullEvent() }
    -- local id, message = rednet.receive(networkProtocol)
    local event = eventData[1]

    if event == "rednet_message" and eventData[4] == networkProtocol then
        print("MESSAGE RECEIVED")
        local message = eventData[3]

        if message == switchPosition then
            rs.setOutput(outputSideGate, true)
            rs.setOutput(outputSideLamp, true)
            term.setTextColor(colors.lime)
            print("[SUCCESS] Redirect " .. switchPosition .. " active")
        end

        if message == "RESET" then
            rs.setOutput(outputSideGate, false)
            rs.setOutput(outputSideLamp, false)
            term.setTextColor(colors.orange)
            print("[INFO   ] Termination sequence received ...")
            print("[INFO   ] Resetting ...")
            sleep(1)
            reset()
        end

        if message == "PING" then
            initNetwork()
            reset()
        end
    end  
end

