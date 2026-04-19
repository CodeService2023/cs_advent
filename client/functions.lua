if Shared.Framework == "ESX" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded',function()
        Ready = false
        Wait(6000)
        Ready = true
        CreateBlips()
    end)
else
	RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
        Ready = false
        Wait(6000)
        Ready = true
        CreateBlips()
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Ready = false
    Wait(6000)
    Ready = true
    CreateBlips()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    DeletePed(Ped)
end)

function CreateBlips()
    CreateThread(function()
        for zone, v in pairs(Config_C.Zones) do
            if Config_C.Zones[zone].blip.enabled then
                local blip = AddBlipForCoord(Config_C.Zones[zone].coords.x,Config_C.Zones[zone].coords.y,Config_C.Zones[zone].coords.z)
                SetBlipSprite (blip, Config_C.Zones[zone].blip.type)
                SetBlipScale  (blip, Config_C.Zones[zone].blip.size)
                SetBlipColour (blip, Config_C.Zones[zone].blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(Config_C.Zones[zone].blip.name)
                EndTextCommandSetBlipName(blip)
            end
            if Config_C.Zones[zone].npc.enabled then
                RequestModel(Config_C.Zones[zone].npc.hash)
                while not HasModelLoaded(Config_C.Zones[zone].npc.hash) do
                    Wait(1)
                end
                Ped = CreatePed(Config_C.Zones[zone].npc.type,Config_C.Zones[zone].npc.hash,Config_C.Zones[zone].coords[1],Config_C.Zones[zone].coords[2],Config_C.Zones[zone].coords[3]-1, 3374176, false, true)
                SetEntityHeading(Ped,Config_C.Zones[zone].npc.heading)
                FreezeEntityPosition(Ped, true)
                SetEntityInvincible(Ped, true)
                SetBlockingOfNonTemporaryEvents(Ped, true)
            end
        end
   end)
end

local NumberCharset = {}
local Charset = {}

 for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
 for i = 65,  90 do table.insert(Charset, string.char(i)) end
 for i = 97, 122 do table.insert(Charset, string.char(i)) end

 function GeneratePlate()
	math.randomseed(GetGameTimer())
	local generatedPlate = string.upper(GetRandomLetter(Config_C.PlateLetters) .. (Config_C.PlateUseSpace and ' ' or '') .. GetRandomNumber(Config_C.PlateNumbers))

	local isTaken = IsPlateTaken(generatedPlate)
	if isTaken then 
		return GeneratePlate()
	end
	return generatedPlate
end

function IsPlateTaken(plate)
	local p = promise.new()
    if Shared.Framework == "ESX" then
        Framework.TriggerServerCallback('cs_vehicleshop:isPlateTaken', function(isPlateTaken)
            p:resolve(isPlateTaken)
        end, plate)
    else
        Framework.Functions.TriggerCallback('cs_vehicleshop:isPlateTaken', function(isPlateTaken)
            p:resolve(isPlateTaken)
        end, plate)
    end
	return Citizen.Await(p)
end

function GetRandomNumber(length)
     Wait(1)
     math.randomseed(GetGameTimer())
     if length > 0 then
         return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
     else
         return ''
     end
end

function GetRandomLetter(length)
     Wait(1)
     math.randomseed(GetGameTimer())
     if length > 0 then
         return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
     else
         return ''
     end
end