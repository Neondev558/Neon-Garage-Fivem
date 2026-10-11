Config = {}


Config.Mysql = 'oxmysql' --   mysql-async -- oxmysql  -- pls fxmanifest and open requirement
Config.Framework = "newqb" -- newqb, oldqb, esx
Config.Account = 'money' --- bank , money



----------------------------
Config.SellCar = true --- ture and false
Config.TransferCar = true -- ture and false

Config.Price = 100
Config.impoundPrice = 500
Config.GarageCoords = {
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(213.59,  -809.34,  31.01 ),  npcHeading =0.0,     parking = vector3(215.68,  -792.62, 29.83 ), parkout= vector3(222.45,   -801.44,  30.25 ), vehicleHeading=246.89 , garageName = 'A GARAGE'}, -- Hastane altı
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(-899.275,-153.0,   41.88 ),  npcHeading =121.86,  parking = vector3(-906.28, -154.96, 41.06 ), parkout= vector3(-911.93,  -164.65,  41.45 ), vehicleHeading=27.11  , garageName = 'B GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(275.182, -345.534, 45.173),  npcHeading =0.0,     parking = vector3(272.68,  -337.14, 44.0  ), parkout= vector3(285.34,   -335.65,  44.49 ), vehicleHeading=250.6  , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(-833.255,-2351.34, 14.57 ),  npcHeading =284.43,  parking = vector3(-826.95, -2351.44,13.6  ), parkout= vector3(-820.66,  -2361.0,  14.15 ), vehicleHeading=329.02 , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(721.95,  -2016.379,29.43 ),  npcHeading =264.04,  parking = vector3(727.5,   -2017.41,28.25 ), parkout= vector3(728.45,   -2031.35, 28.86 ), vehicleHeading=355.12 , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(-2162.82,-377.15,  13.28 ),  npcHeading =165.99,  parking = vector3(-2165.56,-383.22, 12.19 ), parkout= vector3(-2169.86, -373.34,  12.67 ), vehicleHeading=169.68 , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(-423.85, 1206.11,  325.76),  npcHeading =260.8,   parking = vector3(-418.73, 1206.37, 324.80), parkout= vector3(-422.07,  1198.1,   352.22), vehicleHeading=229.16 , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(112.23,  6619.66,  31.82 ),  npcHeading =237.14,  parking = vector3(116.99,  6613.56, 31.0  ), parkout= vector3(111.88,   6602.95,  31.51 ), vehicleHeading=272.66 , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(2768.34, 3462.92,  55.63 ),  npcHeading =241.17,  parking = vector3(2773.22, 3461.03, 54.60 ), parkout= vector3(2767.28,  3457.05,  55.28 ), vehicleHeading=241.9  , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(1951.79, 3750.95,  32.16 ),  npcHeading =118.06,  parking = vector3(1948.04, 3747.62, 31.22 ), parkout= vector3(1950.16,  3759.21,  31.78 ), vehicleHeading=30.35  , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(1851.43, 2587.75,  45.67 ),  npcHeading =251.45,  parking = vector3(1856.02, 2589.47, 44.80 ), parkout= vector3(1854.8,   2579.11,  45.25 ), vehicleHeading=272.67 , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(916.81,  -15.27,   78.76 ),  npcHeading =146.82,  parking = vector3(913.89,  -19.08,  77.94 ), parkout= vector3(907.01,   -13.41,   78.34 ), vehicleHeading=147.92 , garageName = 'A GARAGE'},
          {garageType = 'normal', npcHash ="s_m_y_barman_01", npc = vector3(99.79,   -1072.98, 29.37 ),  npcHeading =250.0,   parking = vector3(107.32,  -1070.57,28.37 ), parkout= vector3(117.64,   -1082.05, 28.77 ), vehicleHeading=3.1    , garageName = 'A GARAGE'},
          {garageType ='impound', npcHash ="s_m_y_barman_01", npc = vector3(-181.24, -1282.1, 31.2959),  npcHeading =192.07,  parking = vector3(-181.81, -1287.4, 25.271), parkout= vector3(-189.10,  -1290.3,  30.871), vehicleHeading=269.66 , garageName = 'Impound Garage'}, -- Hastane altı

}

Config.BlacklistVehicles = {
    GetHashKey('bati'),

 
}

Config.Notification = function(message, type, isServer, src)
    if isServer then
        if Config.Framework == "esx" then
            TriggerClientEvent("esx:showNotification", src, message)
        else
            TriggerClientEvent('QBCore:Notify', src, message, type, 1500)
        end
    else
        if Config.Framework == "esx" then
            TriggerEvent("esx:showNotification", message)
        else
            TriggerEvent('QBCore:Notify', message, type, tonumber(1500))
        end
    end
end 

Config.Notifications = {
    ['error_transfer'] = {
        message = 'You cant transfer your car to you.',
        type = 'error'
    },
    ['player_transfer'] = {
        message = 'Player not in the game.',
        type = 'error'
    },
    ['player_transfer_error'] = {
        message = 'his is not allowed..',
        type = 'error'
    },
    ['price_error'] = {
        message = 'his is not allowed..',
        type = 'error'
    },
  
     ['carsell'] = {
        message = 'Car sale succesful',
        type = 'success'
    },
    ['parkprice'] = {
        message = 'You have paid $ ',
        type = 'success'
    },
    ['notowner'] = {
        message = 'Car is not yours.',
        type = 'error'
    },
    ['transfer'] = {
        message = 'You have transfered the car',
        type = 'success'
    },
    ['transfer2'] = {
        message = 'The car has been sent to your garage',
        type = 'success'
    },
    ['money'] = {
        message = 'Not enough cash',
        type = 'error'
    },
    ['notvehicle'] = {
        message = 'There is no car in your garage',
        type = 'error'
    },
}
Config.HelpNotfiy = 'Press [E].'
Config.HelpNotfiy1 = 'There is no car in your garage'
---- DİSCORD WEBHOOK --- 
Config.TransferWeebhok = ""
Config.SellWebhook = ""
Config.IconURL = "https://cdn.discordapp.com/attachments/862018783391252500/943983046347063316/Patreon_Logo_3.png"
Config.Logo = "https://cdn.discordapp.com/attachments/862018783391252500/943983046347063316/Patreon_Logo_3.png"
Config.Botname = "Garage Report Log"

-- DrawText Settings 
Config.drawmarkerid = 1
Config.red = 255
Config.green = 10
Config.blue = 20
Config.alpha = 155

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 90)
end



-- don't touch if qb framework
-- don't touch if qb framework
-- don't touch if qb framework
Config.DefaultManufacturer = "UNKOWN"
Config.VehiclesManufacturer = {
    ["blade"] = "Vapid",
    ["buccaneer"] = "Albany",
    ["buccaneer2"] = "Albany",
    ["chino"] = "Vapid",
    ["chino2"] = "Vapid",
    ["coquette3"] = "Invetero",
    ["dominator"] = "Vapid",
    ["dukes"] = "Imponte",
    ["gauntlet"] = "Bravado",
    ["hotknife"] = "Vapid",
    ["faction"] = "Willard",
    ["faction2"] = "Willard",
    ["faction3"] = "Willard",
    ["nightshade"] = "Imponte",
    ["phoenix"] = "Imponte",
    ["picador"] = "Cheval",
    ["sabregt"] = "Declasse",
    ["sabregt2"] = "Declasse",
    ["slamvan3"] = "Vapid",
    ["tampa"] = "Declasse",
    ["virgo"] = "Albany",
    ["vigero"] = "Declasse",
    ["voodoo"] = "Declasse",
    ["330661258"] = "Dinka",
    ["brioso"] = "Grotti",
    ["issi2"] = "Weeny",
    ["blista"] = "Dinka",
    ["panto"] = "Benefactor",
    ["prairie"] = "Bollokan",
    ["bison"] = "Declasse",
    ["bobcatxl"] = "Vapid",
    ["burrito3"] = "Declasse",
    ["gburrito2"] = "Declasse",
    ["gburrito"] = "Declasse",
    ["camper"] = "Brute",
    ["journey"] = "Zirconium",
    ["minivan"] = "Vapid",
    ["moonbeam"] = "Declasse",
    ["moonbeam2"] = "Declasse",
    ["paradise"] = "Bravado",
    ["rumpo"] = "Bravado",
    ["rumpo3"] = "Bravado",
    ["surfer"] = "BF",
    ["youga"] = "Bravado",
    ["youga2"] = "Bravado",
    ["asea"] = "Declasse",
    ["cognoscenti"] = "Enus",
    ["emperor"] = "Cheval",
    ["glendale"] = "Benefactor",
    ["intruder"] = "Karin",
    ["premier"] = "Declasse",
    ["primo2"] = "Albany",
    ["regina"] = "Dundreary",
    ["cogcabri"] = "Enus",
    ["schafter2"] = "Benefactor",
    ["stretch"] = "Dundreary",
    ["superd"] = "Enus",
    ["tailgater"] = "Obey",
    ["warrener"] = "Vulcar",
    ["washington"] = "Albany",
    ["baller2"] = "Gallivanter",
    ["baller3"] = "Gallivanter",
    ["cavalcade2"] = "Albany",
    ["contender"] = "Vapid",
    ["dubsta"] = "Benefactor",
    ["dubsta2"] = "Benefactor",
    ["fq2"] = "Fathom",
    ["granger"] = "Declasse",
    ["gresley"] = "Bravado",
    ["huntley"] = "Enus",
    ["landstalker"] = "Dundreary",
    ["mesa"] = "Canis",
    ["mesa3"] = "Canis",
    ["patriot"] = "Mammoth",
    ["radi"] = "Vapid",
    ["rocoto"] = "Obey",
    ["seminole"] = "Canis",
    ["xls"] = "Benefactor",
    ["btype"] = "Albany",
    ["btype3"] = "Albany",
    ["btype2"] = "Albany",
    ["casco"] = "Lampadati",
    ["coquette2"] = "Invetero",
    ["manana"] = "Albany",
    ["monroe"] = "Pegassi",
    ["pigalle"] = "Lampadati",
    ["stinger"] = "Grotti",
    ["stingergt"] = "Grotti",
    ["feltzer3"] = "Benefactor",
    ["ztype"] = "Truffade",
    ["bifta"] = "BF",
    ["bfinjection"] = "BF",
    ["blazer"] = "Nagasaki",
    ["blazer4"] = "Nagasaki",
    ["brawler"] = "Coil",
    ["dubsta3"] = "Benefactor",
    ["dune"] = "MTL",
    ["guardian"] = "Vapid",
    ["rebel2"] = "Karin",
    ["sandking"] = "Vapid",
    ["monster"] = "Vapid",
    ["trophytruck"] = "Vapid",
    ["trophytruck2"] = "Vapid",
    ["cogcabrio"] = "Enus",
    ["exemplar"] = "Dewbauchee",
    ["f620"] = "Ocelot",
    ["felon"] = "Lampadati",
    ["felon2"] = "Lampadati",
    ["jackal"] = "Ocelot",
    ["oracle2"] = "Übermacht",
    ["sentinel"] = "Übermacht",
    ["sentinel2"] = "Übermacht",
    ["windsor"] = "Lampadati",
    ["windsor"] = "Enus",
    ["windsor2"] = "Enus",
    ["zion"] = "Übermacht",
    ["zion2"] = "Übermacht",
    ["ninef"] = "Obey",
    ["ninef2"] = "Obey",
    ["alpha"] = "Albany",
    ["banshee"] = "Bravado",
    ["bestiagts"] = "Grotti",
    ["buffalo"] = "Bravado",
    ["buffalo2"] = "Bravado",
    ["carbonizzare"] = "Grotti",
    ["comet2"] = "Pfister",
    ["coquette"] = "Invetero",
    ["tampa2"] = "Declasse",
    ["elegy2"] = "Annis",
    ["feltzer2"] = "Benefactor",
    ["furoregt"] = "Lampadati",
    ["fusilade"] = "Schyster",
    ["jester"] = "Dinka",
    ["jester2"] = "Dinka",
    ["khamelion"] = "Hijak",
    ["kuruma"] = "Karin",
    ["lynx"] = "Ocelot",
    ["mamba"] = "Declasse",
    ["massacro"] = "Dewbauchee",
    ["massacro2"] = "Dewbauchee",

    ["omnis"] = "Obey",
    ["penumbra"] = "Maibatsu",
    ["rapidgt"] = "Dewbauchee",
    ["rapidgt2"] = "Dewbauchee",
    ["schafter3"] = "Benefactor",
    ["seven70"] = "Dewbauchee",
    ["sultan"] = " Karin",
    ["surano"] = "Benefactor",
    ["tropos"] = "Lampadati",
    ["verlierer2"] = "Bravado",
    ["adder"] = "Truffade",
    ["banshee2"] = "Bravado",
    ["bullet"] = "Vapid",
    ["cheetah"] = "Grotti",
    ["entityxf"] = "Överflöd",
    ["sheava"] = "Emperor",
    ["fmj"] = "Vapid",
    ["infernus"] = "Pegassi",
    ["osiris"] = "Pegassi",
    ["pfister811"] = "Pfister",
    ["le7b"] = "Annis",
    ["reaper"] = "Pegassi",
    ["sultanrs"] = "Karin",
    ["t20"] = "Progen",
    ["turismor"] = "Grotti",
    ["tyrus"] = "Progen",
    ["vacca"] = "Pegassi",
    ["voltic"] = "Coil",
    ["prototipo"] = "Grotti",
    ["zentorno"] = "Pegassi",
    ["AKUMA"] = "Dewbauchee",
    ["avarus"] = "Liberty City Cycles",
    ["bagger"] = "Western Motorcycle Company",
    ["bati"] = "Pegassi",
    ["bati2"] = "Pegassi",
    ["bf400"] = "Nagasaki",
    
}