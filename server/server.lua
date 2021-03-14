ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('lentokone:ammo:getClips', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getInventoryItem('clip').count)
end)

ESX.RegisterServerCallback('lentokone:ammo:RemoveClips', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('clip', 1)
    cb(true)
end)