
local Chest = {}
Chest.__index = Chest

function Chest.new(inv, cache)
    local self = {}
    setmetatable(self, Chest)
    self.inv = inv
    self.name = peripheral.getName(inv)
    self.cache = cache
    return self
end

function Chest:moveAll(to)
    for i, item in pairs(self.inv.list()) do
        self.inv.pushItems(to.name, i, item.count)
    end
end

function Chest:moveItems(to, slot, count)
    return self.inv.pushItems(to.name, slot, count)
end

function Chest:moveItemsById(to, id, count)
    for i, item in pairs(self.inv.list()) do
        if item.name == id then
            return self.inv.pushItems(to.name, i, count)
        end
    end
    return 0
end

return Chest
