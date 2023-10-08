Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) and IsControlPressed(0, 51) and IsVehicleOnAllWheels(GetVehiclePedIsIn(GetPlayerPed(-1))) then -- Hold E to pushback :)
            ApplyForceToEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 0.0, -3.5, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, true, false, true)
            Citizen.Wait(500)
        end
    end
end)