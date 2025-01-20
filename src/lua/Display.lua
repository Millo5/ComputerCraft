
local Display = {}
Display.__index = Display

function Display.new(cache)
    local self = {}
    setmetatable(self, Display)
    self.monitor = peripheral.find("monitor")
    self.monitor.setTextScale(0.5)
    self.monitor.clear()

    self.cache = cache
    return self
end

function Display:start()
    parallel.waitForAny(function() self:loop() end, function() self:inputLoop() end)
end

function Display:inputLoop()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        print("Touched at " .. x .. ", " .. y)
    end
end

function Display:loop()
    self.monitor.setBackgroundColor(colors.black)
    self.monitor.setTextColor(colors.white)

    while true do
        self.monitor.clear()

        self.monitor.setCursorPos(1, 1)
        self.monitor.write("Storage Status: " .. self.cache.state)
        self.monitor.setCursorPos(1, 2)
        local size = { self.monitor.getSize() }
        self.monitor.write(string.rep("-", size[1]))

        self:displayItems()
        sleep(0.1)
    end
end


function Display:displayItems()

    local sortables = {}
    for name, item in pairs(self.cache.itemCache) do
        table.insert(sortables, item)
    end

    table.sort(sortables, function(a, b) return a.count > b.count end)


    local y = 3
    for name, item in pairs(sortables) do
        self.monitor.setCursorPos(1, y)
        self.monitor.write(item.display .. ": " .. item.count)
        y = y + 1

        if y > self.monitor.getSize() then
            break
        end
    end
end

return Display