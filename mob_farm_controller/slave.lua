local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(1) -- Open 43 so we can receive replies

local event, side, channel, replyChannel, message, distance
while true do
    event, side, channel, replyChannel, message, distance =  os.pullEvent("modem_message")
    redstone.setOutput('back', message)
    print("Received restone status changed to: " .. tostring(message))
end

