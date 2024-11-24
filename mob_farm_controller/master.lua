local modem = peripheral.find("modem") or error("No modem attached", 0)

while true do

    os.pullEvent("redstone")
    local current_status = redstone.getInput('top')
    modem.transmit(1, 0, current_status)
    
    print("Redstone status changed to: "..tostring(current_status))
    
end