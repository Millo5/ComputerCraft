local LibDeflate = require("LibDeflate")

local websocket = http.websocket("wss://26fd-81-207-247-206.ngrok-free.app")

local monitor = peripheral.find("monitor")

local w,h = monitor.getSize()
local width = 80
local height = 48

local xOffset = (w - width) / 2
local yOffset = (h - height) / 2

monitor.setTextScale(0.5)
monitor.setCursorPos(1, 1)
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear()


while true do
    local response = websocket.receive()
    if response then
        print(response)
        break
    end
end

-- while true do
--     local response = websocket.receive()
--     if response then

--         local bytes = { string.byte(response, 1, -1) }
--         -- loop over the bytes, 2 at a time
--         -- for i = 1, #bytes, 2 do

--         --     local char = string.char(bytes[i])
--         --     local cols = bytes[i + 1]

--         --     local fg = string.format("%X", bit.band(bit.brshift(cols, 4), 0xF))
--         --     local bg = string.format("%X", bit.band(cols, 0xF))

--         --     term.blit(char, fg, bg)
--         -- end
        
--         local line = {
--             fg = "",
--             bg = "",
--             text = ""
--         }
--         local x = xOffset
--         local y = yOffset
--         monitor.setCursorPos(x, y)
--         for i = 1, #bytes, 2 do
--             local charB = bytes[i]

--             if charB == 0 then
--                 monitor.blit(line.text, line.fg, line.bg)
--                 line = {
--                     fg = "",
--                     bg = "",
--                     text = ""
--                 }
                
--                 x = xOffset
--                 y = y + 1
--                 monitor.setCursorPos(x, y)
--             else
--                 x = x + 1

--                 local char = string.char(charB)
--                 local cols = bytes[i + 1]
--                 local fg = string.format("%X", bit.band(bit.brshift(cols, 4), 0xF))
--                 local bg = string.format("%X", bit.band(cols, 0xF))
                
--                 line.fg = line.fg .. fg
--                 line.bg = line.bg .. bg
--                 line.text = line.text .. char
--             end
--         end

--         monitor.blit(line.text, line.fg, line.bg)
--     else 
--         print("No response")
--         break
--     end
-- end
