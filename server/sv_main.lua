local QBCore = exports['qb-core']:GetCoreObject() -- Core

-- Callbacks 
QBCore.Functions.CreateCallback("qb-drugs:Server:canStartMission", function(source, cb, price) -- Checks if player has enough money to start the mission
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    local enough = Player.Functions.GetMoney('cash') >= price
    if not Player then return end
    if enough then 
        Player.Functions.RemoveMoney('cash', price)
        canStart = true
    else 
        canStart = false
    end
    cb(canStart)
end)

QBCore.Functions.CreateCallback("qb-drugs:Server:grabServerConfig", function(source, cb) -- Grabs the server-side config
    local cServer = cServer
    cb(cServer)
end)

QBCore.Functions.CreateCallback("qb-drugs:Server:canProcessDrugs", function(source, cb, drug, process) -- Checks players inventory for specific drug
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not drug then return end

    for k, v in pairs(Drugs.Processing[process]) do
        local item = Player.Functions.GetItemByName(Drugs.Processing[process])
        if not item then return end 
        if item.amount >= Drugs.Processing[process].requires then 
            canProcess = true
        else
            canProcess = false
        end
    end
    cb(canProcess) 
end)

QBCore.Functions.CreateCallback("qb-drugs:Server:checkCooldownStatus", function(source, cb) -- Checks cooldown status of mission NPC
    local cooldown = Drugs.npcCooldown
    cb(cooldown)
end)

-- Events
RegisterNetEvent("qb-drugs:Server:itemHandling", function(action, item, amount) -- Item Handling
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not item or not amount or not action then return end 

    for k, v in pairs(Drugs.Items) do
        if action == 'add' then
            if v == item then 
                Player.Functions.AddItem(item, amount)
            end
        elseif action == 'remove' then 
            if v == item then 
                Player.Functions.RemoveItem(item, amount)
            end
        end
    end 
end)

RegisterNetEvent("qb-drugs:Server:itemPackageHandling", function(drug) -- Processing of the drugs Handling
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(drug)
    if not Player or not drug then return end
    if not item then TriggerClientEvent('QBCore:Notify', source, "You don't have enough " .. drug .. " to bag", "error") return end

    for k, v in pairs(Drugs.Packaging) do
        if k == drug then
            if item.amount >= Drugs.Packaging[k].requires then    
                Player.Functions.RemoveItem(drug, Drugs.Packaging[k].requires)
                Player.Functions.RemoveItem(Drugs.Packaging[k].needs, 1)
                Player.Functions.AddItem(Drugs.Packaging[k].turnsInto, 1)
                TriggerClientEvent('QBCore:Notify', source, "Successfully bagged some " .. k, "success")
            end
        end
    end
end)

RegisterNetEvent("qb-drugs:Server:UpdateReputation", function(drug, xp, src) -- Reputation System
    local Player = QBCore.Functions.GetPlayer(src)
    if not drug or not xp then return end

    for k, v in pairs(Drugs.Info) do
        local DrugReputation = Player.PlayerData.metadata['xpSystem']
        local DrugLevel = Player.PlayerData.metadata['druglevel']
        if DrugReputation and k == drug then
            DrugReputation[drug] = DrugReputation[drug] + xp 
            while DrugReputation[drug] > Drugs.Info[drug].level.repToLvl do 
                Player.Functions.AddDrugLevel(drug, 1)
                Drugs.Info[drug].level.repToLvl = Drugs.Info[drug].level.repToLvl + Drugs.Info[drug].level.repToLvlAdd
                DrugReputation[drug] = DrugReputation[drug] - Drugs.Info[drug].level.repToLvl
                cServer.drugZones[drug].levelPriceGain = cServer.drugZones[drug].levelPriceGain + cServer.drugZones[drug].levelPriceGain
            end
 
            if DrugReputation[drug] and DrugLevel[drug] > Drugs.Info[drug].level.maxLvl then
                DrugLevel[drug] = Drugs.Info[drug].level.maxLvl
                Player.Functions.SetDrugLevel(drug, Drugs.Info[drug].level.maxLvl)
                cServer.drugZones[drug].levelPriceGain = cServer.drugZones[drug].levelPriceGain * Drugs.Info[drug].level.maxLvl
                return
            end
        end
    end 
end)

RegisterNetEvent("qb-drugs:Server:handleDrugSales", function(canSell, drug, zone) -- Drug Sales System
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = math.random(Drugs.Selling[drug].sellForMin, Drugs.Selling[drug].sellForMax) + cServer.drugZones[zone].levelPriceGain
    local removeA = math.random(Drugs.Selling[drug].removeMin, Drugs.Selling[drug].removeMax)
    local XP = math.random(Drugs.Selling[drug].xpMin, Drugs.Selling[drug].xpMax)
    local chance = math.random(1, 100)
    local hasDrugs = Player.Functions.GetItemByName(drug)
    if not drug or not canSell or not amount then DropPlayer(src, "[DRUGS] Detect an event being called without correct parms. This has been logged") return end 
    if hasDrugs and hasDrugs.amount > 0 then 
        if Drugs.Selling[drug].callPoliceChance >= chance then 
            Player.Functions.RemoveItem(drug, removeA)
            Player.Functions.AddMoney('cash', amount)
            TriggerClientEvent('QBCore:Notify', source, "You've successfully sold some " .. drug .. " for $" .. amount, "success")
            TriggerClientEvent('QBCore:Notify', source, "You gained " .. XP .. " reputation for this sale", "success")
            TriggerEvent("qb-drugs:Server:UpdateReputation", zone, XP, src)
        else
            -- Call Police
        end
    end
end)

RegisterNetEvent("qb-drugs:Server:methTableHandling", function(cont, success)
    if not cont or not success then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem('methbaggy', 1)
end)

RegisterNetEvent("qb-drugs:Server:callPolice", function(reason, coords)
    local alertData = {
        title = "10-28 | Drug Call",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Drug Processing has been reported in the area"
    }
    TriggerClientEvent("qb-drugs:Client:callPolice", -1, reason, coords)
    TriggerClientEvent("qb-phone:client:addPoliceAlert", -1, alertData)
end)

RegisterNetEvent("qb-drugs:Server:checkDrugsPlayer", function(drug, drugType) -- Check if player has drugs to sell
    if not drug or not drugType then return end
    local src = source 
    local Player = QBCore.Functions.GetPlayer(src)
    for k, v in pairs(drugType) do
        if Player.Functions.GetItemByName(v) then 
            if Player.Functions.GetItemByName(v).amount > 0 then 
                TriggerClientEvent("qb-drugs:Client:setDrugStatus", src, true)
                return 
            end
        else
            TriggerClientEvent("qb-drugs:Client:setDrugStatus", src, false)
            return 
        end
    end
end)

RegisterNetEvent("qb-drugs:Server:activateCooldown", function() -- Activate the cooldown
    local src = source 

    if not Drugs.npcCooldown then 
        Drugs.npcCooldown = true
    end 

    Wait((cServer.cooldown * 1000) * 60)
    Drugs.npcCooldown = false
end)
