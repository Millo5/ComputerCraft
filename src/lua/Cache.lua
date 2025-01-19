
local Cache = {}
Cache.__index = Cache

function Cache.new()
    local self = {}
    setmetatable(self, Cache)
    self.cache = {} -- { chestName: { itemName: count } }
    self.itemCache = {} -- { itemName: { chestName } }
    return self
end

function Cache:cacheChest(chest)
    self.cache[chest.name] = {}

    for i, item in pairs(chest.inv.list()) do
        local count = self.cache[chest.name][item.name]

        if count == nil then
            count = 0
        end

        self.cache[chest.name][item.name] = count + item.count

        if self.itemCache[item.name] == nil then
            self.itemCache[item.name] = {}
        end

        table.insert(self.itemCache[item.name], chest.name)

    end

end

function Cache:save()
    local file = fs.open("cache", "w")

    for chest, items in pairs(self.cache) do
        file.write("#" .. chest .. "\n")

        for item, count in pairs(items) do
            file.write(item .. " " .. count .. "\n")
        end
    end

    file.write("\n")

    for item, chests in pairs(self.itemCache) do
        file.write("#" .. item .. "\n")

        for i, chest in pairs(chests) do
            file.write(chest .. "\n")
        end
    end

    file.close()
end


function Cache:load()
    local file = fs.open("cache", "r")
    local chest = nil
    local item = nil

    if file == nil then
        return
    end

    while true do
        local line = file.readLine()

        if line == nil then
            break
        end

        if string.sub(line, 1, 1) == "#" then
            chest = string.sub(line, 2, string.len(line) - 1)
            self.cache[chest] = {}
        else
            local item, count = string.match(line, "(%w+) (%d+)")
            self.cache[chest][item] = tonumber(count)
        end
    end

    while true do
        local line = file.readLine()

        if line == nil then
            break
        end

        if string.sub(line, 1, 1) == "#" then
            item = string.sub(line, 2, string.len(line) - 1)
            self.itemCache[item] = {}
        else
            table.insert(self.itemCache[item], line)
        end
    end

    file.close()
end


function Cache:print()
    for i, item in pairs(self.cache) do
        print(i, item)
    end
    print("\n")
    for i, item in pairs(self.itemCache) do
        print(i, item)
    end
end

function Cache:cacheAll()
    local chests = { peripheral.find("inventory") }
    local trayChest = Chest.new(peripheral.wrap("left"))

    for i, chest in pairs(chests) do
        local chest = Chest.new(chest)
        if chest.name ~= trayChest.name then
            self:cacheChest(chest)
        end
    end
end

return Cache
