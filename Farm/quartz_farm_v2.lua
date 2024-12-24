local X_LIMIT = 15
local Y_LIMIT = 1
local Z_LIMIT = 20

local INSPECT_DIRECTION_MAP = {
    ['up'] = turtle.inspectUp,
    ['down'] = turtle.inspectDown,
    ['front'] = turtle.inspect
}

local DROP_DIRECTION_MAP = {
    ['up'] = turtle.dropUp,
    ['down'] = turtle.dropDown,
    ['front'] = turtle.drop
}
local UNLOAD_CHEST_DIRECTION = 'down'
local unloadTurtle = DROP_DIRECTION_MAP['UNLOAD_CHEST_DIRECTION']

local FUEL_PER_COAL = 80
local FUEL_LIMIT = 5120

local EXCLUDED_BLOCKS = {"ae2:flawed_budding_quartz", "ae2:chipped_budding_quartz", "ae2:damaged_budding_quartz", "ae2:growth_accelerator"}
local EXCLUDED_UNLOAD_ITEMS = {"minecraft:coal"}

local BLOCK_TO_REPLACE = {
    ["ae2:quartz_block"] = "ae2:flawed_budding_quartz"
}

local facing = 0 -- Stores the facing position of the turtle. Goes from 0 to 3, clockwise.

local FACING_MOVE_CHANGE = {
    {0, 0, 1},
    {1, 0, 0},
    {0, 0, -1},
    {-1, 0, 0}
}

-- Stores the current position of the turtle (x, y, z)
local turtlePosition = {0, 0, -1}

local function locateResource(resourceName)
    -- Get the resource location within the turtle inventory. Return the resource location
    local item = nil
    local itemLocation = 0

    for slot = 1, 16, 1 do
        item = turtle.getItemDetail(slot)

        if item['name'] == resourceName then
            itemLocation = slot
            break
        end
    end

    return itemLocation
end

local function refuelTurtle()
    -- Refuel the computer, locating coal within the computer inventory and refueling to 5120 fuel level.
    local slot = locateResource('minecraft:coal')
    
    if slot == 0 then
        print('Warning: No fuel found.')
        return
    end
    
    local remainingFuel = turtle.getFuelLevel()
    local missingFuel = FUEL_LIMIT - remainingFuel

    if missingFuel > 0 then
        turtle.select(slot)
        turtle.refuel(missingFuel // FUEL_PER_COAL) 
    end
end

local function replenishRoutine()
    -- Replenish the turtle of fuel and flawed quartz blocks.
    local flawedQuartzSlot = locateResource('ae2:flawed_budding_quartz')
    local coalSlot = locateResource('minecraft:coal')

    -- UNIMPLEMENTED
end

local function unloadRoutine()
    -- Unload the turtle inventory into the inventory to the direction defined, excluding the EXCLUDED_UNLOAD_ITEMS
    
    for slot = 1, 16, 1 do
        local skip = false
        local item = turtle.getItemDetail(slot)

        if item then
            for k, v in pairs(EXCLUDED_UNLOAD_ITEMS) do
                if item['name'] == v then
                    skip = true
                    break
                end
            end

            if not skip then
                turtle.select(slot)
                unloadTurtle()
            end
        end
    end
end

local function moveForward()
    -- Move turtle forward and reflect it into the stored turtle position
    if turtle.forward() then
        for k, v in pairs(turtlePosition) do
            turtlePosition[k] = turtlePosition[k] + FACING_MOVE_CHANGE[facing][k]
        end
    end
end

local function isExcludedBlock(direction)
    -- A function that check if the block on the specified direction of the turtle is in the exclude list
    local inspectFunction = INSPECT_DIRECTION_MAP[direction]
    local has_block, data = inspectFunction()

    if not has_block then
       return true
    end

    for k, v in pairs(EXCLUDED_BLOCKS) do
        if data['name'] == v then
            return true
        end
    end

    return false
end

local function isReplaceableBlock(direction)
    -- A function that check if the block on the specified direction of the turtle is in the exclude list
    local inspectFunction = INSPECT_DIRECTION_MAP[direction]
    local has_block, data = inspectFunction()

    if not has_block then
       return false
    end

    for k, v in pairs(BLOCK_TO_REPLACE) do
        if data['name'] == k then
            return data
        end
    end

    return false
end

local function replaceBlock(blockName)
    -- Replace the block of the 
    local replacementBlock = BLOCK_TO_REPLACE[blockName]
    local replacementBlockSlot = locateResource(replacementBlock)

    if replacementBlockSlot == 0 then
        return
    end

    turtle.select(replacementBlockSlot)
    turtle.digDown()
    turtle.placeDown()
end

local function turnLeft()
    if turtle.turnLeft() then
        facing = (facing - 1) % 4
    end
end

local function turnRight()
    if turtle.turnRight() then
        facing = (facing + 1) % 4
    end
end

local function turnAround()
    turnLeft()
    turnLeft()
end


local function stepRoutine(stepType)
    -- A function that execute on the step of the turtle
    if not isExcludedBlock('down') then
        local blockToReplace = isReplaceableBlock('down')
        
        if blockToReplace and stepType == 'backward' then
            replaceBlock(blockToReplace['name'])
        elseif not blockToReplace then
            turtle.digDown()
        end
    end

    if stepType == 'forward' then
        if facing == 0 then
            turtle.turnRight()
            turtle.dig()
            turtle.forward()
            turtle.turnRight()
        elseif facing == 2 then
            turtle.turnLeft()
            turtle.dig()
            turtle.forward()
            turtle.turnLeft()
        end
        
    elseif stepType == 'backward'  then
        if facing == 0 then
            turtle.turnLeft()
            turtle.dig()
            turtle.forward()
            turtle.turnLeft()
        elseif facing == 2 then
            turtle.turnRight()
            turtle.dig()
            turtle.forward()
            turtle.turnRight()
        end
    end
end

local function moveAlongZLimit(stepType)
    -- Mueve la tortuga en la dirección especificada a lo largo del eje Z.
    local directionMap = {
        [0] = 'forward',
        [1] = '',
        [2] = 'backward',
        [3] = ''
    }

    local direction = directionMap[facing]
    
    if direction == "forward" then
        while turtlePosition[2] < Z_LIMIT do
            turtle.dig()
            moveForward()
            stepRoutine(stepType)
        end
    elseif direction == "backward" then
        while turtlePosition[2] > 0 do
            turtle.dig()
            moveForward()
            stepRoutine(stepType)
        end
    end
end

local function tourRoutine()
    -- Mueve la tortuga por el área, llamando a una función callback en cada paso.
    while turtlePosition[0] < X_LIMIT do
        if facing == 0 then
            moveAlongZLimit('forward')
        elseif facing == 2 then
            moveAlongZLimit('forward')
        else
            break
        end
    end
end

local function returnRoutine()
    -- Retorna la tortuga a la posición inicial.
    while turtlePosition[0] > -1 do
        if facing == 0 then
            moveAlongZLimit('backward')
        elseif facing == 2 then
            moveAlongZLimit('backward')
        else
            break
        end
    end
end

local function main()
    -- The main routine function
    while true do
        refuelTurtle()
        turtle.up()
        tourRoutine()
        turnAround()
        returnRoutine()
        turnAround()
        turtle.down()
        unloadRoutine()
        os.sleep(30)
    end
end
main()