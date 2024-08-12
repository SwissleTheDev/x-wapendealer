-- // [ VARIABLES ] \\ --
Allowed = false
PlayerLoaded = false
lib.locale()
if Swl.Framework == 'ESX' then
    PlayerData = {}
    PlayerData = ESX.PlayerData
    ESX = exports["" .. Swl.FrameworkResource .. ""]:getSharedObject()
elseif Swl.Framework == 'QB' then
    QBCore = exports["" .. Swl.FrameworkResource .. ""]:GetCoreObject()
else
    print('' .. GetCurrentGameName() .. '' .. locale('error_framework'))
end

-- // [ FUNCTIONS ] \\ --
local function CheckJob(job)
    if not Swl.BlacklistedjobTable[job] then
        return true
    else
        return false
    end
end

local function OpenMenu()
    local WapenInkoop = {}
    local MunutieInkoop = {}
    for k, v in pairs(Swl.ItemsTable['weapons']) do
        WapenInkoop[#WapenInkoop+1] = {
            title = v.Label,
            description = locale('description', v.Label, v.Price ),
            icon = 'fa-solid fa-gun',
            serverEvent = 'swl-wapendealer:server:buy',
            args = {
                weapon = k,
                count = v.Count,
                price = v.Price
            }
        }
    end

    for k, v in pairs(Swl.ItemsTable['ammo']) do
        MunutieInkoop[#MunutieInkoop+1] = {
            title = '' .. v.Count .. ' ' .. '|' .. ' ' .. v.Label .. '',
            description = locale('description', v.Label, v.Price ),
            icon = 'fa-solid fa-gun',
            serverEvent = 'swl-wapendealer:server:buy',
            args = {
                weapon = k,
                count = v.Count,
                price = v.Price
            }
        }
    end


    local elements = {
        {
            title = locale('buy_weapons'),
            description = locale('buy_weapons_desc'),
            icon = 'fa-solid fa-gun',
            onSelect = function()
                lib.registerContext({
                    id = 'WeaponMenu',
                    title = locale('weapondealer'),
                    menu = 'mainMenu',
                    options = WapenInkoop
                })
                lib.showContext('WeaponMenu')
            end
        },
        {
            title = locale('buy_ammo'),
            description = locale('buy_ammo_desc'),
            icon = 'fa-solid fa-gun',
            onSelect = function()
                lib.registerContext({
                    id = 'AmmmoMenu',
                    title = locale('munition_buy'),
                    menu = 'mainMenu',
                    options = MunutieInkoop
                })
                lib.showContext('AmmmoMenu')
            end
        }
    }

    lib.registerContext({
        id = 'mainMenu',
        title = locale('title'),
        options = elements
    })
    lib.showContext('mainMenu')
end


-- // [ Framework ] \\ --
if Swl.Framework == 'ESX' then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xSwissle)
        PlayerData = xSwissle
        PlayerLoaded = true
        if CheckJob(PlayerData.job.name) then
            Allowed = true
        end
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
        PlayerLoaded = true
        if CheckJob(PlayerData.job.name) then
            Allowed = true
        else
            Allowed = false
        end
    end)
elseif Swl.Framework == 'QB' then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        local player = QBCore.Functions.GetPlayerData()
        PlayerJob = player.job

        if CheckJob(PlayerData.job.name) then
            Allowed = true
        else
            Allowed = false
        end
    end)
else
    print('' .. GetCurrentGameName() .. '' .. locale('error_framework'))
end

-- // [ THREADS ] \\ --
CreateThread(function()
    while not PlayerLoaded do Wait(0) end

    lib.callback.await('swl-wapendealer:server:get:config', function(data)
        Swl = data
    end)
    while not Swl do Wait(0) end

    if Swl.blip.enable and Allowed then
        Blip = AddBlipForCoord(Swl.Location)
        SetBlipAsShortRange(Blip, true)
        SetBlipSprite(Blip, Swl.blip.sprite)
        SetBlipScale(Blip, Swl.blip.size)
        SetBlipColour(Blip, Swl.blip.colour)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Swl.blip.name)
        EndTextCommandSetBlipName(Blip)
    end
end)
if Swl.Npc then
    RequestModel(GetHashKey("a_m_y_business_03"))
    while not HasModelLoaded(GetHashKey("a_m_y_business_03")) do
        Wait(1)
    end

     Ped = CreatePed(4, 0xA1435105, Swl.Location.x, Swl.Location.y, Swl.Location.z, Swl.Heading, false, true)

    SetEntityHeading(Ped, Swl.Heading)
    FreezeEntityPosition(Ped, true)
    SetEntityInvincible(Ped, true)
    SetBlockingOfNonTemporaryEvents(Ped, true)

    if Swl.Interaction == 'ox_target' then
        exports.ox_target:addLocalEntity(Ped, {
            {
                name = 'Wapendealer',
                icon = 'fa-solid fa-money-bills',
                label = locale('target'),
                onSelect = function()
                    OpenMenu()
                end
            }
        })
    elseif Swl.Interaction == 'qb-target' then
        
        print("qb-target gets soon supported!!")
    else
        print(locale('error-interaction'))
    end
else

-- // [ Marker ] \\ --
local showing = false
local point = lib.points.new({
    coords = Swl.Location,
    distance = 20,
})

function point:onEnter()
    showing = false
end

function point:onExit()
    showing = false
end

function point:nearby()
    DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 70, 130, 180,
        222, false, false, 0, true, false, false, false)
end

function onEnter(self)
    lib.showTextUI(locale('interaction'))
end

function onExit(self)
    lib.hideTextUI()
end

function inside(self)
    if IsControlJustReleased(0, 38) and Allowed then
        OpenMenu()
    end
end

local sphere = lib.zones.sphere({
    coords = Swl.Location,
    radius = 1,
    debug = false,
    inside = inside,
    onEnter = onEnter,
    onExit = onExit
})
end

-- // [[ CFX ]] -- 

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return end

    if Ped then 
            DeletePed(Ped)
    end
end)

