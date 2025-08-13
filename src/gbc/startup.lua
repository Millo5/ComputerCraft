local websocket, err = http.websocket("ws://localhost:50505")

if not websocket then
    printError("Failed to open websocket: " .. err)
    return
end


local monitor = peripheral.find("monitor")

monitor.setTextScale(0.5)
local w,h = monitor.getSize()
local width = 80
local height = 48

-- local screen = surface.create(w, h)

local xOffset = (w - width) / 2
local yOffset = (h - height) / 2

monitor.setTextScale(0.5)
monitor.setCursorPos(1, 1)
monitor.setPaletteColor(colors.black, 0, 0, 0)
monitor.setPaletteColor(colors.white, 1, 1, 1)
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear()


function handleResponse(response)

    local bytes = { string.byte(response, 1, -1) }

    for i = 0, 15 do
        -- print(i, bytes[i * 3 + 1], bytes[i * 3 + 2], bytes[i * 3 + 3])
        local r = bytes[i * 3 + 1] / 255
        local g = bytes[i * 3 + 2] / 255
        local b = bytes[i * 3 + 3] / 255
        monitor.setPaletteColor(2^i, r, g, b)
    end

    -- Trim the first 48 bytes
    response = response:sub(49)

    local bufferCutoff = #response / 2
    local blitStr = response:sub(1, bufferCutoff)
    local colrStr = response:sub(bufferCutoff + 1)

    local x = xOffset
    local y = yOffset
    monitor.setCursorPos(x, y)

    -- print(#blitStr)
    -- print(#colrStr)

    for i = 1, #blitStr do

        local char = string.char(string.byte(blitStr, i))
        local color = string.byte(colrStr, i)

        local bg = bit.band(color, 0x0F)
        local fg = bit.brshift(bit.band(color, 0xF0), 4)

        -- print(string.byte(blitStr, i), char, string.format("%X", fg), string.format("%X", bg))
        
        -- while true do
        --     sleep(2)
        -- end

        x = x + 1
        -- if char == "\n" then
        -- if x > width + xOffset then
        if i % width == 0 then
            y = y + 1
            x = xOffset
            monitor.setCursorPos(x, y)
        else
            monitor.blit(char, string.format("%X", fg), string.format("%X", bg))
        end

    end

    -- for i = 1, #response do

    --     local char = string.char(string.byte(response, i))

    --     if char == "\n" then
    --         y = y + 1
    --         monitor.setCursorPos(x, y)
    --     else
    --         monitor.blit(" ", char, char)
    --     end

    -- end

    websocket.send("ACK")

end




while true do
    local response = websocket.receive()
    if response == nil then
        break
    end

    if response == "hello" then
        print("Connected to server")
        websocket.send("hello")
    else
        handleResponse(response)
    end

end