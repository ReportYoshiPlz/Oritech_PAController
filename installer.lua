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
print("--- Particle Accelerator Installer ---")
print("Modus: Komplette Neuinstallation")
print("1) Controller")
print("2) Switch")
write("> ")
local choice = read()

if choice == "1" then
    print("\nLade alle Dateien von GitHub...")
    downloadFullProject("") -- Lädt alles, auch die originale config.lua

    print("\n--- Konfiguration anpassen ---")
    write("Protokoll (Standard: Collider 1): ")
    local prot = read()
    prot = (prot ~= "" and prot or "Collider 1")

    write("Primary Injection Side: ")
    local pSide = read()

    write("Secondary Injection Side: ")
    local sSide = read()

    -- Bestehende config.lua laden, um andere Werte zu erhalten
    local config = require("config")
    
    -- Werte im Table überschreiben
    config.protocol = prot
    config.primaryInjectionSide = pSide
    config.secondaryInjectionSide = sSide

    -- Datei mit aktualisierten Werten neu schreiben
    local f = fs.open("config.lua", "w")
    f.writeLine("local config = " .. textutils.serialize(config))
    f.writeLine("return config")
    f.close()
    
    print("[OK] Einstellungen in config.lua aktualisiert.")

elseif choice == "2" then
    print("\nInstalliere Switch...")
    if fs.exists("startup.lua") then fs.delete("startup.lua") end
    downloadFile("modules/switchControl.lua", "startup.lua")
    -- Hier könntest du analog die Settings-Logik von vorhin einbauen
end

print("\nInstallation abgeschlossen! Neustart...")
sleep(2)
os.reboot()