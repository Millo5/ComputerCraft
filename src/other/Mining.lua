
local width = 12
local length = 12
local depth = 24

local function dig()
    for k = 1, depth do
        for i = 1, length do
            if i > 1 then
                if i % 2 == 0 then
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                end
                turtle.dig()
                turtle.forward()
                turtle.digDown()
                if i % 2 == 0 then
                    turtle.turnRight()
                else
                    turtle.turnLeft()
                end
            end

            for j = 1, width - 1 do
                turtle.dig()
                turtle.forward()
                turtle.digDown()
            end
        end

        -- Go back to the start
        if depth % 2 == 0 then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
        for i = 1, length do
            turtle.forward()
        end
        if depth % 2 == 0 then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end

        turtle.digDown()
        turtle.down()
        turtle.digDown()
        turtle.down()
        turtle.digDown()

    end
end

dig()