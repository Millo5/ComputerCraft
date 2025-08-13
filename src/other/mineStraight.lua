local amount = 800

turtle.refuel()

for i = 1, amount do
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
end

turtle.turnRight()
turtle.turnRight()

for i = 1, amount do
    turtle.forward()
end
