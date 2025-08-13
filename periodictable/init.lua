
-- local url = "https://raw.githubusercontent.com/Millo5/ComputerCraft/master/src/lua/"
local url = "https://raw.githubusercontent.com/Millo5/ComputerCraft/refs/heads/master/periodictable/"
local ids = { "init", "startup", "PeriodicTable" }

for i, v in pairs(ids) do
    if fs.exists(v .. ".lua") then
        fs.delete(v .. ".lua")
    end
end


for i, v in pairs(ids) do
    print("Downloading " .. v .. ".lua")
    local uniqueParam = "?nocache=" .. os.epoch("utc")

    print(url .. v .. ".lua" .. uniqueParam)
    local h = http.get(url .. v .. ".lua" .. uniqueParam)
    local f = fs.open(v .. ".lua", "w")
    f.write(h.readAll())
    f.close()
    h.close()
end
