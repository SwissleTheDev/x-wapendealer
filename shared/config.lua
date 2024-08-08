Swl = {}

Swl.Framework = 'ESX' -- ESX or QB
Swl.FrameworkResource = 'es_extended' -- for  ESX = 'es_extended' or custom resource name QB = 'qb-core' or custom resource name
Swl.Notify = 'OX' -- you can choose bewteen OX or ESX

Swl.BlacklistedjobTable = {
    police = true,
    kmar = true,
    mechanic = true,
    ambulance = true
}

Swl.blip = {
    enable = true,
    sprite = 774,
    size = 0.8,
    name = 'Wapen Dealer',
    colour = 26
}

Swl.MoneyType = 'black_money' -- money / black_money / bank

Swl.Location = vec3(-718.1540, -1448.5582, 4.0026)
Swl.Heading = 339.8603

Swl.Npc = true
Swl.Interaction  = 'ox_target' -- ox_target, qb-target


Swl.ItemsTable = {
    ['weapons'] = {
        ['weapon_pistol'] = {
            Count = 1,
            Label = 'Glock 17',
            Price = 100000
        },
        ['weapon_rifle'] = {
            Count = 100,
            Label = 'AK-47',
            Price = 250000
        }
    },
    ['ammo'] = {
        ['ammo-9'] = {
            Count = 100,
            Label = '9mm',
            Price = 10000
        },
        ['ammo-rifle'] = {
            Count = 100,
            Label = '5.56X45',
            Price = 50000
        },
        ['ammo-shotgun'] = {
            Count = 100,
            Label = '12 Gauge',
            Price = 4000
        }
    }
}