
local Chest = {}
Chest.__index = Chest

function Chest.new(inv)
    local self = {}
    setmetatable(self, Chest)
    self.inv = inv
    self.name = peripheral.getName(inv)
    return self
end

function Chest:moveAll(to)
    for i, item in pairs(self.inv.list()) do
        self.inv.pushItems(to.name, i, item.count)
    end
end

function Chest:pushItems(to, slot, count)
    self.inv.pushItems(to.name, slot, count)
end

return Chest
