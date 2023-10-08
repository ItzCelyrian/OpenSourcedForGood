local cooldown = false
RegisterCommand("squawk", function ()
     if not cooldown then
         local squawkCode = math.random(0, 7777)
         local squawkStr = tostring(squawkCode)
         squawkStr = squawkStr:gsub('8', '7'):gsub('9', '7')
         squawkCode = tonumber(squawkStr)
 
         TriggerEvent('chat:addMessage', {
             color = {50, 235, 220},
             multiline = true,
             args = {'Squawk Code: ', squawkStr}
         })
         
         ShowNotification("~g~Squawk Code Generated!")
         cooldown = true
     else
         ShowNotification("~r~Please wait 5 seconds before using this command again")
     end
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        if cooldown then
            Citizen.Wait(5000)
            cooldown = false
        end
    end
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end
