local keybind = 170
local command = "carmenu"
local cooldown = false

_menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("Vehicle Options", "~b~Vehicle options menu", 100, 0)
_menuPool:Add(mainMenu)
mainMenu.SetMenuWidthOffset(100)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if cooldown then
                Citizen.Wait(5000)
                cooldown = false
            end
        end
    end
)

local function getPedVeh()
    local ped = GetPlayerPed(-1)
    return ped, GetVehiclePedIsIn(ped)
end

function seatrs(menu)
    local seats = _menuPool:AddSubMenu(menu, "Vehicle seats", "Change vehicle seats", 100, 0)
    local ped, veh = getPedVeh()
    local max = GetVehicleModelNumberOfSeats(GetEntityModel(veh))

    local items = {
        {"Driver Seat", -1},
        {"Passenger Seat", 0},
        {"Rear left seat", 1},
        {"Rear right seat", 2}
    }

    for i = 1, max do
        local item = NativeUI.CreateItem(items[i][1], "move into the " .. items[i][1])
        seats:AddItem(item)
        seats.OnItemSelect = function(_, selectedItem)
            if selectedItem == item then
                TaskWarpPedIntoVehicle(ped, veh, items[i][2])
            end
        end
    end
end

function doors(menu)
    local doorsMenu = _menuPool:AddSubMenu(menu, "Door options", "Manage the vehicles doors", 100, 0)
    local doorItems = {
        {"Front Left Door", 0},
        {"Front Right Door", 1},
        {"Back Left Door", 2},
        {"Back Right Door", 3},
        {"Trunk", 5},
        {"Hood", 4}
    }

    for _, door in pairs(doorItems) do
        local item = NativeUI.CreateItem(door[1], "Open " .. door[1])
        doorsMenu:AddItem(item)
        doorsMenu.OnItemSelect = function(_, selectedItem)
            if selectedItem == item then
                local ped, veh = getPedVeh()
                local isopen = GetVehicleDoorAngleRatio(veh, door[2])
                if isopen == 0 then
                    SetVehicleDoorOpen(veh, door[2], false, false)
                else
                    SetVehicleDoorShut(veh, door[2], false)
                end
            end
        end
    end
end

function windows(menu)
    local windowsMenu = _menuPool:AddSubMenu(menu, "Window options", "Manage the vehicle's windows", 100, 0)
    local windowItems = {
        {"Front Left Window", 0},
        {"Front Right Window", 1},
        {"Back Left Window", 2},
        {"Back Right Window", 3}
    }

    for _, window in pairs(windowItems) do
        local item = NativeUI.CreateItem(window[1], "Toggle " .. window[1])
        windowsMenu:AddItem(item)
        windowsMenu.OnItemSelect = function(_, selectedItem)
            if selectedItem == item then
                local ped, veh = getPedVeh()
                local isDown = IsVehicleWindowIntact(veh, window[2])
                if isDown then
                    RollDownWindow(veh, window[2])
                else
                    RollUpWindow(veh, window[2])
                end
            end
        end
    end
end

function extras(menu)
    local extrasMenu = _menuPool:AddSubMenu(menu, "Extras options", "Toggle vehicle extras", 100, 0)
    local numExtras = 3 -- Assume each vehicle has 3 extras for this example

    for i = 1, numExtras do
        local item = NativeUI.CreateItem("Extra " .. i, "Toggle extra " .. i)
        extrasMenu:AddItem(item)
        extrasMenu.OnItemSelect = function(_, selectedItem)
            if selectedItem == item then
                local _, veh = getPedVeh()
                local isOn = IsVehicleExtraTurnedOn(veh, i)
                if isOn then
                    SetVehicleExtra(veh, i, true)
                else
                    SetVehicleExtra(veh, i, false)
                end
            end
        end
    end
end

function licenses(menu)
    local license = _menuPool:AddSubMenu(menu, "Manage License Plate", "manage your vehicles license plate", 100, 0)
    local change = NativeUI.CreateItem("Random license plate", "Stole a vehicle? Set a different license.")
    local set = NativeUI.CreateItem("Customize your license plate", "Set a custom license plate of your choice.")
    local letters = {"K", "L", "Q", "R", "Z", "N"}

    license:AddItem(change)
    license:AddItem(set)

    local function getRandomPlate()
        local a, b, c, d, e =
            math.random(1, 9),
            math.random(1, 9),
            math.random(1, 9),
            math.random(1, 9),
            math.random(1, 9)
        local t1, t2, t3 = letters[math.random(1, 6)], letters[math.random(1, 6)], letters[math.random(1, 6)]
        return a .. b .. t1 .. c .. t2 .. d .. e .. t3
    end

    license.OnItemSelect = function(sender, item, index)
        local ped = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(ped, false)

        if item == change then
            if not cooldown then
                local plate = getRandomPlate()
                SetVehicleNumberPlateText(veh, plate)
                ShowNotification("~g~License plate changed to " .. plate)
                cooldown = true
            else
                ShowNotification("~r~Please wait 5 seconds before using this command again")
            end
        elseif item == set then
            DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 30)
            while (UpdateOnscreenKeyboard() == 0) do
                DisableAllControlActions(0)
                Wait(0)
            end
            if GetOnscreenKeyboardResult() then
                local plate = GetOnscreenKeyboardResult()
                set:RightLabel(plate)
                SetVehicleNumberPlateText(veh, plate)
                ShowNotification("~g~License plate changed to " .. plate)
            end
        end
    end
end

doors(mainMenu)
seatrs(mainMenu)
windows(mainMenu)
extras(mainMenu)
licenses(mainMenu)
_menuPool:RefreshIndex()

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            _menuPool:ProcessMenus()
            if IsControlJustPressed(1, keybind) then
                if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                    mainMenu:Clear()
                    mainMenu:Visible(not mainMenu:Visible())
                else
                    ShowNotification("~r~You need to be in a vehicle to use this menu")
                end
            end
        end
    end
)

RegisterCommand(
    command,
    function()
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            mainMenu:Visible(not mainMenu:Visible())
        else
            ShowNotification("~r~You need to be in a vehicle to use this menu")
        end
    end,
    false
)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end  