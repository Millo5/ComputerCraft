
local Chest = require("Chest")

local Cache = {}
Cache.__index = Cache

function Cache.new()
    local self = {}
    setmetatable(self, Cache)
    self.cache = {} -- { chestName: { itemName: count } }
    self.itemCache = {} -- { itemName: { count: count, chests: { chestName } } }
    self.trayId = nil
    return self
end

function list_contains(list, item)
    for i, v in pairs(list) do
        if v == item then
            return true
        end
    end
    return false
end


function Cache.getTrayChest()

end

function Cache.getStorageChests()
    local chests = { peripheral.find("inventory") }
    local trayChest
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
            self.itemCache[item.name] = {count = 0, chests = {}}
        end

        self.itemCache[item.name].count = self.itemCache[item.name].count + item.count
        if not list_contains(self.itemCache[item.name].chests, chest.name) then
            table.insert(self.itemCache[item.name].chests, chest.name)
        end
    end
end

function Cache:save()
    local file = fs.open("savedCache", "w")

    file.write(self.trayId .. "\n")

    for chest, items in pairs(self.cache) do
        file.write("#" .. chest .. "\n")

        for item, count in pairs(items) do
            file.write(item .. " " .. count .. "\n")
        end
    end

    file.write("\n")

    for item, chests in pairs(self.itemCache) do
        file.write("#" .. item .. "\n")
        file.write(chests.count .. "\n")

        for i, chest in pairs(chests.chests) do
            file.write(chest .. "\n")
        end
    end

    file.close()
end


function Cache:load()
    local file = fs.open("savedCache", "r")
    local chest = nil
    local item = nil

    if file == nil then
        write("Enter tray id: ")
        self.trayId = read()
        return
    end

    self.trayId = file.readLine()

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
            self.itemCache[item] = {count = 0, chests = {}}
        else
            if item == nil then
                break
            end

            if self.itemCache[item] == nil then
                self.itemCache[item] = {count = 0, chests = {}}
            end

            if self.itemCache[item].count == 0 then
                self.itemCache[item].count = tonumber(line)
            else
                table.insert(self.itemCache[item].chests, line)
            end
        end
    end

    file.close()
end


function Cache:print()
    for i, item in pairs(self.cache) do
        print(i)
        for j, count in pairs(item) do
            print("  ", j, count)
        end
    end
    print("\n")
    for i, item in pairs(self.itemCache) do
        print(i, item.count)
        for j, chest in pairs(item.chests) do
            print("  ", chest)
        end
    end
end

function Cache:cacheAll()
    local chests = { peripheral.find("inventory") }
    local trayChest = Chest.new(peripheral.wrap("left"))

    self.cache = {}
    self.itemCache = {}

    for i, chest in pairs(chests) do
        local chest = Chest.new(chest)
        if chest.name ~= trayChest.name then
            self:cacheChest(chest)
        end
    end
end

function Cache:addTray()
    local chests = { peripheral.find("inventory") }
    local trayChest = Chest.new(peripheral.wrap("left"))

    local targetChest = nil
    for slot, item in pairs(trayChest.inv.list()) do

        while item.count > 0 do
            
            if targetChest ~= nil then
                print("Pushing to " .. targetChest.name .. " from " .. trayChest.name)
                print("Item count before: " .. item.count)
                trayChest:moveAll(targetChest)
                print("Pushed " .. count .. " items to " .. targetChest.name)
                print("Item count: " .. item.count)
            else
                local chest = chests[1]
                targetChest = Chest.new(chest)
            end

        end

    end


end

return Cache
