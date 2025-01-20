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

    self.state = "idle"

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
        if item ~= nil then
            self:cacheItem(chest, item, i)
        end
    end

end

function Cache:cacheItem(chest, item, slot)
    self:cacheItemAmount(chest, item, slot, item.count)
end

function Cache:cacheItemAmount(chest, item, slot, amount)
    local count = self.cache[chest.name][item.name]

    if count == nil then
        count = 0
    end

    self.cache[chest.name][item.name] = count + amount

    if self.itemCache[item.name] == nil then
        local itemCache = {count = 0, chests = {}}
        itemCache.display = chest.inv.getItemDetail(slot).displayName
        self.itemCache[item.name] = itemCache
    end

    self.itemCache[item.name].count = self.itemCache[item.name].count + amount
    if not list_contains(self.itemCache[item.name].chests, chest.name) then
        table.insert(self.itemCache[item.name].chests, chest.name)
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

    for id, data in pairs(self.itemCache) do
        file.write("#" .. id .. " " .. data.display .. "\n")
        file.write(data.count .. "\n")

        for i, chest in pairs(data.chests) do
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
            local id, display = string.match(line, "#(.+) (.+)")
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
    for id, data in pairs(self.itemCache) do
        print(data.count .. "x " .. data.display)
    end
    
    -- for i, item in pairs(self.cache) do
    --     print(i)
    --     for j, count in pairs(item) do
    --         print("  ", j, count)
    --     end
    -- end
    -- print("\n")
    -- for i, item in pairs(self.itemCache) do
    --     print(i, item.count)
    --     for j, chest in pairs(item.chests) do
    --         print("  ", chest)
    --     end
    -- end
end

function Cache:cacheAll()
    self:setState("indexing")

    local chests = self:getStorageChests()

    self.cache = {}
    self.itemCache = {}

    for i, chest in pairs(chests) do
        local chest = Chest.new(chest)
        self:cacheChest(chest)
    end
    
    self:idleState()
end

function Cache:addTray()

    print("Moving all items from tray to storage")

    self:setState("emptying tray")

    local trayChest = self:getTrayChest()
    local chests = self:getStorageChests()

    local outOfSpace = false

    local targetChest = nil
    local items = trayChest.inv.list()
    for slot, item in pairs(items) do
        self:setState("emptying tray: " .. slot .. "/" .. #items)

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

                            self:cacheItemAmount(chest, item, slot, moved)

                            if (moved > 0) then
                                targetChest = chest
                                break
                            end

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

                        self:cacheItemAmount(chest, item, slot, moved)

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

            local moved = trayChest:moveItems(targetChest, slot, item.count)
            item.count = item.count - moved

            self:cacheItemAmount(targetChest, item, slot, moved)

            if (moved == 0) then
                targetChest = nil
            end

        end

    end

    -- self:cacheAll()

    if outOfSpace then
        print("Out of space!")
        sleep(2)
        print("\nEnter to continue\n")
        read()
    end

    self:idleState()

end

function Cache:setState(state)
    self.state = state
end
function Cache:idleState()
    self.state = "idle"
end

function Cache:fetch(id, count)
    
    local itemCache = self.itemCache[id]
    local tray = self:getTrayChest()

    self:setState("fetching")

    if itemCache == nil then
        print("Item not found")
        print("Press enter to continue")
        read()

        self:idleState()
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

                self:cacheItemAmount(chest, {name = id}, slot, -moved)

                if count == 0 then
                    break
                end
            end
        end
    end
    
    self:idleState()
    
end

return Cache
