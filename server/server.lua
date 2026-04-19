if Shared.Framework == "ESX" then
	Framework = exports[Shared.FrameworkName.ESX]:getSharedObject()
elseif Shared.Framework == "QBCore" then
	Framework = exports[Shared.FrameworkName.QBCore]:GetCoreObject()
elseif Shared.Framework == "qbox" then
	Framework = exports[Shared.FrameworkName.QBOX]:GetCoreObject()
end

RegisterServerEvent('cs_advent:addRewardItems')
AddEventHandler('cs_advent:addRewardItems', function(adventData, door, rewardData)
    local source = source
    if Shared.Framework == "ESX" then
        local xPlayer = Framework.GetPlayerFromId(source)
        Config_SV.Update(xPlayer, adventData)
        if rewardData.reward.type == "item" then
            xPlayer.addInventoryItem(rewardData.reward.name, rewardData.amount)
        elseif rewardData.reward.type == "weapon" then
            xPlayer.addWeapon(rewardData.reward.name, 0)
        elseif rewardData.reward.type == "money" then
            xPlayer.addAccountMoney(rewardData.reward.name, rewardData.amount)
        elseif rewardData.reward.type == "vehicle" then
            TriggerClientEvent('cs_advent:setVehicle', source, rewardData.reward)
        end
        if WEBHOOK.DiscordLog.Webhook.Enabled then
            if rewardData.reward.type == "vehicle" or rewardData.reward.type == "weapon"  then
                local rewardName = rewardData.reward.name
                SendDiscordLog({Door=door, Reward=rewardName, Character=xPlayer.name, Name=GetPlayerName(source), Identifier=xPlayer.identifier})
            else
                local rewardName = rewardData.reward.name.." ("..rewardData.amount.."x)"
                SendDiscordLog({Door=door, Reward=rewardName, Character=xPlayer.name, Name=GetPlayerName(source), Identifier=xPlayer.identifier})
            end
        end
    else
        local xPlayer = Framework.Functions.GetPlayer(source)
        Config_SV.Update(xPlayer, adventData)
        if rewardData.reward.type == "item" then
        xPlayer.Functions.AddItem(rewardData.reward.name, rewardData.amount)
        elseif rewardData.reward.type == "weapon" then
        elseif rewardData.reward.type == "money" then
            xPlayer.Functions.AddMoney(rewardData.reward.name, rewardData.amount)
        elseif rewardData.reward.type == "vehicle" then
            TriggerClientEvent('cs_advent:setVehicle', source, rewardData.reward)
        end
        if WEBHOOK.DiscordLog.Webhook.Enabled then
            if rewardData.reward.type == "vehicle" or rewardData.reward.type == "weapon"  then
                local rewardName = rewardData.reward.name
                SendDiscordLog({Door=door, Reward=rewardName, Character=xPlayer.PlayerData.charinfo.firstname.." "..xPlayer.PlayerData.charinfo.lastname, Name=GetPlayerName(source), Identifier=xPlayer.PlayerData.license})
            else
                local rewardName = rewardData.reward.name.." ("..rewardData.amount.."x)"
                SendDiscordLog({Door=door, Reward=rewardName, Character=xPlayer.PlayerData.charinfo.firstname.." "..xPlayer.PlayerData.charinfo.lastname, Name=GetPlayerName(source), Identifier=xPlayer.PlayerData.license})
            end
        end
    end
end)

RegisterServerEvent('cs_advent:setVehicle')
AddEventHandler('cs_advent:setVehicle', function(vehicleProps, vehicleName, vehicleType)
    local source = source
    if Shared.Framework == "ESX" then
        local xPlayer = Framework.GetPlayerFromId(source)
        Config_SV.SetVehicle(xPlayer, vehicleProps, vehicleName, vehicleType)
    else
        local xPlayer = Framework.Functions.GetPlayer(source)
        Config_SV.SetVehicle(xPlayer, vehicleProps, vehicleName, vehicleType)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Config_SV.SetupDB()
end)