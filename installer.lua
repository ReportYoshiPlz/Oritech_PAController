--- CONFIGURATION
local USER = "ReportYoshiPlz"
local REPO = "Minecraft.Oritech_ParticleAcceleratorMain"
local BRANCH = "main"

local RAW_URL = "https://raw.githubusercontent.com/"..USER.."/"..REPO.."/"..BRANCH.."/"
local API_URL = "https://api.github.com/repos/"..USER.."/"..REPO.."/contents/"

local function downloadFile(repoPath, localPath)
    print("Lade: " .. repoPath)
    local response = http.get(RAW_URL .. repoPath)
    if response then
        local f = fs.open(localPath, "w")
        f.write(response.readAll())
        f.close()
        response.close()
        return true
    end
    return false
end

local function downloadFullProject(path)
    local response = http.get(API_URL .. path .. "?ref=" .. BRANCH)
    if not response then return end
    local data = textutils.unserialiseJSON(response.readAll())
    response.close()

    for _, item in ipairs(data) do
        if item.type == "dir" then
            if not fs.exists(item.path) then fs.makeDir(item.path) end
            downloadFullProject(item.path)
        elseif item.type == "file" then
            downloadFile(item.path, item.path)
        end
    end
end

-- INSTALLER UI
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.orange)
print("--- PARTICLE ACCELERATOR INSTALLER ---")
print("")
term.setTextColor(colors.white)
print("[INFO] Which component do you want to install? Please enter number.")
print("")
print("1: Controller")
print("2: Switch")
term.setTextColor(colors.yellow)
write("> ")


local choice = read()

if choice == "1" then
    print("")
    print("[INFO] Downloading files from GitHub")
    downloadFullProject("") 

    term.setTextColor(colors.white)
    print("")
    print("[INFO] Please adjust the following settings: ")
    print("[INFO] Please enter an unique ID for your collider (Standard: 1): ")
    term.setTextColor(colors.yellow)
    write("> ")
    local prot = read()
    prot = ("Collider "..prot) or "Collider 1"

    term.setTextColor(colors.white)
    print("")
    print("[INFO] Please specify the side for the primary injection redstone signal (e. g. LEFT, RIGHT, ...): ")
    term.setTextColor(colors.yellow)
    write("> ")
    local pSide = read()

    term.setTextColor(colors.white)
    print("")
    print("[INFO] Please specify side for the secondary injection redstone signal (e. g. RIGHT, ...):")
    term.setTextColor(colors.yellow)
    write("> ")
    local sSide = read()
    
    term.setTextColor(colors.white)
    print("")
    print("[INFO] Please specify side for the activation redstone signal (e. g. FRONT, ...):")
    term.setTextColor(colors.yellow)
    write("> ")
    local aSide = read()

    -- OVERWRITE standard variables in config-file
    local config = require("config")
    
    -- OVERWRITE values in table
    config.protocol = prot
    config.primaryInjectionSide = pSide
    config.secondaryInjectionSide = sSide
    config.activationSide = aSide

    -- SAVE file with new values
    local f = fs.open("config.lua", "w")
    f.writeLine("local config = " .. textutils.serialize(config))
    f.writeLine("return config")
    f.close()
    
    print("")
    term.setTextColor(colors.lime)
    print("[SUCCESS] Settings saved!")

elseif choice == "2" then
    print("")
    term.setTextColor(colors.white)
    print("[INFO] Installiere Switch...")
    if fs.exists("startup.lua") then fs.delete("startup.lua") end
    downloadFile("modules/switchControl.lua", "startup.lua")
   
end

print("")
term.setTextColor(colors.lime)
print("[SUCCESS] Installation finished! Rebooting ...")
sleep(2)
os.reboot()