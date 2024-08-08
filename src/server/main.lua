-- // [ VARIABLES ] \\ --
Location = nil
ConfigSend = false
lib.locale()
if Swl.Framework == 'ESX' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Swl.Framework == 'QB' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('' .. GetCurrentGameName() .. '' .. locale('error_framework'))
end


-- // [ CALLBACKS ] \\ --
lib.callback.register('swl-wapendealer:server:get:config', function()
    if not ConfigSend then
        return Swl
    else
        return DropPlayer(source,  locale('dropmessage', "swl-wapendealer:server:get:config"))
    end
end)

-- // [ EVENTS ] \\ --
RegisterServerEvent('swl-wapendealer:server:buy', function(args)
    Player = nil
    if Swl.Framework == 'ESX' then
        Player = ESX.GetPlayerFromId(source)
         Balance = Player.getAccount(Swl.MoneyType).money
    elseif Swl.Framework == 'QB' then
        Player = QBCore.Functions.GetPlayer(source)
         Balance = exports['qb-banking']:GetAccountBalance(Swl.MoneyType)
    else
        print('' .. GetCurrentGameName() .. '' .. locale('error_framework'))
    end
    local Weapon = args.weapon
    local count = args.count
    local price = args.price

    if not Player then
        return DropPlayer(source, locale('dropmessage', "swl-wapendealer:server:buy"))
    end
    if not Balance then
        return DropPlayer(source, locale('dropmessage', "swl-wapendealer:server:buy"))
    end
    if not Weapon then
        return DropPlayer(source, locale('dropmessage', "swl-wapendealer:server:buy"))
    end
    if not count then
        return DropPlayer(source, locale('dropmessage', "swl-wapendealer:server:buy"))
    end
    if not price then
        return DropPlayer(source, locale('dropmessage', "swl-wapendealer:server:buy"))
    end

    local dist = #(GetEntityCoords(GetPlayerPed(Player.source)) - Swl.Location)
    if dist > 20 then
        return DropPlayer(source, locale('dropmessage', "swl-wapendealer:server:buy"))
    end

    if Balance >= tonumber(price) or Balance == tonumber(price) then
        if Swl.Framework == 'ESX' then
            Player.removeAccountMoney(Swl.MoneyType, price)
            exports.ox_inventory:AddItem(source, Weapon, count)
        elseif Swl.Framework == 'QB' then
            exports['qb-inventory']:RemoveItem(source, Weapon, count, 1, false)
            exports['qb-banking']:AddMoney(Swl.MoneyType, price, locale('qb-banking_buy_decs', Weapon, count))
        else
            print('' .. GetCurrentGameName() .. '' .. locale('error_framework'))
        end
        if Swl.Notify == 'OX' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = locale('title'),
                description = locale('item_bought', Weapon, price),
                type = 'success'
            })
        elseif Swl.Notify == 'ESX' then
            Player.showNotification('success', locale('item_bought', Weapon, price), 5000)
        elseif Swl.Notify == 'QB' then
            TriggerClientEvent('QBCore:Notify', source, locale('item_bought', Weapon, price), 'success', 5000)
        else
            print('' .. GetCurrentGameName() .. '' .. locale('error_framework'))
        end
    else
        if Swl.Notify == 'OX' then
            return TriggerClientEvent('ox_lib:notify', source, {
                title = locale('title'),
                description = locale('not_enough_money'),
                type = 'error'
            })
        elseif Swl.Notify == 'ESX' then
           return Player.showNotification('error', locale('not_enough_money'), 5000)
        elseif Swl.Notify == 'QB' then
           return TriggerClientEvent('QBCore:Notify', source, locale('not_enough_money'), 'error', 5000)
        else
           return print('' .. GetCurrentGameName() .. '' .. locale('error_framework'))
        end
    end
end)
