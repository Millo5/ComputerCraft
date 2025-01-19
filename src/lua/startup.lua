local Chest = require("Chest")
local Cache = require("Cache")
local completion = require("cc.completion")

local cache = Cache.new()

cache:load()

function main()

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

        if choice == "exit" then
            break
        elseif choice == "list" then
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
        elseif choice == "get" then
            local args = choice.split(" ")
            local id = args[2]
            local count = args[3] or 1

            if id == nil then
                print("No id provided")
                print("Press enter to continue")
                read()
                break
            end

            cache:fetch(id, count)
        end

    end

end

main()

