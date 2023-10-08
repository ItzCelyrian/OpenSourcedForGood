local config = {
  command = "tp",
  cooldowntime = 60000,
  jailcoords = {use = false, x = 0, y = 0, z = 0, radius = 70},
  menuTitle = "~b~Teleportation menu",
  menuSubtitle = "",
  notificationMsg = {
      cooldown = "~r~You need to wait before teleporting again.",
      inJail = "~r~You cannot teleport while in jail!",
      inVehicle = "~r~You cannot teleport while in a vehicle"
  }
}

local menus = {
  ['Category #1'] = {
      {name = 'Place #1', x = 1837.02, y = 3699.81, z = 33.82},
      {name = 'Place #2', x = -450.93, y = 6000.64, z = 32.32},
      {name = 'Place #3', x = 425.56, y = -980.25, z = 30.70}
  },
  ['Example, Civilian Locations'] = {
      {name = 'Legion Square', x = 160.43, y = -987.2, z = 30.09},
      {name = 'Sandy Shores 24/7', x = 1971.98, y = 3740.34, z = 32.32},
      {name = 'Paleto Bay SkyLift', x = -765.34, y = 5551.45, z = 33.70}
  }
}

local cooldown = false

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("", config.menuTitle, 1430, 0)
_menuPool:Add(mainMenu)

local function tp(menu)
  for Name, Category in pairs(menus) do
      local category = _menuPool:AddSubMenu(menu, Name)
      for _, coords in pairs(Category) do
          local tps = NativeUI.CreateItem(coords.name, '')
          category:AddItem(tps)

          tps.Activated = function(ParentMenu, SelectedItem)
              local ped = GetPlayerPed(-1)
              local pedCoords = GetEntityCoords(ped)
              if IsPedInAnyVehicle(ped) == false and cooldown == false then
                  if config.jailcoords.use and GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, config.jailcoords.x, config.jailcoords.y, config.jailcoords.z) > 70 or not config.jailcoords.use then
                      SetEntityCoords(ped, coords.x, coords.y, coords.z)
                      cooldown = true
                  else
                      ShowNotification(config.notificationMsg.inJail)
                  end
              elseif IsPedInAnyVehicle(ped) then
                  ShowNotification(config.notificationMsg.inVehicle)
              else
                  ShowNotification(config.notificationMsg.cooldown)
              end
          end
      end
  end
end

tp(mainMenu)
_menuPool:RefreshIndex()
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)
_menuPool:ControlDisablingEnabled(false)

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      _menuPool:ProcessMenus()
      if cooldown then
          Citizen.Wait(config.cooldowntime)
          cooldown = false
      end
  end
end)

RegisterCommand(config.command, function()
  _menuPool:ProcessMenus()
  Citizen.Wait(1)
  mainMenu:Visible(not mainMenu:Visible())
end)

local function ShowNotification(text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  DrawNotification(false, false)
end
