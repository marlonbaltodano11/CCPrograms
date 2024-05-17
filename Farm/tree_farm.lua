local block_moved = 2

function SuckAround()
    for i = 1, 4 do
        turtle.turnRight()
        turtle.suck()
    end
end

function KeepForward()
	local _, data = turtle.inspect()
	if data["name"] == "minecraft:oak_leaves" then
		turtle.dig()
	end

	local moved, _ = turtle.forward()
	
	while moved do
		block_moved = block_moved + 1

		_, data = turtle.inspect()

		if data["name"] == "minecraft:oak_leaves" then
			turtle.dig()
		end

		moved, _ = turtle.forward();
	end

	return
end

function ChopTree()
	turtle.dig()
	turtle.forward()
	block_moved = block_moved + 1 
	
	turtle.digUp()
	turtle.up()
	turtle.digUp()
	turtle.up()
	turtle.digUp()
	turtle.up()
	turtle.digUp()

	turtle.down()
	turtle.down()
	turtle.down()
end

function EndJourney()
	turtle.turnRight()
	turtle.turnRight()
	turtle.digUp()
	turtle.up()

	turtle.select(1)
	for i = block_moved, 3, -1 do 
		if i % 5 == 0 then
			turtle.placeDown()
		end

		turtle.dig()
		SuckAround()
		turtle.forward()
	end

	turtle.down()

	for i = 3, 16, 1 do
		turtle.select(i)
		turtle.drop()
	end 

	turtle.turnRight()
	turtle.turnRight()
	block_moved = 2
end


function FillFuel()
	local dataItem, _ = turtle.getItemDetail(2)
	local fuelCount = dataItem["count"]
	
	turtle.select(2)

	if fuelCount - 1 > 0 then
		turtle.refuel(fuelCount-1)
	end
end

while true do
	--FillFuel()
	KeepForward()

	local has_block, data = turtle.inspect()

	if data["name"] == "minecraft:oak_log" then
		ChopTree()
	else
		os.sleep(60)
		EndJourney()
		-- os.sleep(1820)
		FillFuel()
	end
end