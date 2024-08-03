-- // [ VARIABLES ] \\ --
Location = nil
ConfigSend = false
if Swl.Framework == 'ESX' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Swl.Framework == 'QB' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('' .. GetCurrentGameName() .. '' .. 'Please enter a valid Framework type ESX or QB')
end


-- // [ CALLBACKS ] \\ --
lib.callback.register('swl-wapendealer:server:get:config', function()
    if not ConfigSend then
        return Swl
    else
        return DropPlayer(source, 'Tried to exploied  "swl-wapendealer:server:get:config"')
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
        print('' .. GetCurrentGameName() .. '' .. 'Please enter a valid Framework type ESX or QB')
    end
    local Weapon = args.weapon
    local count = args.count
    local price = args.price

    if not Player then
        return DropPlayer(source, 'Tried to exploied "swl-wapendealer:server:buy"')
    end
    if not Balance then
        return DropPlayer(source, 'Tried to exploied "swl-wapendealer:server:buy"')
    end
    if not Weapon then
        return DropPlayer(source, 'Tried to exploied "swl-wapendealer:server:buy"')
    end
    if not count then
        return DropPlayer(source, 'Tried to exploied "swl-wapendealer:server:buy"')
    end
    if not price then
        return DropPlayer(source, 'Tried to exploied "swl-wapendealer:server:buy"')
    end

    local dist = #(GetEntityCoords(GetPlayerPed(Player.source)) - Swl.Location)
    if dist > 2 then
        return DropPlayer(source, 'Tried to exploied "swl-wapendealer:server:buy"')
    end

    if Balance >= tonumber(price) or Balance == tonumber(price) then
        if Swl.Framework == 'ESX' then
            Player.removeAccountMoney(Swl.MoneyType, price)
            exports.ox_inventory:AddItem(source, Weapon, count)
        elseif Swl.Framework == 'QB' then
            exports['qb-inventory']:RemoveItem(source, Weapon, count, 1, false)
            exports['qb-banking']:AddMoney(Swl.MoneyType, price, 'je hebt een ' .. Weapon ' ' .. count .. ' keer gekocht')
        else
            print('' .. GetCurrentGameName() .. '' .. 'Please enter a valid Framework type ESX or QB')
        end
        if Swl.Notify == 'OX' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Wapen dealer',
                description = 'Je hebt successvol een ' .. Weapon .. ' gekocht voor ' .. price .. '€',
                type = 'success'
            })
        elseif Swl.Notify == 'ESX' then
            Player.showNotification('success', 'Je hebt successvol een ' .. Weapon .. ' gekocht voor ' .. price .. '€', 5000)
        elseif Swl.Notify == 'QB' then
            TriggerClientEvent('QBCore:Notify', source, 'Je hebt successvol een ' .. Weapon .. ' gekocht voor ' .. price .. '€', 'success', 5000)
        else
            print('' .. GetCurrentGameName() .. '' .. 'Please enter a valid Framework type ESX or QB')
        end
    else
        if Swl.Notify == 'OX' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Wapen dealer',
                description = 'Je hebt niet genoeg geld!',
                type = 'error'
            })
        elseif Swl.Notify == 'ESX' then
            Player.showNotification('error', 'Je hebt niet genoeg geld!', 5000)
        elseif Swl.Notify == 'QB' then
            TriggerClientEvent('QBCore:Notify', source, 'Je hebt niet genoeg geld!', 'error', 5000)
        else
            print('' .. GetCurrentGameName() .. '' .. 'Please enter a valid Framework type ESX or QB')
        end
    end
end)
