-- // [ VARIABLES ] \\ --
Allowed = false
PlayerLoaded = false
if Swl.Framework == 'ESX' then
    local PlayerData = {}
    ESX = exports["" .. Swl.FrameworkResource .. ""]:getSharedObject()
elseif Swl.Framework == 'QB' then
    QBCore = exports["" .. Swl.FrameworkResource .. ""]:GetCoreObject()
else
    print('' .. GetCurrentGameName() .. '' .. 'Please enter a valid Framework type ESX or QB')
end

-- // [ FUNCTIONS ] \\ --
local function CheckJob(job)
    if not Swl.BlacklistedjobTable[job] then
        print("AUTH")
        return true
    else
        return false
    end
end

local function WapenMenu(elements)
    lib.registerContext({
        id = 'WeaponMenu',
        title = 'WapenDealer',
        menu = 'mainMenu',
        options = elements
    })
    lib.showContext('WeaponMenu')
end

local function AmmoMenu(elements)
    lib.registerContext({
        id = 'AmmmoMenu',
        title = 'Munutie inkoop',
        menu = 'mainMenu',
        options = elements
    })
    lib.showContext('AmmmoMenu')
end


local function openMenu()
    local WapenInkoop = {}
    local MunutieInkoop = {}
    for k, v in pairs(Swl.ItemsTable['weapons']) do
        WapenInkoop[#WapenInkoop+1] = {
            title = v.Label,
            description = 'Klik hier om aan een ' .. v.Label .. ' te kopen voor €' .. v.Price .. '',
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
            description = 'Klik hier om aan een ' .. v.Label .. ' te kopen voor €' .. v.Price .. '',
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
            title = 'Wapen inkoop',
            description = 'je kan hier wapen kopen?',
            icon = 'fa-solid fa-gun',
            OnSelect = function ()
                WapenMenu(WapenInkoop)
            end
        },
        {
            title = 'Munutie inkoop',
            description = 'Zou je hier kogels kunnnen kopen?',
            icon = 'fa-solid fa-gun',
            OnSelect = function ()
                AmmoMenu(MunutieInkoop)
            end
        }
    }

    lib.registerContext({
        id = 'mainMenu',
        title = 'Wapendealer ofz?',
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
    print('' .. GetCurrentGameName() .. '' .. 'Please enter a valid Framework type ESX or QB')
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
    lib.showTextUI('[E] - WapenDealer')
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