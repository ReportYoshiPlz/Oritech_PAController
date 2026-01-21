--- CONFIGURATION
local USER = "ReportYoshiPlz"
local REPO = "Minecraft.Oritech_ParticleAcceleratorMain"
local BRANCH = "main"

local API_URL = "https://api.github.com/repos/"..USER.."/"..REPO.."/contents/"
local RAW_URL = "https://raw.githubusercontent.com/"..USER.."/"..REPO.."/"..BRANCH.."/"

local function downloadFolder(path)
    local response = http.get(API_URL .. path .. "?ref=" .. BRANCH)
    if not response then 
        print("Error: Connection failed")
        return 
    end
    
    local data = textutils.unserialiseJSON(response.readAll())
    response.close()

    for _, item in ipairs(data) do
        if item.type == "dir" then
            -- Checks, if folder exists
            if not fs.exists(item.path) then
                fs.makeDir(item.path)
            end
            -- Recursive call for the folder structure
            downloadFolder(item.path)
        elseif item.type == "file" then
            print("Lade: " .. item.path)
            local fileRes = http.get(RAW_URL .. item.path)
            if fileRes then
                local f = fs.open(item.path, "w")
                f.write(fileRes.readAll())
                f.close()
                fileRes.close()
            end
        end
    end
end

term.clear()
term.setCursorPos(1,1)
print("Info: Installing files")
downloadFolder("") 
print("Info: Installation finished!")
print("Info: Restarting PC ...")
sleep(3)
os.reboot()