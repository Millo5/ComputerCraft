
local url = "https://raw.githubusercontent.com/Millo5/ComputerCraft/master/src/lua/"
local ids = { "startup", "Cache", "Chest" }

for i, v in pairs(ids) do
    if fs.exists(v .. ".lua") then
        fs.delete(v .. ".lua")
    end
end

for i, v in pairs(ids) do
    local h = http.get(url .. v .. ".lua")
    local f = fs.open(v .. ".lua", "w")
    f.write(h.readAll())
    f.close()
    h.close()
end
