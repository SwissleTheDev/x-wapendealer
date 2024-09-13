-- // [ VARIABLES ] \\ --
local configSend = false
local resource = GetCurrentGameName()
lib.locale()

local function getFrameworkObject()
    if Swl.Framework == 'ESX' then
        return exports["es_extended"]:getSharedObject()
    elseif Swl.Framework == 'QB' then
        return exports['qb-core']:GetCoreObject()
    else
        print(resource .. locale('error_framework'))
        return nil
    end
end

local function getPlayerBalance(xPlayer)
    if Swl.Framework == 'ESX' then
        return xPlayer.getAccount(Swl.MoneyType).money
    elseif Swl.Framework == 'QB' then
        return exports['qb-banking']:GetAccountBalance(Swl.MoneyType)
    else
        print(resource .. locale('error_framework'))
        return 0
    end
end

local function notifyPlayer(source, message, messageType)
    if Swl.Notify == 'OX' then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('title'),
            description = message,
            type = messageType
        })
    elseif Swl.Notify == 'ESX' then
        Player.showNotification(messageType, message, 5000)
    elseif Swl.Notify == 'QB' then
        TriggerClientEvent('QBCore:Notify', source, message, messageType, 5000)
    else
        print(resource .. locale('error_framework'))
    end
end

local function foundWeapon(weapon)
    for _, v in pairs(Swl.ItemsTable) do
        if v[weapon] then
            return true
        end
    end
    return false
end

-- // [ CALLBACKS ] \\ --
lib.callback.register('swl-wapendealer:server:get:config', function()
    if not configSend then
        return Swl
    end
end)

-- // [ EVENTS ] \\ --
RegisterNetEvent('swl-wapendealer:server:buy')
AddEventHandler('swl-wapendealer:server:buy', function(args)
    local src = source
    local xPlayer = getFrameworkObject()
    if not xPlayer then
        return DropPlayer(src, locale('dropmessage', "swl-wapendealer:server:buy"))
    end

    local balance = getPlayerBalance(xPlayer)
    local weapon = args.weapon
    if not weapon or not foundWeapon(weapon) then
        return DropPlayer(src, locale('dropmessage', "swl-wapendealer:server:buy"))
    end

    local itemData = Swl.ItemsTable['weapons'][weapon] or Swl.ItemsTable['ammo'][weapon]
    if not itemData then
        return DropPlayer(src, locale('dropmessage', "swl-wapendealer:server:buy"))
    end

    local count = itemData.Count
    local price = tonumber(itemData.Price)
    local playerPed = GetPlayerPed(xPlayer.source)
    local playerCoords = GetEntityCoords(playerPed)
    local dist = #(playerCoords - Swl.Location)

    if dist > 10 then
        return DropPlayer(src, locale('dropmessage', "swl-wapendealer:server:buy"))
    end

    if balance >= price then
        if Swl.Framework == 'ESX' then
            xPlayer.removeAccountMoney(Swl.MoneyType, price)
            exports.ox_inventory:AddItem(src, weapon, count)
        elseif Swl.Framework == 'QB' then
            exports['qb-inventory']:RemoveItem(src, weapon, count, 1, false)
            exports['qb-banking']:AddMoney(Swl.MoneyType, price, locale('qb-banking_buy_decs', weapon, count))
        end
        notifyPlayer(src, locale('item_bought', weapon, price), 'success')
    else
        notifyPlayer(src, locale('not_enough_money'), 'error')
    end
end)
