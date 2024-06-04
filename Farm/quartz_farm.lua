
local quartz_block = {"ae2:flawed_budding_quartz", "ae2:chipped_budding_quartz", "ae2:damaged_budding_quartz", "ae2:quartz_block"}
local machine = "ae2:growth_accelerator"

local max_x = 10
local max_y = 10

local facing = "up"
local invert = false


local function reset()
    facing = "up"
    invert = false
end


local function makeTurn()
    if not invert then
        if facing == "up" then
            turtle.turnRight()
            turtle.forward()
            turtle.turnRight()
            facing = "down"
        else
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            facing = "up"
        end
    else
        if facing == "up" then
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            facing = "down"
        else
            turtle.turnRight()
            turtle.forward()
            turtle.turnRight()
            facing = "up"
        end
    end
end

local function turnAround()
    turtle.turnRight()
    turtle.turnRight()

    if facing == "up" then
        facing = "down"
    else
        facing = "up"
    end
end
turtle.turnAround = turnAround

local function replenish()
    turtle.turnAround()

    for _ = 1, 2, 1 do
        turtle.suck()
    end

    local fuelSlot = 1

    for i = 1, 16, 1 do
        local name = ""
        
        if turtle.getItemCount(i) > 0 then
            name = turtle.getItemDetail(i)["name"]
        end

        if name == "minecraft:charcoal" then
            fuelSlot = i
            break
        end
    end

    turtle.select(fuelSlot)
    turtle.refuel()
    turtle.turnAround()
end

local function findQuartzBlocks()
    local quartzSlot = 1
    
    for i = 1, 16, 1 do
        local name = ""
        
        if turtle.getItemCount(i) > 0 then
            name = turtle.getItemDetail(i)["name"]
        end

        if name == "ae2:flawed_budding_quartz" then
            quartzSlot = i
            break
        end
    end

    turtle.select(quartzSlot)
end

local function collectQuartz()
    for x = 1, max_x, 1 do
        for y = 1, max_y, 1 do

            local isOccupied, data = turtle.inspectDown()

            if isOccupied then

                local isQuartzBlock = false

                for _, v in pairs(quartz_block) do
                    if v == data["name"] then
                        isQuartzBlock = true
                        break
                    end
                end

                local isMachine = machine == data["name"]

                if not isQuartzBlock and not isMachine then
                    turtle.digDown()
                end
            end

            if turtle.detect() and y < max_y then
                turtle.dig()
            end

            if y < max_y then
                turtle.forward()
            end
        end
        if x < max_x then
            makeTurn()
        end
    end
end

local function replantQuartz()
    turtle.turnAround()
    invert = true

    for x = 1, max_x, 1 do
        for y = 1, max_y, 1 do

            local isOccupied, data = turtle.inspectDown()

            if isOccupied then
                local isMachine = machine == data["name"]

                if not isMachine and data["name"] == "ae2:quartz_block" then
                    turtle.digDown()
                    turtle.placeDown()
                else
                    local isQuartzBlock = false

                    for _, v in pairs(quartz_block) do
                        if v == data["name"] then
                            isQuartzBlock = true
                            break
                        end
                    end

                    if not isQuartzBlock and not isMachine then
                        turtle.digDown()
                    end
                end
            end
            
            if turtle.detect() and y < max_y then
                turtle.dig()
            end

            if y < max_y then
                turtle.forward()
            end
        end
        if x < max_x then
            makeTurn()
        end
    end
end

local function unloadMerchandise()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.drop()
    end

    turtle.turnAround()
end

local function main()
    while true do
        replenish()
        collectQuartz()
        findQuartzBlocks()
        replantQuartz()
        unloadMerchandise()
        reset()
        os.sleep(60)
    end
end

main()