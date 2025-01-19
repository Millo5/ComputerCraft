local completion = require("cc.completion")
local Chest = require("Chest")

local Cache = {}
Cache.__index = Cache

function Cache.new()
    local self = {}
    setmetatable(self, Cache)
    self.cache = {} -- { chestName: { itemName: count } }
    self.itemCache = {} -- { itemName: { display: name, count: count, chests: { chestName } } }

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


function Cache:getTrayChest()
    return Chest.new(peripheral.wrap(self.trayId))
end

function Cache:getStorageChests()
    local chests = { peripheral.find("inventory") }
    local invalid = { self.trayId, "front", "back", "left", "right", "top", "bottom" }
    for i, chest in pairs(chests) do
        if list_contains(invalid, peripheral.getName(chest)) then
            table.remove(chests, i)
        end
    end
    return chests
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
            local itemCache = {count = 0, chests = {}}
            itemCache.display = chest.inv.getItemDetail(i).displayName
            self.itemCache[item.name] = itemCache
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
        file.write("#" .. item .. " " .. item.display .. "\n")
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
        local names = peripheral.getNames()
        write("Enter tray id: ")
        self.trayId = read(nil, names, function(text) return completion.choice(text, names) end)
        return
    end

    self.trayId = file.readLine()

    while true do
        local line = file.readLine()
        print(line)

        if line == nil or line == "" then
            break
        end

        if string.sub(line, 1, 1) == "#" then
            chest = string.sub(line, 2, string.len(line))
            self.cache[chest] = {}
        else
            local item, count = string.match(line, "(%w+) (%d+)")
            self.cache[chest][item] = tonumber(count)
        end
    end

    while true do
        local line = file.readLine()

        if line == nil or line == "" then
            break
        end

        if string.sub(line, 1, 1) == "#" then
            local id, display = string.match(line, "#(%w+) (.+)")
            item = id
            self.itemCache[item] = {count = 0, chests = {}, display = display}
        else
            if line == nil or line == "" then
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
    local chests = self:getStorageChests()

    self.cache = {}
    self.itemCache = {}

    for i, chest in pairs(chests) do
        local chest = Chest.new(chest)
        self:cacheChest(chest)
    end
end

function Cache:addTray()
    local trayChest = self:getTrayChest()
    local chests = self:getStorageChests()

    local outOfSpace = false

    local targetChest = nil
    for slot, item in pairs(trayChest.inv.list()) do

        while item.count > 0 do
            
            if targetChest == nil then
                -- Find chest that has the item and has room
                local itemCache = self.itemCache[item.name]
                if itemCache ~= nil then
                    local foundIn = self.itemCache[item.name].chests
                    -- Check if any of the chests have room that have the item
                    for i, chestName in pairs(foundIn) do
                        local chest = peripheral.wrap(chestName)
                        if chest ~= nil then
                            local chest = Chest.new(chest)
                            local moved = trayChest:moveItems(chest, slot, item.count)
                            item.count = item.count - moved

                            if (moved > 0) then
                                targetChest = chest
                                break
                            end

                        end
                    end

                    if targetChest == nil then
                        -- No chest had room to stack the item find a new chest that has room
                        local chests = self:getStorageChests()
                        for i, chest in pairs(chests) do
                            local chest = Chest.new(chest)
                            local moved = trayChest:moveItems(chest, slot, item.count)
                            item.count = item.count - moved

                            if (moved > 0) then
                                targetChest = chest
                                break
                            end
                        end
                    end

                    if targetChest == nil then
                        -- No chests have room to stack the item, break out of loop
                        outOfSpace = true
                        break
                    end

                end
            end

            local moved = trayChest:moveItems(targetChest, slot, item.count)
            item.count = item.count - moved

            if (moved == 0) then
                targetChest = nil
            end

        end

    end

    self:cacheAll()

    if outOfSpace then
        print("Out of space!")
        sleep(2)
        print("\nEnter to continue\n")
        read()
    end

end


function Cache:fetch(id, count)
    
    local itemCache = self.itemCache[id]
    local tray = self:getTrayChest()

    if itemCache == nil then
        print("Item not found")
        print("Press enter to continue")
        read()
        return
    end

    local chests = itemCache.chests
    for i, chestName in pairs(chests) do
        local chest = peripheral.wrap(chestName)
        if chest ~= nil then
            local chest = Chest.new(chest)
            while count > 0 do
                local moved = chest:moveItemsById(tray, id, count)
                count = count - moved

                if count == 0 then
                    break
                end
            end
        end
    end

    self:cacheAll()

end

return Cache
