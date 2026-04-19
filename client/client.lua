if Shared.Framework == "ESX" then
	Framework = exports[Shared.FrameworkName.ESX]:getSharedObject()
elseif Shared.Framework == "QBCore" then
	Framework = exports[Shared.FrameworkName.QBCore]:GetCoreObject()
elseif Shared.Framework == "qbox" then
	Framework = exports[Shared.FrameworkName.QBOX]:GetCoreObject()
end

local date
local rotation = 70.0
Reward = {}
SpamDelay = false

CreateThread(function()
    while true do
        local sleep = 200
        if Ready then
            for zone,v in pairs(Config_C.Zones) do
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.coords, true)
                    if not Opened and not IsEntityDead(PlayerPedId()) and IsPedOnFoot(PlayerPedId()) then
                        if Config_C.Zones[zone].marker.enabled then
                            if distance < Config_C.Zones[zone].marker.drawDistance then
                                sleep = 0
                                if Config_C.Zones[zone].marker.rotate then
                                    rotation = rotation + 0.6
                                else
                                    rotation = 70.0
                                end
                                DrawMarker(Config_C.Zones[zone].marker.type, Config_C.Zones[zone].coords.x,Config_C.Zones[zone].coords.y,Config_C.Zones[zone].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, rotation, Config_C.Zones[zone].marker.scale.scaleX, Config_C.Zones[zone].marker.scale.scaleX, Config_C.Zones[zone].marker.scale.scaleZ, Config_C.Zones[zone].marker.color.r, Config_C.Zones[zone].marker.color.g, Config_C.Zones[zone].marker.color.b, Config_C.Zones[zone].marker.color.a, false, false, 2, nil, nil, true)
                            end
                        end
                        if distance <= v.interactDistance then
                            ClosestZone = zone
                            sleep = 0
                            Config_C.HelpNotify(Translation[Config_C.Locale]["helpnotify-open"])
                            if IsControlJustPressed(0, 38) then
                                if SpamDelay then
                                else
                                    if Shared.Framework == "ESX" then
                                        Framework.TriggerServerCallback('cs_advent:getData', function(curDate, adventData)
                                            date = curDate
                                            if adventData == nil then
                                                PlayerData = {}
                                                SendNUIMessage({action="toggleUI", type="open", translation=Translation[Config_C.Locale], sounds=Config_C.Sounds, days=Config_C.Days, playerData=PlayerData, curDay=date.day, allowToOpenAfter=Config_C.AllowToOpenAfter})
                                            else
                                                PlayerData = adventData
                                                SendNUIMessage({action="toggleUI", type="open", translation=Translation[Config_C.Locale], sounds=Config_C.Sounds, days=Config_C.Days, playerData=PlayerData, curDay=date.day, allowToOpenAfter=Config_C.AllowToOpenAfter})
                                            end
                                        end)
                                    else
                                        Framework.Functions.TriggerCallback('cs_advent:getData', function(curDate, adventData)
                                            date = curDate
                                            if adventData == nil then
                                                PlayerData = {}
                                                SendNUIMessage({action="toggleUI", type="open", translation=Translation[Config_C.Locale], sounds=Config_C.Sounds, days=Config_C.Days, playerData=PlayerData, curDay=date.day, allowToOpenAfter=Config_C.AllowToOpenAfter})
                                            else
                                                PlayerData = adventData
                                                SendNUIMessage({action="toggleUI", type="open", translation=Translation[Config_C.Locale], sounds=Config_C.Sounds, days=Config_C.Days, playerData=PlayerData, curDay=date.day, allowToOpenAfter=Config_C.AllowToOpenAfter})
                                            end
                                        end)
                                    end
                                    Opened = true
                                    SetNuiFocus(true, true)
                                    StartSpamDelay()
                                end
                            end
                        end
                    end
                end
            end
        Wait(sleep)
    end
end)

RegisterNUICallback("closeUI", function()
    SetNuiFocus(false, false)
    Opened = false
end)

RegisterNUICallback("Notify", function(data)
    SendNUIMessage({action="sendNotify", type="success", message=Translation[Config_C.Locale]["notify-received"]:format(data.notifyData.rewardAmount, data.notifyData.reward, data.notifyData.adventDoor)})
end)

RegisterNUICallback("addRewardItems", function(data)
    TriggerServerEvent('cs_advent:addRewardItems', PlayerData, data.adventDoor, Reward)
end)

RegisterNUICallback("openAdventDoor", function(data)
    if Config_C.AllowToOpenAfter then
        if date.month == Config_C.Month and date.day >= data.adventDoor then
            local randomReward = math.random(1, #Config_C.Days[data.adventDoor].rewards)
            local randomAmount = math.random(Config_C.Days[data.adventDoor].rewards[randomReward].amount[1], Config_C.Days[data.adventDoor].rewards[randomReward].amount[2])
            SendNUIMessage({action="openDoor", day=data.adventDoor, reward=Config_C.Days[data.adventDoor].rewards[randomReward], rewardAmount=randomAmount})
            table.insert(PlayerData, {door=data.adventDoor, type=Config_C.Days[data.adventDoor].rewards[randomReward].type, reward=Config_C.Days[data.adventDoor].rewards[randomReward].name, label=Config_C.Days[data.adventDoor].rewards[randomReward].label, count=randomAmount})
            Reward = {reward=Config_C.Days[data.adventDoor].rewards[randomReward], amount=randomAmount}
        else
            SendNUIMessage({action="sendNotify", type="error", message=Translation[Config_C.Locale]["notify-cannot-open"]:format(data.adventDoor)})
        end
    else
        if date.month == Config_C.Month and date.day == data.adventDoor then
            local randomReward = math.random(1, #Config_C.Days[data.adventDoor].rewards)
            local randomAmount = math.random(Config_C.Days[data.adventDoor].rewards[randomReward].amount[1], Config_C.Days[data.adventDoor].rewards[randomReward].amount[2])
            SendNUIMessage({action="openDoor", day=data.adventDoor, reward=Config_C.Days[data.adventDoor].rewards[randomReward], rewardAmount=randomAmount})
            table.insert(PlayerData, {door=data.adventDoor, type=Config_C.Days[data.adventDoor].rewards[randomReward].type, reward=Config_C.Days[data.adventDoor].rewards[randomReward].name, label=Config_C.Days[data.adventDoor].rewards[randomReward].label, count=randomAmount})
            Reward = {reward=Config_C.Days[data.adventDoor].rewards[randomReward], amount=randomAmount}
        else
            SendNUIMessage({action="sendNotify", type="error", message=Translation[Config_C.Locale]["notify-cannot-open"]:format(data.adventDoor)})
        end
    end
end)

RegisterNetEvent('cs_advent:setVehicle')
AddEventHandler('cs_advent:setVehicle', function(reward)
    if not IsModelInCdimage(reward.name) then return end
        RequestModel(reward.name)
        while not HasModelLoaded(reward.name) do
            Wait(0)
        end
    local RewardVehicle = CreateVehicle(reward.name, GetEntityCoords(PlayerPedId()), 0.0, false, false)
    SetEntityVisible(RewardVehicle, false)
    SetEntityCollision(RewardVehicle, false, false)
    if Shared.Framework == "ESX" then
        local vehicleProps = Framework.Game.GetVehicleProperties(RewardVehicle)
        vehicleProps.plate = GeneratePlate()
        TriggerServerEvent('cs_advent:setVehicle', vehicleProps, reward.name, reward.vehicleType)
        DeleteEntity(RewardVehicle)
        SetEntityAsNoLongerNeeded(RewardVehicle)
    else
        local vehicleProps = Framework.Functions.GetVehicleProperties(RewardVehicle)
        vehicleProps.plate = GeneratePlate()
        TriggerServerEvent('cs_advent:setVehicle', vehicleProps, reward.name, reward.vehicleType)
        DeleteEntity(RewardVehicle)
        SetEntityAsNoLongerNeeded(RewardVehicle)
    end
end)

function StartSpamDelay()
    SpamDelay = true
    SetTimeout(2000, function()
        SpamDelay = false
    end)
end

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end