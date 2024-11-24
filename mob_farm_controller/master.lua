local modem = peripheral.find("modem") or error("No modem attached", 0)
local redstone = require('redstone')
local os = require('os')

while true do

    os.pullEvent("redstone")
    local current_status = redstone.getAnalogInput('top')
    modem.transmit(1, 0, current_status)
    
    print("Redstone status changed to: "..tostring(current_status))
    
end