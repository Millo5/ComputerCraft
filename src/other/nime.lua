
local amount = 80
local returnAmount = 0

function validBlock(block)
    -- everything is valid except if the name contains ore
    return not string.find(block.name, "ore")
end

function mineIter()

    local exists, block = turtle.inspect()
    if exists then
        if validBlock(block) then
            turtle.dig()
        else
            return false
        end
    end
    turtle.forward()

    exists, block = turtle.inspectUp()
    if exists and validBlock(block) then
        turtle.digUp()
    end

    exists, block = turtle.inspectDown()
    if exists and validBlock(block) then
        turtle.digDown()
    end

    return true
end

for i = 1, amount do
    returnAmount = i
    if not mineIter() then
        break
    end
end

turtle.turnRight()
turtle.dig()
turtle.forward()
turtle.turnRight()

for j = 1, returnAmount do
    if not mineIter() then
        break
    end
end
