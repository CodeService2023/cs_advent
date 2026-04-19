Config_SV = {}

if Shared.Framework == "ESX" then
	Framework = exports[Shared.FrameworkName.ESX]:getSharedObject()
elseif Shared.Framework == "QBCore" then
	Framework = exports[Shared.FrameworkName.QBCore]:GetCoreObject()
elseif Shared.Framework == "qbox" then
	Framework = exports[Shared.FrameworkName.QBOX]:GetCoreObject()
end

if Shared.Framework == "ESX" then
    Framework.RegisterServerCallback("cs_advent:getData", function(source, cb)
        local xPlayer = Framework.GetPlayerFromId(source)
        MySQL.scalar('SELECT identifier FROM cs_advent WHERE identifier=?', {xPlayer.identifier},
            function(identifier)
                if identifier == xPlayer.identifier then
                    MySQL.scalar('SELECT data FROM cs_advent WHERE identifier = ?', {xPlayer.identifier},
                        function(data)
                        cb(os.date("*t"), json.decode(data))
                    end)
                else
                Config_SV.Insert(xPlayer, nil)
                cb(os.date("*t"), nil)
            end
        end)
    end)
else
    Framework.Functions.CreateCallback('cs_advent:getData', function(source, cb)
        local xPlayer = Framework.Functions.GetPlayer(source)
        MySQL.scalar('SELECT identifier FROM cs_advent WHERE identifier=?', {xPlayer.PlayerData.license},
            function(identifier)
                if identifier == xPlayer.PlayerData.license then
                    MySQL.scalar('SELECT data FROM cs_advent WHERE identifier = ?', {xPlayer.PlayerData.license},
                        function(data)
                        cb(os.date("*t"), json.decode(data))
                    end)
                else
                Config_SV.Insert(xPlayer, nil)
                cb(os.date("*t"), nil)
            end
        end)
    end)
end

if Shared.Framework == "ESX" then
    Framework.RegisterServerCallback('cs_vehicleshop:isPlateTaken', function (source, cb, plate)
        MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
        function(result)
            cb(result ~= nil)
        end)
    end)
else
    Framework.Functions.CreateCallback('cs_vehicleshop:isPlateTaken', function(source, cb, plate)
        MySQL.scalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate},
        function(result)
            cb(result ~= nil)
        end)
    end)
end

Config_SV.SetVehicle = function(xPlayer, vehicleProps, vehicleName, vehicleType)
    if Shared.Framework == "ESX" then
        MySQL.Sync.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)', {
            ['@owner']   = xPlayer.identifier,
            ['@plate']   = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@stored']  = 1,
            ['@type'] = vehicleType,
        })
    else
        MySQL.Sync.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage, @state)', {
            ['@license']   = xPlayer.PlayerData.license,
            ['@citizenid']   = xPlayer.PlayerData.citizenid,
            ['@vehicle'] = vehicleName,
            ['@hash']  = GetHashKey(vehicleName),
            ['@mods'] = json.encode(vehicleProps),
            ['@plate'] = vehicleProps.plate,
            ['@garage'] = "pillboxgarage",
            ['@state'] = 1,
        })
    end
end

Config_SV.Insert = function(xPlayer, adventData)
    if Shared.Framework == "ESX" then
        MySQL.Sync.execute('INSERT INTO cs_advent (identifier, data) VALUES (@identifier, @data)', {
            ['@identifier'] = xPlayer.identifier,
            ['@data'] = json.encode(adventData),
        })
    else
        MySQL.Sync.execute('INSERT INTO cs_advent (identifier, data) VALUES (@identifier, @data)', {
            ['@identifier'] = xPlayer.PlayerData.license,
            ['@data'] = json.encode(adventData),
        })
    end
end

Config_SV.Update = function(xPlayer, adventData)
    if Shared.Framework == "ESX" then
        MySQL.Sync.execute('UPDATE cs_advent SET data = @data WHERE identifier = @identifier', {
            ["@identifier"] = xPlayer.identifier,
            ["@data"] = json.encode(adventData),
        })
    else
        MySQL.Sync.execute('UPDATE cs_advent SET data = @data WHERE identifier = @identifier', {
            ["@identifier"] = xPlayer.PlayerData.license,
            ["@data"] = json.encode(adventData),
        })
    end
end

Config_SV.SetupDB = function()
    MySQL.Sync.execute([[
    CREATE TABLE IF NOT EXISTS `cs_advent` (
        `identifier` varchar(50) NOT NULL,
        `data` longtext NOT NULL,
        PRIMARY KEY (`identifier`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
end