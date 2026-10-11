frameworkObject = nil

Citizen.CreateThread(function()
    frameworkObject = GetFrameworkObject() 
end)


Citizen.CreateThread(function()
    for _,v in pairs(Config.GarageCoords) do    
     
         RequestModel(v.npcHash)
         while not HasModelLoaded(v.npcHash) do
        
           Wait(1)
         end

 
         ped =  CreatePed(4,v.npcHash, v.npc.x,v.npc.y,v.npc.z-1, 3374176, false, true)
         SetEntityHeading(ped,v.npcHeading)
         FreezeEntityPosition(ped, true)
         SetEntityInvincible(ped, true)

         SetBlockingOfNonTemporaryEvents(ped, true)
   end

end)




local tables = {}

CreateThread(function()
    Wait(500)
    if Config.Framework == 'esx' then 
        frameworkObject.TriggerServerCallback('neon-garage:loadvehicles2', function(data)
             
                if #data == 0 then
                    print('Vehicles table missing..')
                    print('Vehicles table missing..')
                    print('Vehicles table missing..')
                else
                 for k,v in pairs(data) do        
                     tables[v.hash] = { price = v.price}              
                 end  
                end            
        end)
    else
    for k,v in pairs(frameworkObject.Shared.Vehicles) do
        tables[v.model] = { price = v.price, brand = v.brand, name = v.name  }
    end
    end
 
end)








RegisterNetEvent('notfiycheck')
AddEventHandler('notfiycheck', function(par1,par2)   
    SendNUIMessage({
        action = 'notify',
        message = par1,
        type = par2,
        
    }) 

end)


local lastgarage 
local garajtype 
local newstored 
local vehicleprice 
local sellcar = Config.SellCar
local transferCar = Config.TransferCar
local arabaDisarda = true
local impound  = {}
local press1 = true
local press2 = false
Citizen.CreateThread(function()
    if Config.Framework == 'esx' then
        while true do
        local Sleep = 2000
        local PlayerPed = PlayerPedId()
        local PlayerCoord = GetEntityCoords(PlayerPed)
        local BinilenArac = GetVehiclePedIsIn(PlayerPed)
        local ArabaPlaka = GetVehicleNumberPlateText(BinilenArac)
        for k,v in pairs(Config.GarageCoords) do
          
            local Distance = #(PlayerCoord - v.parking) 

            if Distance <= 3.0 then
                if IsPedInAnyVehicle(PlayerPedId(),false)  then 
                    Sleep = 5
                    frameworkObject.ShowHelpNotification(Config.HelpNotfiy)
                    DrawMarker(Config.drawmarkerid, v.parking, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 6.0, 6.0, 0.20, Config.red , Config.green , Config.blue , Config.alpha , false, false, false, 1, false, false, false)
                    if IsControlJustReleased(0, 38) then
                        frameworkObject.TriggerServerCallback('neon-garage:vehicleOwned', function(owned)
                            if owned then
                                
                                TriggerServerEvent('neon-garage:saveProps', ArabaPlaka, frameworkObject.Game.GetVehicleProperties(BinilenArac))
                                TaskLeaveVehicle(PlayerPed, BinilenArac, 0)
                                Citizen.Wait(2500)
                                frameworkObject.Game.DeleteVehicle(BinilenArac)
                                TriggerServerEvent('neon-garage:stored', ArabaPlaka, 1)
                            else
                                frameworkObject.ShowNotification('Araç senin değil')
                            end
                        end, ArabaPlaka)
                    end
                end
            elseif Distance <= 20.0 then
                Sleep = 5
                DrawMarker(1, v.parking.x, v.parking.y, v.parking.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 6.0, 6.0, 0.30, 120, 10, 20, 155, false, false, false, 1, false, false, false)
            end       
            if v.garageType == 'normal' then
                
                    local dist = #(PlayerCoord - v.npc )
                    if dist <= 3.0 then
                        Sleep = 0
                        DrawText3D(v.npc.x,v.npc.y,v.npc.z + 0.98,"[E] GARAGE")

                        if IsControlJustReleased(0,38) then
                            press1 = false
                            press2 = true
                            lastgarage = k
                            garajtype = 1
                      
                            frameworkObject.TriggerServerCallback('neon-garage:loadvehicles', function(veri)

                            if #veri == 0 then
                                frameworkObject.ShowHelpNotification(Config.HelpNotfiy1)                              
                            else                              
                                for _,v in pairs(veri) do 
                                    if v.stored then
                                        newstored = 1                                      
                                    else
                                        newstored = 0
                                    end                                  
                                     
                                    local carhash = v.vehicle.model
                                    local damage = v.vehicle.engineHealth / 10                            
                                    local carname = GetDisplayNameFromVehicleModel(carhash)                                       
                                    local spawnkod = string.gsub(carname, "%s+", ""):lower();
                                    local vehicleName = GetLabelText(carname)                                          
                                    local brand = Config.VehiclesManufacturer[spawnkod] or Config.DefaultManufacturer
                                    local fuellevel = v.vehicle.fuelLevel
                                    local plate = v.plate   
                                    local body =  v.vehicle.bodyHealth  / 10 
                                   
                                   
                                    if tables[carhash] ~= nil then 
                                        local price = tables[carhash]
                                        vehicleprice = price.price / 2 
                                    else
                                        vehicleprice = 0
                                    end    
                                
                                                                                             
                                    AddCar(newstored,body,carhash,plate, spawnkod,vehicleName,damage,fuellevel,brand,vehicleprice,garajtype,sellcar,transferCar)
                                 
                                end                              
                            end    
                            end)
                            Citizen.Wait(1000)
                        end
                    end
               
                
            elseif v.garageType == 'impound' then
              
                    local dist = #(PlayerCoord - v.npc )
                        if dist <= 3.0 then
                            Sleep = 0
                        DrawText3D(v.npc.x,v.npc.y,v.npc.z + 0.98,"[E] IMPOUND GARAGE")
                        if IsControlJustReleased(0,38) then
                            lastgarage = k
                              garajtype = 0
                              frameworkObject.TriggerServerCallback('neon-garage:impoundGarage', function(veri)
                               
                            if #veri == 0 then
                                frameworkObject.ShowHelpNotification(Config.HelpNotfiy1)
                            
                            else
                                impound = {}
                                for _,v in pairs(veri) do 
                                                                      
                                    if not  v.stored then
                                    frameworkObject.TriggerServerCallback('neon-garage:changedCars', function(veri2)      
                                                                    
                                    if veri2 then
                                      
                                        impound[v.plate] = true
                                                     
                                    else
                                      
                                        impound[v.plate] = false
                                    end
                                  
                                     end,v.plate)
                                    while impound[v.plate] == nil do
                                        Citizen.Wait(0)
                                    end
                                   
                                    local carhash = v.vehicle.model
                                    local damage = v.vehicle.engineHealth / 10                            
                                    local carname = GetDisplayNameFromVehicleModel(carhash)                                       
                                    local spawnkod = string.gsub(carname, "%s+", ""):lower();
                                    local vehicleName = GetLabelText(carname)                                          
                                    local brand = Config.VehiclesManufacturer[spawnkod] or Config.DefaultManufacturer
                                    local fuellevel = v.vehicle.fuelLevel
                                    local plate = v.plate   
                                    local body =  v.vehicle.bodyHealth  / 10 
                                    if tables[carhash] ~= nil then 
                                        local price = tables[carhash]
                                        vehicleprice = price.price / 2 
                                    else
                                        vehicleprice = 0
                                    end                                                                                                                                                                                                                    
                                    AddCar(newstored,body,carhash,plate, spawnkod,vehicleName,damage,fuellevel,brand,vehicleprice,garajtype,sellcar,transferCar,impound[v.plate])
                               
                                end 
                                end 
                            end    
                            end)
                            Citizen.Wait(1000)
                        end
                    end
                                  
            end
        end

      
        Citizen.Wait(Sleep)
        end
    else  --- qb framework
        while true do
            local Sleep = 2000
            local PlayerPed = PlayerPedId()
            local PlayerCoord = GetEntityCoords(PlayerPed)
            local BinilenArac = GetVehiclePedIsIn(PlayerPed)
            local ArabaPlaka = GetVehicleNumberPlateText(BinilenArac)
            for k,v in pairs(Config.GarageCoords) do
              
                local Distance = #(PlayerCoord - v.parking) 
    
                if Distance <= 3.0 then
                    if IsPedInAnyVehicle(PlayerPedId(),false)  then 
                        Sleep = 5
                  
                        DrawMarker(Config.drawmarkerid, v.parking, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 6.0, 6.0, 0.20, Config.red , Config.green , Config.blue , Config.alpha , false, false, false, 1, false, false, false)
                        if IsControlJustReleased(0, 38) then
                            frameworkObject.Functions.TriggerCallback('neon-garage:vehicleOwned', function(owned)
                                if owned then
                                    
                                    TriggerServerEvent('neon-garage:saveProps', ArabaPlaka, frameworkObject.Functions.GetVehicleProperties(BinilenArac))
                                    TaskLeaveVehicle(PlayerPed, BinilenArac, 0)
                                    Citizen.Wait(2500)
                                   frameworkObject.Functions.DeleteVehicle(BinilenArac)
                                    TriggerServerEvent('neon-garage:stored', ArabaPlaka, 1)
                                else
                               
                                     Config.Notification(Config.Notifications["notowner"]["message"],Config.Notifications["notowner"]["type"])
                                end
                            end, ArabaPlaka)
                        end
                    end
                elseif Distance <= 20.0 then
                    Sleep = 5
                    DrawMarker(1, v.parking.x, v.parking.y, v.parking.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 6.0, 6.0, 0.30, 120, 10, 20, 155, false, false, false, 1, false, false, false)
                end       
                if v.garageType == 'normal' then
                 
                        local dist = #(PlayerCoord - v.npc )
                        if dist <= 3.0 then
                            Sleep = 0
                            DrawText3D(v.npc.x,v.npc.y,v.npc.z + 0.98,"[E] GARAGE")
                            if IsControlJustReleased(0,38) then
                                lastgarage = k
                                garajtype = tonumber(1)
                                frameworkObject.Functions.TriggerCallback('neon-garage:loadvehicles', function(veri)
                              
                                if #veri == 0 then
                                    Config.Notification(Config.Notifications["notvehicle"]["message"],Config.Notifications["notvehicle"]["type"]) 
                                else
                                    for _,v in pairs(veri) do   
                                    
                                        if v.stored == 1 then
                                        
                                            newstored = 1                                      
                                        else
                                            newstored = 0
                                        end                      
                                       local carhash = v.hash
                                       local damage = v.vehicle.engineHealth / 10                            
                                       local carname = v.carname                                                               
                                       local spawnkod = string.gsub(carname, "%s+", ""):lower();                                                                            
 
                                        local brand2 = tables[carname] or {}
                                        local brand = brand2.brand or Config.DefaultManufacturer
                                        local vehicleName = brand2.name or carname
                                        local vehicleprice = (tonumber(brand2.price) or 0) / 2
                                        local fuellevel = v.vehicle.fuelLevel
                                        local plate = v.plate   
                                         local body =  v.vehicle.bodyHealth  / 10   
                                    
                                                        
                                       AddCar(newstored,body,carhash,plate, spawnkod,vehicleName,damage,fuellevel,brand,vehicleprice,tonumber(garajtype),sellcar,transferCar)
                                    end                              
                                end    
                                end)
                                Citizen.Wait(1000)
                            end
                        end
                   
                 
                    
                elseif v.garageType == 'impound' then
                   
                        local dist = #(PlayerCoord - v.npc )
                        if dist <= 3.0 then
                            Sleep = 2
                            DrawText3D(v.npc.x,v.npc.y,v.npc.z + 0.98,"[E] IMPOUND GARAGE")
                            if IsControlJustReleased(0,38) then
                                lastgarage = k
                                garajtype = 0
                                frameworkObject.Functions.TriggerCallback('neon-garage:loadvehicles', function(veri)
                               
                                   
                                        for _,v in pairs(veri) do                                         
                                            
                                            if v.stored == 0 then
                                                frameworkObject.Functions.TriggerCallback('neon-garage:changedCars', function(veri2)      
                                                                                
                                                if veri2 then
                                                  
                                                    impound[v.plate] = true
                                                                 
                                                else
                                                  
                                                    impound[v.plate] = false
                                                end
                                              
                                                 end,v.plate)
                                                while impound[v.plate] == nil do
                                                    Citizen.Wait(0)
                                                end
                                                                   
                                               local carhash = v.hash
                                               local damage = v.vehicle.engineHealth / 10                            
                                               local carname = v.carname                                                               
                                               local spawnkod = string.gsub(carname, "%s+", ""):lower();                                                                            
         
                                                local brand2 = tables[carname] or {}
                                                local brand = brand2.brand or Config.DefaultManufacturer
                                                local vehicleName = brand2.name or carname
                                                local vehicleprice = (tonumber(brand2.price) or 0) / 2
                                                local fuellevel = v.vehicle.fuelLevel
                                                local plate = v.plate   
                                                 local body =  v.vehicle.bodyHealth  / 10  
                                                 AddCar(newstored,body,carhash,plate, spawnkod,vehicleName,damage,fuellevel,brand,vehicleprice,tonumber(garajtype),sellcar,transferCar,impound[v.plate]) 
                                            else
                                                Config.Notification(Config.Notifications["notvehicle"]["message"],Config.Notifications["notvehicle"]["type"]) 
                                            end
                                        end
                                        
                                        
                                end)
                                Citizen.Wait(1000)
                            end
                        end
                 
                      
                  
                end
            end
    
          
            Citizen.Wait(Sleep)
            end

    end
end)





RegisterNUICallback('closepage',function()

    SetNuiFocus(false,false)
end)


RegisterNUICallback('spawnvehicle',function(data,cb)
    if Config.Framework == 'esx' then 
        frameworkObject.TriggerServerCallback('neon-garage:checkMoneyCars', function(hasEnoughMoney)
            if hasEnoughMoney then

                frameworkObject.TriggerServerCallback('neon-garage:vehicleOwner', function(cars)
                
                    local x,y,z = table.unpack(Config.GarageCoords[lastgarage]["parkout"])
                    local props = json.decode(cars[1].vehicle)
                
                    frameworkObject.Game.SpawnVehicle(props.model, {
                       x = x,
                       y = y,
                       z = z + 1
                   }, Config.GarageCoords[lastgarage]["vehicleHeading"], function(callback_vehicle)
                    frameworkObject.Game.SetVehicleProperties(callback_vehicle, props)
                       SetVehRadioStation(callback_vehicle, "OFF")
                       TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
                       if garajtype then
                       TriggerServerEvent('neon-garage:payCar', garajtype)
                       
                       else 
                       
                        TriggerServerEvent('neon-garage:payCar',garajtype)
                       end
                   end)
               
               end,data.plate)
               TriggerServerEvent('neon-garage:stored', data.plate, 0)
            else
                Config.Notification(Config.Notifications["money"]["message"],Config.Notifications["money"]["type"])
            end
        end,garajtype)
    else -- qbcore
        frameworkObject.Functions.TriggerCallback('neon-garage:checkMoneyCars', function(hasEnoughMoney)
            if hasEnoughMoney then

                frameworkObject.Functions.TriggerCallback('neon-garage:vehicleOwner', function(cars)
                    if not cars or not cars[1] then return end
                    local x,y,z = table.unpack(Config.GarageCoords[lastgarage]["parkout"])
                    local props = json.decode(cars[1].mods) or {}

                    frameworkObject.Functions.SpawnVehicle(cars[1].vehicle, function(callback_vehicle)

                        frameworkObject.Functions.SetVehicleProperties(callback_vehicle, props)
                        SetVehRadioStation(callback_vehicle, "OFF")
                        TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
                        TriggerEvent("vehiclekeys:client:SetOwner", frameworkObject.Functions.GetPlate(callback_vehicle))
                        local fuel = tonumber(props.fuel or props.fuelLevel or cars[1].fuel) or 100.0
                        if GetResourceState('LegacyFuel') == 'started' then
                            exports['LegacyFuel']:SetFuel(callback_vehicle, fuel)
                        else
                            SetVehicleFuelLevel(callback_vehicle, fuel + 0.0)
                        end
                        if garajtype then
                           
                            TriggerServerEvent('neon-garage:payCar', garajtype)
                        else 
                            
                         TriggerServerEvent('neon-garage:payCar',garajtype)
                        end

                    end, vector4(x,y,z,Config.GarageCoords[lastgarage]["vehicleHeading"]), true)
               
               end,data.plate)
               TriggerServerEvent('neon-garage:stored', data.plate, 0)
            else
                Config.Notification(Config.Notifications["money"]["message"],Config.Notifications["money"]["type"])
            end
        end,garajtype)


    end

      
end)


RegisterNUICallback('sellvehicle',function(data,cb)
    local hash = tonumber(data.hash)
    local price = tonumber(data.price)
    local plate = data.plate
    local sell = false
    for _,v in pairs(Config.BlacklistVehicles) do
           
           if hash == tonumber(v) then
                sell = true
                cb(sell)
            return
           end
    end
    cb(sell)
    TriggerServerEvent("neon-garage:sellPrice",plate,price)

     
end)
RegisterNUICallback('transfervehicle',function(data,cb)
    local id = tonumber(data.id)
    local plate = data.plate 
    TriggerServerEvent("neon-garage:TransferVehicle",id,plate)
end)




function AddCar(stored,body,carhash,plate, model,name,damage,fuellevel,brand,vehicleprice,garajtype,sellcar,transferCar,impound)

    SetNuiFocus(true, true)
          SendNUIMessage({
              action = 'open',             
              stored = stored,
              body = body,
              carhash = carhash,
              plate = plate,
              model = model,
              damage = damage,
              name = name,
              fuellevel = fuellevel,
              brand = brand,
              vehicleprice = vehicleprice,
              garaj = garajtype,
              sellcar = sellcar,
              transferCar = transferCar,
              impound = impound
              
          }) 
end




Citizen.CreateThread(function()
    for _, coords in pairs(Config.GarageCoords) do
        local blip = AddBlipForCoord(coords.npc)

        SetBlipSprite(blip, 357)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 49)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(coords.garageName)
        EndTextCommandSetBlipName(blip)
    end
end)
         




