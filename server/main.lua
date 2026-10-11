frameworkObject = GetFrameworkObject()

local QBCore = frameworkObject

local function notify(src, key, suffix)
    local entry = Config.Notifications[key]
    if entry then
        TriggerClientEvent('QBCore:Notify', src, entry.message .. (suffix or ''), entry.type, 1500)
    end
end

local function notifyUI(src, key)
    local entry = Config.Notifications[key]
    if entry then
        TriggerClientEvent('notfiycheck', src, entry.message, entry.type)
    end
end

local function isValidPlate(plate)
    return type(plate) == 'string' and #plate > 0 and #plate <= 12
end

local function getOwnedVehicle(src, plate)
    if not isValidPlate(plate) then
        return nil
    end
    local player = QBCore.Functions.GetPlayer(src)
    if not player then
        return nil
    end
    local citizenid = player.PlayerData.citizenid
    return MySQL.single.await('SELECT * FROM `player_vehicles` WHERE `plate` = ? AND `citizenid` = ?', { plate, citizenid }), citizenid, player
end

local function getPlayerVehicles(src)
    local player = QBCore.Functions.GetPlayer(src)
    if not player then
        return {}
    end
    return MySQL.query.await('SELECT * FROM `player_vehicles` WHERE `citizenid` = ?', { player.PlayerData.citizenid }) or {}
end

local function isBlacklisted(model)
    local hash = joaat(model)
    for _, blacklisted in pairs(Config.BlacklistVehicles or {}) do
        if tonumber(blacklisted) == hash then
            return true
        end
    end
    return false
end

local function getSellPrice(model)
    local data = QBCore.Shared.Vehicles[model]
    local price = data and tonumber(data.price) and data.price / 2 or 0
    return math.floor(price)
end

local function isNormalGarage(garageType)
    return tonumber(garageType) ~= 0 and garageType ~= false and garageType ~= nil
end

local function getGarageFee(garageType)
    local account = Config.Account == 'bank' and 'bank' or 'cash'
    local price = isNormalGarage(garageType) and Config.Price or Config.impoundPrice
    return account, price
end

local function getIdentifiers(src)
    local discord = GetPlayerIdentifierByType(src, 'discord')
    return {
        discord = discord and ('<@' .. discord:sub(9) .. '>') or 'Bilinmiyor',
        license = GetPlayerIdentifierByType(src, 'license') or 'Bilinmiyor'
    }
end

local function dclog(webhook, title, text)
    if type(webhook) ~= 'string' or not webhook:find('^https?://') then
        return
    end

    local embeds = {
        {
            color = 3092790,
            title = title,
            description = text,
            footer = {
                text = 'Neon Garage      ' .. os.date('%Y-%m-%d %H:%M:%S'),
                icon_url = Config.IconURL,
            },
        }
    }

    PerformHttpRequest(webhook, function() end, 'POST', json.encode({
        username = Config.Botname,
        embeds = embeds,
        avatar_url = Config.Logo
    }), { ['Content-Type'] = 'application/json' })
end

QBCore.Functions.CreateCallback('neon-garage:loadvehicles', function(source, cb)
    local ownedCars = {}
    for _, v in pairs(getPlayerVehicles(source)) do
        ownedCars[#ownedCars + 1] = {
            vehicle = json.decode(v.mods),
            stored = v.state,
            plate = v.plate,
            hash = v.hash,
            carname = v.vehicle,
        }
    end
    cb(ownedCars)
end)

QBCore.Functions.CreateCallback('neon-garage:impoundGarage', function(source, cb)
    local impoundCars = {}
    for _, v in pairs(getPlayerVehicles(source)) do
        impoundCars[#impoundCars + 1] = {
            vehicle = json.decode(v.mods),
            stored = v.state,
            plate = v.plate,
        }
    end
    cb(impoundCars)
end)

QBCore.Functions.CreateCallback('neon-garage:vehicleOwner', function(source, cb, plate)
    local vehicle = getOwnedVehicle(source, plate)
    cb(vehicle and { vehicle } or {})
end)

QBCore.Functions.CreateCallback('neon-garage:vehicleOwned', function(source, cb, plate)
    if type(plate) == 'string' then
        plate = plate:gsub('^%s+', ''):gsub('%s+$', '')
    end
    cb(getOwnedVehicle(source, plate) ~= nil)
end)

QBCore.Functions.CreateCallback('neon-garage:changedCars', function(source, cb, plate)
    if type(plate) ~= 'string' then
        return cb(false)
    end

    plate = plate:gsub('%s+', ''):lower()
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        if GetVehicleNumberPlateText(vehicles[i]):gsub('%s+', ''):lower() == plate then
            return cb(true)
        end
    end
    cb(false)
end)

QBCore.Functions.CreateCallback('neon-garage:checkMoneyCars', function(source, cb, garageType)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then
        return cb(false)
    end

    local account, price = getGarageFee(garageType)
    cb((player.PlayerData.money[account] or 0) >= price)
end)

RegisterNetEvent('neon-garage:saveProps', function(plate, props)
    local src = source
    if type(props) ~= 'table' then
        return
    end
    if type(plate) == 'string' then
        plate = plate:gsub('^%s+', ''):gsub('%s+$', '')
    end
    local vehicle, citizenid = getOwnedVehicle(src, plate)
    if not vehicle then
        return
    end
    MySQL.update.await('UPDATE `player_vehicles` SET `mods` = ? WHERE `plate` = ? AND `citizenid` = ?', { json.encode(props), plate, citizenid })
end)

RegisterNetEvent('neon-garage:stored', function(plate, state)
    local src = source
    state = tonumber(state)
    if state ~= 0 and state ~= 1 then
        return
    end
    if type(plate) == 'string' then
        plate = plate:gsub('^%s+', ''):gsub('%s+$', '')
    end
    local vehicle, citizenid = getOwnedVehicle(src, plate)
    if not vehicle then
        return
    end
    MySQL.update.await('UPDATE `player_vehicles` SET `state` = ? WHERE `plate` = ? AND `citizenid` = ?', { state, plate, citizenid })
end)

RegisterNetEvent('neon-garage:sellPrice', function(plate)
    local src = source
    if not Config.SellCar then
        return notify(src, 'price_error')
    end

    local vehicle, citizenid, player = getOwnedVehicle(src, plate)
    if not vehicle or isBlacklisted(vehicle.vehicle) then
        return
    end

    local price = getSellPrice(vehicle.vehicle)
    local deleted = MySQL.update.await('DELETE FROM `player_vehicles` WHERE `plate` = ? AND `citizenid` = ?', { plate, citizenid })
    if not deleted or deleted < 1 then
        return
    end

    player.Functions.AddMoney('bank', price, 'neon-garage-sell')
    notifyUI(src, 'carsell')

    local ids = getIdentifiers(src)
    dclog(Config.SellWebhook, 'Garage Sell Vehicle', ('\n Discord : %s\n License : %s\n ID : %s\n Price : %s\n Plate : %s'):format(ids.discord, ids.license, src, price, plate))
end)

RegisterNetEvent('neon-garage:TransferVehicle', function(targetId, plate)
    local src = source
    if not Config.TransferCar then
        return notify(src, 'player_transfer_error')
    end

    targetId = tonumber(targetId)
    if not targetId or not isValidPlate(plate) then
        return
    end
    if targetId == src then
        return notifyUI(src, 'error_transfer')
    end

    local target = QBCore.Functions.GetPlayer(targetId)
    if not target then
        return notifyUI(src, 'player_transfer')
    end

    local vehicle, citizenid = getOwnedVehicle(src, plate)
    if not vehicle then
        return
    end

    local updated = MySQL.update.await('UPDATE `player_vehicles` SET `citizenid` = ?, `license` = ? WHERE `plate` = ? AND `citizenid` = ?', {
        target.PlayerData.citizenid,
        target.PlayerData.license,
        plate,
        citizenid
    })
    if not updated or updated < 1 then
        return
    end

    notify(src, 'transfer')
    notify(targetId, 'transfer2')

    local owner = getIdentifiers(src)
    local newOwner = getIdentifiers(targetId)
    dclog(Config.TransferWeebhok, 'Garage Transfer LOG', ('\n Vehicle Owner \n Discord : %s\n License : %s\n ID : %s\n\n New Vehicle Owner \n Discord : %s\n License : %s\n ID : %s\n\n Vehicle Plate : %s'):format(owner.discord, owner.license, src, newOwner.discord, newOwner.license, targetId, plate))
end)

RegisterNetEvent('neon-garage:payCar', function(garageType)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then
        return
    end

    local account, price = getGarageFee(garageType)
    if player.Functions.RemoveMoney(account, price, 'neon-garage-fee') then
        notify(src, 'parkprice', tostring(price))
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        MySQL.update.await('UPDATE `player_vehicles` SET `state` = 1')
    end
end)
