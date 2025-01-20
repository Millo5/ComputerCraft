
local Display = {}
Display.__index = Display

function Display.new()
    local self = {}
    setmetatable(self, Display)
    self.monitor = peripheral.find("monitor")
    self.monitor.setTextScale(0.5)
    self.monitor.clear()
    return self
end

function Display:displayItems(cache)

    local sortables = {}
    for name, item in pairs(cache.itemCache) do
        table.insert(sortables, item)
    end

    table.sort(sortables, function(a, b) return a.count > b.count end)

    self.monitor.setBackgroundColor(colors.black)
    self.monitor.setTextColor(colors.white)

    self.monitor.clear()

    self.monitor.setCursorPos(1, 1)
    self.monitor.write("Storage Status: " .. cache.state)
    self.monitor.setCursorPos(1, 2)
    local size = { self.monitor.getSize() }
    self.monitor.write(string.rep("-", size[1]))

    local y = 3
    for name, item in pairs(sortables) do
        self.monitor.setCursorPos(1, y)
        self.monitor.write(item.display .. ": " .. item.count)
        y = y + 1

        if y > 24 then
            break
        end
    end
end

return Display