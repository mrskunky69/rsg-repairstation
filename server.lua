local RSGCore = exports['rsg-core']:GetCoreObject()


RegisterNetEvent('rsg-pay')
AddEventHandler('rsg-pay', function(action)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local amount = math.random(Config.MinCash, Config.MaxCash)
    
    if Player.Functions.RemoveMoney('cash', amount) then
        TriggerClientEvent('rsg-pay-notify', src, amount)

    else
        TriggerClientEvent('RSGCore:Notify', src, 'Not enough cash!', 'error')
        
    end
end)



