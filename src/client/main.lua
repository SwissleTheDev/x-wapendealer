-- // [ VARIABLES ] \\ --
local allowed = false
local playerLoaded = false
local resource = GetCurrentGameName()
lib.locale()

if Swl.Framework == 'ESX' then
    ESX = exports[Swl.FrameworkResource]:getSharedObject()
    PlayerData = ESX.PlayerData
elseif Swl.Framework == 'QB' then
    QBCore = exports[Swl.FrameworkResource]:GetCoreObject()
else
    print(resource .. locale('error_framework'))
end

-- // [ FUNCTIONS ] \\ --
local function checkJob(job)
    return not Swl.BlacklistedjobTable[job]
end

local function openMenu()
    local weaponPurchase = {}
    local ammoPurchase = {}

    for k, v in pairs(Swl.ItemsTable['weapons']) do
        table.insert(weaponPurchase, {
            title = v.Label,
            description = locale('description', v.Label, v.Price),
            icon = 'fa-solid fa-gun',
            serverEvent = 'swl-wapendealer:server:buy',
            args = { weapon = k, count = v.Count }
        })
    end

    for k, v in pairs(Swl.ItemsTable['ammo']) do
        table.insert(ammoPurchase, {
            title = v.Count .. ' | ' .. v.Label,
            description = locale('description', v.Label, v.Price),
            icon = 'fa-solid fa-gun',
            serverEvent = 'swl-wapendealer:server:buy',
            args = { weapon = k, count = v.Count }
        })
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
                    options = weaponPurchase
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
                    id = 'AmmoMenu',
                    title = locale('munition_buy'),
                    menu = 'mainMenu',
                    options = ammoPurchase
                })
                lib.showContext('AmmoMenu')
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
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        playerLoaded = true
        allowed = checkJob(PlayerData.job.name)
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
        playerLoaded = true
        allowed = checkJob(PlayerData.job.name)
    end)
elseif Swl.Framework == 'QB' then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        local player = QBCore.Functions.GetPlayerData()
        PlayerJob = player.job
        allowed = checkJob(PlayerJob.name)
    end)
else
    print(resource .. locale('error_framework'))
end

local function createBlip()
    if Swl.blip.enable and allowed then
        local blip = AddBlipForCoord(Swl.Location)
        SetBlipAsShortRange(blip, true)
        SetBlipSprite(blip, Swl.blip.sprite)
        SetBlipScale(blip, Swl.blip.size)
        SetBlipColour(blip, Swl.blip.colour)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Swl.blip.name)
        EndTextCommandSetBlipName(blip)
    end
end

-- // [ THREADS ] \\ --
CreateThread(function()
    while not playerLoaded do Wait(0) end

    Swl = lib.callback.await('swl-wapendealer:server:get:config')
    while not Swl do Wait(0) end
    createBlip()
end)

if Swl.Npc then
    RequestModel(GetHashKey("a_m_y_business_03"))
    while not HasModelLoaded(GetHashKey("a_m_y_business_03")) do
        Wait(1)
    end

    local ped = CreatePed(4, 0xA1435105, Swl.Location.x, Swl.Location.y, Swl.Location.z, Swl.Heading, false, true)
    SetEntityHeading(ped, Swl.Heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if Swl.Interaction == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'Wapendealer',
                icon = 'fa-solid fa-money-bills',
                label = locale('target'),
                onSelect = function()
                    openMenu()
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
        DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 70, 130,
            180, 222, false, false, 0, true, false, false, false)
    end
end

-- // [[ CFX ]] --
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if ped then
        DeletePed(ped)
    end
end)
