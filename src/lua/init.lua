
local url = "https://raw.githubusercontent.com/Millo5/ComputerCraft/master/src/lua/"
local ids = { "init", "startup", "Cache", "Chest", "Display" }

for i, v in pairs(ids) do
    if fs.exists(v .. ".lua") then
        fs.delete(v .. ".lua")
    end
end

-- Delete cache file
-- if fs.exists("savedCache") then
--     fs.delete("savedCache")
-- end

for i, v in pairs(ids) do
    print("Downloading " .. v .. ".lua")
    local uniqueParam = "?nocache=" .. os.epoch("utc")

    local h = http.get(url .. v .. ".lua" .. uniqueParam)
    local f = fs.open(v .. ".lua", "w")
    f.write(h.readAll())
    f.close()
    h.close()
end
