--- CONFIGURATION & SETTINGS ---
local SETTING_PROTOCOL = "switch.protocol"
local SETTING_GATE     = "switch.outputGate"
local SETTING_LAMP     = "switch.outputLamp"
local SETTING_POS      = "switch.position"

-- Function for first Setup
local function firstTimeSetup()
    if settings.get(SETTING_PROTOCOL) == nil then
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.yellow)
        print("--- SWITCH SETUP ---")
        
        term.setTextColor(colors.white)
        print("")
        print("[INFO] Please enter the unique ID of your collider (Standard: 1): ")
        term.setTextColor(colors.yellow)
        write("> ")
        term.setTextColor(colors.white)

        local prot = read()
        settings.set(SETTING_PROTOCOL, prot ~= "" and prot or "Collider 1")

        print("")
        print("[INFO] Where is the Gate located (e. g. TOP)?")
        term.setTextColor(colors.yellow)
        write("> ")
        term.setTextColor(colors.white)
        settings.set(SETTING_GATE, read())

        print("")
        print("[INFO] Where is the redstone lamp located (e. g. FRONT)?")
        term.setTextColor(colors.yellow)
        write("> ")
        term.setTextColor(colors.white)
        settings.set(SETTING_LAMP, read())
        
        print("")
        print("[INFO] Please set the name of the switch (multi-switch-setup not yet implemented, set to SWITCH 1): ")
        term.setTextColor(colors.yellow)
        write("> ")
        settings.set(SETTING_POS, read())

        settings.save(".settings")
        
        print("")
        term.setTextColor(colors.lime)
        print("[SUCCESS] Settings saved successfully ...")
        sleep(1)
    end
end

-- Start first time setup
firstTimeSetup()

-- Load variables from settings
local networkProtocol = settings.get(SETTING_PROTOCOL)
local outputSideGate  = settings.get(SETTING_GATE)
local outputSideLamp  = settings.get(SETTING_LAMP)
local switchPosition   = settings.get(SETTING_POS)

local modem = peripheral.find("modem")



--- FUNCTIONS ---
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
        -- Open rednet 
        local modemName = peripheral.getName(modem)
        rednet.open(modemName)
        
        term.setTextColor(colors.white)
        print("[INFO   ] Modem found: " .. modemName)
        term.setTextColor(colors.lime)
        print("[SUCCESS] Connected to network")
        term.setTextColor(colors.white)
        print("[INFO   ] Protocol: " .. networkProtocol)
        print("[INFO   ] Position: " .. switchPosition)
        rednet.broadcast(switchPosition .. " ready", networkProtocol)
    else 
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.red)
        print("[ERROR  ] No modem detected")
    end 
end

--- MAIN ---
reset()
initNetwork()

while true do
    local id, message, protocol = rednet.receive(networkProtocol)
    
    print("MESSAGE RECEIVED: " .. tostring(message))

    if message == switchPosition then
        rs.setOutput(outputSideGate, true)
        rs.setOutput(outputSideLamp, true)
        term.setTextColor(colors.lime)
        print("[SUCCESS] Redirect " .. switchPosition .. " active")

    elseif message == "RESET" then
        rs.setOutput(outputSideGate, false)
        rs.setOutput(outputSideLamp, false)
        term.setTextColor(colors.orange)
        print("[INFO   ] Termination sequence received ...")
        print("[INFO   ] Resetting ...")
        sleep(1)
        reset()

    elseif message == "PING" then
        initNetwork()
        reset()
    end  
end

