local Chest = require("Chest")
local Cache = require("Cache")
local Display = require("Display")
local completion = require("cc.completion")

local cache = Cache.new()
local display = Display.new(cache)

cache:load()
cache:cacheAll()



function main()
    parallel.waitForAny(function() display:start() end, terminalLoop)
end


function terminalLoop()
    
    while true do
        term.clear()
        term.setCursorPos(1, 1)

        local choices = {
            "list",
            "index",
            "add", -- Add items from the tray to the main storage
            "get", -- Get items from the main storage
        }

        term.write("Choices: " .. table.concat(choices, ", "))
        term.setCursorPos(1, 2)
        term.write("Choice> ")
        local choice = read(nil, choices, function(text) return completion.choice(text, choices) end)
        local args = {}
        for arg in string.gmatch(choice, "%S+") do
            table.insert(args, arg)
        end

        handleChoice(choice, args)
    end

end

function handleChoice(choice, args)
    if choice == "list" then
        cache:print()
        print("Press enter to continue")
        read() -- Wait for enter
    elseif choice == "index" then
        print("Indexing...")
        cache:cacheAll()
        cache:save()
    elseif choice == "add" then
        cache:addTray()
        cache:save()
    elseif args[1] == "get" then
        local id = args[2]
        local count = tonumber(args[3]) or 1

        if id == nil then
            print("No id provided")
            print("Press enter to continue")
            read()
            return
        end

        print("Getting " .. count .. " of " .. id)
        sleep(1)

        cache:fetch(id, count)
    end
end

main()

