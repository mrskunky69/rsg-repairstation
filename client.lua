local RSGCore = exports['rsg-core']:GetCoreObject()

local fixing = false
local position = 0

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 0, 0, 215)
    SetTextDropshadow(1, 1, 1, 1, 255)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str, _x, _y)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)

        for k, v in pairs(Config.Stations) do
            if not fixing then
                local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
                if dist < 100 then
                    DrawMarker(36, v.x, v.y, v.z + 1.1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 5.0, 1.0, 255, 0, 0, 100, true, true, 2, true, false, false, false)
                    DrawMarker(0, v.x, v.y, v.z - 0.4, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 255, 0, 100, false, false, 2, false, false, false, false)

                    if dist < 2.5 then
                        position = k
                        DrawText3D(v.x, v.y, v.z + 1.0, ' PRESS E TO REPAIR AND CLEAN ')
                        
                        if IsControlJustPressed(0, 0xCEFD9220) then
                            local vehicle = GetVehiclePedIsIn(playerPed, false)
                            if vehicle and vehicle ~= 0 then
                                TriggerEvent('carfixstation:fixCar', vehicle, true)
                                TriggerServerEvent('rsg-pay', 'repair')
                            else
                                RSGCore.Functions.Notify("You need to be in the vehicle to repair it.", "error")
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('carfixstation:fixCar')
AddEventHandler('carfixstation:fixCar', function(vehicle, repair)
    local playerPed = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)

    if currentVehicle == vehicle then
        fixing = true

        Citizen.Wait(Config.RepairTime)
        fixing = false

        DoScreenFadeOut(500)
        Citizen.Wait(1500)

        if repair then
            SetVehicleFixed(vehicle)
        end

        SetVehicleDirtLevel(vehicle, 0.0)
        DoScreenFadeIn(1800)

        local action = repair and "REPAIRED" or "WASHED"
        TriggerEvent('rNotify:NotifyLeft', "WAGON!", action, "generic_textures", "tick", 4000)

        if repair then
            SetVehicleDoorsLocked(vehicle, 1) -- Lock the vehicle
            TriggerEvent('rNotify:NotifyLeft', "WAGON!", "VEHICLE UNLOCKED", "generic_textures", "tick", 4000)
        end
    else
        RSGCore.Functions.Notify("You need to be in the vehicle to repair it.", "error")
    end
end)

RegisterNetEvent('rsg-pay-notify')
AddEventHandler('rsg-pay-notify', function(amount)
    TriggerEvent('rNotify:NotifyLeft', "WAGON!", 'You paid $' .. amount .. ' for the service.', "generic_textures", "tick", 4000)
end)

local blips = {
    { name = 'WAGON REPAIRS', sprite = 1869246576, x = -271.69, y = 687.57, z = 113.41 },
    -- Add more blip locations if needed
}

Citizen.CreateThread(function()
    for _, info in pairs(blips) do
        local blip = N_0x554d9d53f696d002(1664425300, info.x, info.y, info.z)
        SetBlipSprite(blip, info.sprite, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, info.name)
    end
end)
