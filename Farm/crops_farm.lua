local config = {}
config["width"] = 0
config["height"] = 0

local seedsDic = {
	["minecraft:potatoes"] = "minecraft:potato",
	["minecraft:carrots"] = "minecraft:carrot",
	["minecraft:wheat"] = "minecraft:wheat_seeds"
}


local file

local orientation = 0 -- clock wise starting with front
local x = 1
local y = 0

function Initialize()
	file, _ = io.open("config", "r")

	if file == nil then
		file, _ = io.open("config", "w")

		io.write("[Granja automatizada]\n")
		
		io.write("Ingrese la altura:")
		io.flush()
		local height = io.read()

		io.write("Ingrese la anchura:")
		io.flush()
		local width = io.read()
		
		config["height"] = tonumber(height)
		config["width"] = tonumber(width)

		file:write(height, "\n")
		file:write(width, "\n")
		
	else
		local height = file:read()
		local width = file:read()

		config["height"] = tonumber(height)
		config["width"] = tonumber(width)
		
	end

	file:close()
end


function NextCrop()

	if orientation == 0 and y == config["height"] then
		TurnRutine()
	elseif orientation == 2 and y == 1 then
		TurnRutine()
	end


	local succeed, _ = turtle.forward()

	if succeed and orientation == 0 then
		y = y + 1
	elseif succeed and orientation == 2 then
		y = y - 1
	end
end

function Harvest()
	
	local hasBlock, infoBlock = turtle.inspectDown()

	if not hasBlock then
		return
	end

	if infoBlock.state.age < 7 then
		return
	end

	turtle.digDown()
	
	local slot = FindSeed(infoBlock.name)
	
	turtle.select(slot)
	turtle.placeDown()
end 

function FindSeed(crop_name)
	local seed = seedsDic[crop_name]

	for i = 1, 16, 1 do
		local item = turtle.getItemDetail(i)
		
		if item ~= nil then
			if item.name == seed then
				return i
			end
		end
	end
end

function TurnRutine()
	if orientation == 0 then
		turtle.turnRight()
		turtle.forward()
		x = x + 1
		turtle.turnRight()
		orientation = 2
	elseif orientation == 2 then
		turtle.turnLeft()
		turtle.forward()
		x = x + 1
		turtle.turnLeft()
		orientation = 0
	end
	Harvest()
end

function FinishFarming()
	if orientation == 0 then
		turtle.turnLeft()
	elseif orientation == 2 then
		turtle.turnRight()
	end

	for i = x, 2, -1 do
		turtle.forward()
	end

	x = 1

	turtle.turnLeft()

	for i = y, 1, -1 do
		turtle.forward()
	end

	y = 0

	turtle.down()

	for i = 1, 16, 1 do
		turtle.select(i)
		turtle.drop()
	end

	turtle.turnRight()
	turtle.turnRight()

	orientation = 0

end




Initialize()
--print(config["height"])
--print(config["width"])

while true do
	local keep_farming = true
	turtle.up() --Una vez

	while keep_farming do
		NextCrop()
		Harvest()

		if orientation == 0 and x == config["width"] and y == config["height"] then
			keep_farming = false
			FinishFarming()
		elseif orientation == 2 and x == config["width"] and y == 1 then
			keep_farming = false
			FinishFarming()
		end

	end

	os.sleep(2100)
end


