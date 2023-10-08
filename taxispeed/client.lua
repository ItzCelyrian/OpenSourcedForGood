local taxispeed = 5
local isSpeedLimiterEnabled = false

RegisterCommand("settaximaxspeed", function(source, args, rawCommand)
    local speed = tonumber(args[1])
    if speed then
        taxispeed = speed
        TriggerEvent("chat:addMessage", { color = {255,0,0}, multiline = true, args = {"System", "Max Taxi Speed set to: " .. taxispeed}})
    else
        TriggerEvent("chat:addMessage", { color = {255,0,0}, multiline = true, args = {"System", "Invalid speed value!"}})
    end
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if taxispeed < GetEntitySpeed(vehicle) and isSpeedLimiterEnabled then
            SetVehicleForwardSpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false), taxispeed)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 182) then  -- "L" key
            isSpeedLimiterEnabled = not isSpeedLimiterEnabled
            
            local statusMessage = isSpeedLimiterEnabled and "Speed Limiter: ON" or "Speed Limiter: OFF"
            TriggerEvent("chat:addMessage", { color = {255,0,0}, multiline = true, args = {"System", statusMessage}})
        end
    end
end)