while true do
    os.pullEvent("turtle_inventory")
    
    local doOtherPass = true
    while doOtherPass do
        doOtherPass = false
        for slot = 1, 16, 1 do
            turtle.select(slot)

            local item = turtle.getItemDetail()
            
            if item then
                turtle.dropDown()
                doOtherPass = true
            end
        end
    end
end