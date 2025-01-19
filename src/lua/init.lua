
local ids = {
    startup = "vvd47FkK",
    Chest = "uHnKqwfY",
    Cache = "7yQBA3gS"
}

-- delete old files
for k, v in pairs(ids) do
    if fs.exists(k .. ".lua") then
        fs.delete(k .. ".lua")
    end
end

-- download new files
for k, v in pairs(ids) do
    local h = http.get("https://pastebin.com/raw/" .. v)
    local f = fs.open(k .. ".lua", "w")
    f.write(h.readAll())
    f.close()
    h.close()
end