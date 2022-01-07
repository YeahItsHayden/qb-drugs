-- Made by Hayden#6789
local QBCore = exports['qb-core']:GetCoreObject() -- Core Object
local Skillbar = exports['qb-skillbar']:GetSkillbarObject() -- Skillbar Object
local PlayerData = {}
local hasDrugs = false
local checkedForDrugs = false
-- Coke Tables
local cokeHarvestBlips = {}
local cokeAlreadyPicked = {}
local cokeProcessingTable = {}
-- Drug Table 
local soldToPed = {} -- Table to handle peds that have had drugs sold to them 

RegisterCommand("placeMeth", function() 
    TriggerEvent("qb-drugs:Client:methTableHandling")
end, false)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job
end)  

CreateThread(function()
    while not config do 
        Wait(500)
        QBCore.Functions.TriggerCallback("qb-drugs:Server:grabServerConfig", function(cServer)
            config = cServer
            return config
        end)
    end

    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply)

    -- Tables for QB-menu
    local exitCokeProcessing = {} 
    local enterCokeProcessing = {}
    local cokeProcessingArea = {}

    local cayoPerico = PolyZone:Create({ -- Cayo Perico Island
        vector2(3821.7133789062, -4678.34375),
        vector2(4190.5952148438, -4302.21484375),
        vector2(4760.2236328125, -4275.6416015625),
        vector2(5015.5004882812, -4376.103515625),
        vector2(5081.0991210938, -4474.0053710938),
        vector2(5246.53515625, -4633.189453125),
        vector2(5681.2924804688, -5226.357421875),
        vector2(5572.6577148438, -6078.2177734375),
        vector2(4807.5244140625, -6029.2802734375),
        vector2(4747.4643554688, -5981.798828125)
        }, {
        name="Cayo Perico",
        minZ = 0.1267392635345,
        maxZ = 80.519729614258
    })

    if not config.processCokeLocationChange then
        cokeProcessing = CircleZone:Create(config.processCokeLocations, 2.0, {
            name="cokeProcessing",
            useZ=false,
        })
    else
        local max = #config.processCokeLocations
        local random = math.random(1, max)
        cokeProcessingTable[#cokeProcessingTable+1] = { id = random }
        cokeProcessing = CircleZone:Create(config.processCokeLocations[random], 2.0, {
            name="cokeProcessing",
            useZ=false,
        })
    end

    leaveCokeProcessing = CircleZone:Create(config.leaveCokeLab, 2.0, {
        name="leaveCokeProcessing",
        useZ=false,
    })

    cokeProcessingZone = CircleZone:Create(config.cokeProcess, 2.0, {
        name="cokeProcessingarea",
        useZ=false,
    })
        
    exitCokeProcessing[#exitCokeProcessing+1] = {
        header = "Leave Building?",
        params = {
            event = 'qb-drugs:Client:labHandling',
            args = {
                leaving = true,
                lab = 'coke', 
            }
        }
    }

    enterCokeProcessing[#enterCokeProcessing+1] = {
        header = "Enter Building?",
        params = {
            event = 'qb-drugs:Client:labHandling',
            args = {
                canEnter = true,
                lab = 'coke', 
            }
        }
    }

    cokeProcessingArea[#cokeProcessingArea+1] = {
        header = "Process Coke?",
        params = {
            event = 'qb-drugs:Client:processDrugs',
            args = {
                drug = "coke",
                process = "cocaleaves",
            }
        }
    }

    cokeProcessingZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
        if isPointInside then
            exports['qb-menu']:showHeader(cokeProcessingArea)
        else
            exports['qb-menu']:closeMenu()
        end
    end)

    cokeProcessing:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
        if isPointInside then
            exports['qb-menu']:showHeader(enterCokeProcessing)
        else
            exports['qb-menu']:closeMenu()
        end
    end)

    leaveCokeProcessing:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
        if isPointInside then
            exports['qb-menu']:showHeader(exitCokeProcessing)
        else
            exports['qb-menu']:closeMenu()
        end 
    end)
    
    cayoPerico:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
        if isPointInside then
            local max = #config.startMissionNPC
            local random = math.random(1, max)

            RequestModel(Drugs.npcMissionModel)
            print(random)
            while not HasModelLoaded(Drugs.npcMissionModel) do
                Wait(10) 
            end

            missionNPCModel = CreatePed(1, Drugs.npcMissionModel, config.startMissionNPC[random], false, true)
            SetBlockingOfNonTemporaryEvents(missionNPCModel, true)
            FreezeEntityPosition(missionNPCModel, true)
            SetPedDiesWhenInjured(missionNPCModel, false)
            SetEntityInvincible(missionNPCModel, true)

            exports['qb-target']:AddEntityZone("npcMissionHandler", missionNPCModel, {
                name = "npcMissionHandler",
                debugPoly = false
            }, {
                distance = 2.0,
                options = {
                    {
                        type = "client",
                        event = "qb-drugs:Client:npcHandling",
                        icon = 'fas fa-comments',
                        label = 'Talk to NPC',
                    }
                }
            })
        else
            exports['qb-target']:RemoveTargetEntity(missionNPCModel)
            SetEntityAsNoLongerNeeded(missionNPCModel)
            DeletePed(missionNPCModel)
            
        end
    end)
end)

CreateThread(function()
    while not config do 
        Wait(0)
        QBCore.Functions.TriggerCallback("qb-drugs:Server:grabServerConfig", function(cServer)
            config = cServer
            return config
        end)
    end

    while true do 
        Wait(1)
        local nearSelling = false 
        local canSell, drug, drugType, zone = isInsideSellingZone()
        if canSell then
            nearSelling = true   
            if not IsPedInAnyVehicle(PlayerPedId()) or not IsPedDeadOrDying(PlayerPedId()) then
                ent = getPedPlayerIsLookingAt()
            end
            if not IsPedDeadOrDying(ent) and not IsPedInAnyVehicle(ent) then 
                local eT = GetPedType(ent)
                local entPos = GetEntityCoords(ent)
                if eT ~= 28 and not IsPedAPlayer(ent) and not hasValue(soldToPed, ent) then
                    if not checkedForDrugs then 
                        TriggerServerEvent("qb-drugs:Server:checkDrugsPlayer", drug, drugType)
                        checkedForDrugs = true
                    end 
                    if hasDrugs then
                        DrawText3Ds(entPos.x, entPos.y, entPos.z, "[~r~E~w~] to offer drugs")
                        if IsControlJustPressed(0, 38) then 
                            startDrugSale(canSell, drugType, ent, zone)
                            checkedForDrugs = false
                        end
                    else
                        Wait(1000)
                    end
                end
            end
        end
        if not nearSelling then 
            Wait(1000)
        end
    end
end)

RegisterNetEvent("qb-drugs:Client:startMissionClient", function(data) -- Handles most data for missions
    price = data.price
    if not data.start then QBCore.Functions.Notify("Cya then", "error") return end
    TriggerEvent("qb-drugs:Client:checkMissionStatus", data.drug) 
    if doingMission then QBCore.Functions.Notify("You're already doing a mission for me", "error") return end 
    
    if data.drug == "coke" then -- Coke Mission 
        QBCore.Functions.TriggerCallback("qb-drugs:Server:checkCooldownStatus", function(cooldown) 
            if cooldown then QBCore.Functions.Notify("This mission is currently on cooldown", "error") return end -- Cooldown error 
        end, data.drug)

        QBCore.Functions.TriggerCallback("qb-drugs:Server:canStartMission", function(canStart)
            if not canStart then QBCore.Functions.Notify("You don't have enough money to start the mission", "error") return end
        end, price)

        local max = #config.harvestCokeLocations
        local random = math.random(1, max)

        QBCore.Functions.Notify("I've marked some locations on your map, go to them to harvest coca leaves", "success")
        
        for i = 1, #config.harvestCokeLocations[random] do 
            createBlip(config.harvestCokeLocations[random][i], 143, 4, 1.0, 5, false, "Harvest Location " .. i)
            cokeHarvestBlips[#cokeHarvestBlips+1] = {id = i, coords = config.harvestCokeLocations[random][i], blipID = blip}
        end

        while true do
            Wait(1)
            for i = 1, #config.harvestCokeLocations[random] do
                local plyCoords = GetEntityCoords(PlayerPedId())
                local harvestCoords = config.harvestCokeLocations[1][i] 
                if #(plyCoords - harvestCoords) < 5 then 
                    local closeToPlantWithId = i
                    if not hasValue(cokeAlreadyPicked, closeToPlantWithId) then -- I can only think of this way, my brain is smol
                        DrawText3Ds(config.harvestCokeLocations[random][closeToPlantWithId].x, config.harvestCokeLocations[random][closeToPlantWithId].y, config.harvestCokeLocations[random][closeToPlantWithId].z, "[~r~E~w~] To Harvest")
                        DrawMarker(2, config.harvestCokeLocations[random][closeToPlantWithId].x, config.harvestCokeLocations[random][closeToPlantWithId].y, config.harvestCokeLocations[random][closeToPlantWithId].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                    end 
                    if #(plyCoords - harvestCoords) < 2.5 then
                        if IsControlJustReleased(0, 38) then
                            for k, v in pairs(cokeHarvestBlips) do
                                if v.id == closeToPlantWithId then
                                    DoesBlipExist(v.blipID)
                                    RemoveBlip(v.blipID)
                                    startPickingDrug(closeToPlantWithId, 'coke')
                                end
                            end 
                        end
                    end
                end
            end
        end
    elseif data.drug == "opium" then -- Opium Mission

    end
end)

RegisterNetEvent("qb-drugs:Client:checkMissionStatus", function(action) -- checks mission status
    if action == 'coke' then 
        if next(cokeHarvestBlips) then 
            doingMission = true 
        else 
            doingMission = false
        end
    end 
end)

RegisterNetEvent("qb-drugs:Client:labHandling", function(data) -- Handles lab entering 
    local ply = PlayerPedId()

    if data.canEnter then
        if data.lab == 'coke' then 
            SetEntityCoords(ply, config.cokeLab, 0, 0, 1)
            SetEntityHeading(ply, 178.04)
        end
    end 

    if data.leaving then 
        if data.lab == 'coke' then 
            if not config.processCokeLocationChange then
                SetEntityCoords(ply, config.processCokeLocations)
            else
                SetEntityCoords(ply, config.processCokeLocations[random])
            end
        end
    end
end)

RegisterNetEvent("qb-drugs:Client:mapHandling", function() -- Handles using the map item
    if showingMapCoords then
        DoesBlipExist(cokeBlip)
        RemoveBlip(cokeBlip)
        showingMapCoords = false
        QBCore.Functions.Notify('The locations have been removed!', 'success')
    else
        if not config.processCokeLocationChange then 
            cokeBlip = AddBlipForCoord(config.processCokeLocations)
            SetBlipSprite(cokeBlip, 89)
            SetBlipAsShortRange(cokeBlip, false)
            SetBlipScale(cokeBlip, 0.8)
            SetBlipColour(cokeBlip, 0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Coke Processing")
            EndTextCommandSetBlipName(cokeBlip)
            showingMapCoords = true
            QBCore.Functions.Notify('The map shows a potential drug location on your map, check it!', 'success')
        else
            for _, v in pairs(cokeProcessingTable) do 
                cokeBlip = AddBlipForCoord(config.processCokeLocations[v.id])
                SetBlipSprite(cokeBlip, 89)
                SetBlipAsShortRange(cokeBlip, false)
                SetBlipScale(cokeBlip, 0.8)
                SetBlipColour(cokeBlip, 0)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Coke Processing")
                EndTextCommandSetBlipName(cokeBlip)
                showingMapCoords = true
                QBCore.Functions.Notify('The map shows a potential drug location on your map, check it!', 'success')
            end
        end
    end
end)

RegisterNetEvent("qb-drugs:Client:npcHandling", function() -- Handles mission NPC Dialog 
    drugsTable = Drugs.Info

    local missionMenu = {
        {
            header = "Hey there, I've got some jobs for you, pick your favourite one below",
            isMenuHeader = true,
        },
    }

    for k, v in pairs(drugsTable) do 
        missionMenu[#missionMenu + 1] = {
            header = k,
            txt = "This will cost $" .. drugsTable[k].startPrice .. " to start",
            params = {
                event = "qb-drugs:Client:startMissionClient",
                args = {
                    start = true,
                    drug = k,
                    price = drugsTable[k].startPrice,
                }
            }
        }
    end
    exports["qb-menu"]:openMenu(missionMenu)
end)

RegisterNetEvent("qb-drugs:Client:processDrugs", function(data) -- Handles drug processing
    QBCore.Functions.TriggerCallback("qb-drugs:Server:canProcessDrugs", function(canProcess)
        if data.drug == 'coke' then
            if not canProcess then QBCore.Functions.Notify("You don't have enough coca leaves to process", "error") return end

            local ply = PlayerPedId()
            local dict = "anim@amb@business@coc@coc_unpack_cut_left@"

            if not HasAnimDictLoaded(dict) then
                RequestAnimDict(dict)

                while not HasAnimDictLoaded(dict) do
                    Wait(4)
                end
            end

            TaskPlayAnim(ply, dict, "coke_cut_v5_coccutter", 8.0, -8.0, -1, 1, 0, false, false, false)
            RemoveAnimDict(dict)

            Skillbar.Start({
                duration = math.random(2000, 5000),
                pos = math.random(20, 100),
                width = math.random(5, 20),
            }, function() -- succeeded
                ClearPedTasks(ply)
                TriggerServerEvent("qb-drugs:Server:itemHandling", "remove", "cocaleaves", 2)
                TriggerServerEvent("qb-drugs:Server:itemHandling", "add", "purecoke", 1)
                QBCore.Functions.Notify("Successfully processed leaves into pure coke", "success")
            end, function() -- failed
                ClearPedTasks(ply)
                TriggerServerEvent("qb-drugs:Server:itemHandling", "remove", "cocaleaves", 2)
                QBCore.Functions.Notify("You failed the processing, some of your leaves were destroyed in the process", "error")
            end)
        end
    end, data.drug, data.process)
end)

RegisterNetEvent("qb-drugs:Client:useDrugBag", function() -- Handles drug packaging 
    local drugPackaging = {
        {
            header = "What drug would you like to package?",
            isMenuHeader = true,
        },
    }

    for k, v in pairs(Drugs.Packaging) do 
        drugPackaging[#drugPackaging + 1] = {
            header = v.itemName,
            txt = "To package " .. v.itemName .. " into " .. v.turnsInto .. " you'll require " .. v.requires .. " " .. v.itemName,
            params = {
                event = "qb-drugs:Client:itemPackageHandling",
                args = {
                    drug = k,
                }
            }
        }
    end
    exports["qb-menu"]:openMenu(drugPackaging)
end)

RegisterNetEvent("qb-drugs:Client:itemPackageHandling", function(data)
    if not data then return end
    Skillbar.Start({
        duration = math.random(2000, 5000),
        pos = math.random(20, 50),
        width = math.random(5, 20),
    }, function() -- succeeded
        ClearPedTasks(ply)
        TriggerServerEvent("qb-drugs:Server:itemPackageHandling", data.drug)
    end, function() -- failed
        ClearPedTasks(ply)
        TriggerServerEvent("qb-drugs:Server:itemHandling", "remove", data.drug, math.random(1,2))
        QBCore.Functions.Notify("You dropped some material, you've lost some of the drug in the process", "error")
    end)
end)

RegisterNetEvent("qb-drugs:Client:setDrugStatus", function(value)
    hasDrugs = value
end)

RegisterNetEvent("qb-drugs:Client:methTableHandling", function()
    local continue = false
    exports['qb-drawtext']:DrawText("Press E to place object","right")            
    while true do
        local mTable = rayPlacement() 
        if mTable then 
            local objHash = Drugs.methTable.tableProp
            local curObject = CreateObject(objHash, mTable, false, false, false)
            Wait(0)
            SetModelAsNoLongerNeeded(curObject)
            SetEntityCollision(curObject, false, false)
            SetEntityCompletelyDisableCollision(curObject, false, false)
            SetEntityAlpha(curObject, 255, false)
            DeleteObject(curObject)
            if IsControlJustReleased(0, 38) then
                methTableObject = CreateObject(objHash, mTable, false, false, false)
                exports['qb-drawtext']:HideText()
                continue = true
                break 
            end
        end 
    end
    
    if continue then -- stuff
       -- methAnimation()
        FreezeEntityPosition(PlayerPedId(), true)
        Skillbar.Start({
            duration = math.random(2000, 5000),
            pos = math.random(20, 50),
            width = math.random(5, 20),
        }, function() -- succeeded
            local chance = math.random(1, 100)

            if Drugs.methTable.chanceOfExplosion >= chance then
                while not RequestScriptAudioBank("BIG_SCORE_GOLD_VAULT_EXPLOSION", 0) do 
                    Wait(0)
                    RequestScriptAudioBank("BIG_SCORE_GOLD_VAULT_EXPLOSION", 0)
                end 
                PlaySoundFromEntity(-1, "Gold_Vault_Explosions", methTableObject, 'BIG_SCORE_3B_SOUNDS', 1, 1)
                
                while not HasNamedPtfxAssetLoaded("core") do -- This don't work :/ 
                    Wait(0)
                    RequestNamedPtfxAsset("core")
                end
                local particle = StartNetworkedParticleFxLoopedOnEntity("exp_grd_petrol_pump", methTableObject, vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, 0.0), 1.0, vec3(0.0, 0.0, 0.0))
                SetParticleFxLoopedEvolution(particle, "core", 0.0, 0) -- No work
                SetEntityAsNoLongerNeeded(methTableObject)
                DeleteObject(methTableObject)
                SetEntityHealth(PlayerPedId(), 1)
                ExplodePedHead(PlayerPedId())
                QBCore.Functions.Notify("The processing failed and you exploded, have fun explaining this to EMS", "error")
                FreezeEntityPosition(PlayerPedId(), false)
            else     
                ClearPedTasks(ply)
                TriggerServerEvent("qb-drugs:Server:methTableHandling")
                QBCore.Functions.Notify("Successfully processed leaves into pure coke", "success")
                FreezeEntityPosition(PlayerPedId(), false)
            end
        end, function() -- failed
            ClearPedTasks(ply)
            QBCore.Functions.Notify("You failed the processing, some of your leaves were destroyed in the process", "error")
        end)
    end
end)

function isInsideSellingZone() -- Functions to check if inside selling zone
    local plyCoords = GetEntityCoords(PlayerPedId())
    for k, v in pairs(config.drugZones) do                
        local drugCoords = config.drugZones[k].coords
        local drugType = config.drugZones[k].canSell
        local zone = k
        if #(plyCoords - drugCoords) < config.drugZones[k].radius then           
            return true, k, drugType, zone
        else 
            return false, k, drugType, zone
        end
    end
end

function getPedPlayerIsLookingAt() -- Raytracing to return entity player is looking at 
	local plyPos = GetEntityCoords(PlayerPedId())
	local plyOffset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.3, 0.0)
	local rH = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, PlayerPedId(), 7)
	local _, _, _, _, ent = GetShapeTestResult(rH)
	return ent
end

function startDrugSale(canSell, drugType, ent, zone) -- Function for the drug sale
    if not canSell or not drugType or not ent then return end 

    RequestAnimDict("mp_safehouselost@")
    while (not HasAnimDictLoaded("mp_safehouselost@")) do Wait(0) end

    drugProp = CreateObject(`prop_drug_package_02`, 0, 0, 0, true, true, true) 
    AttachEntityToEntity(drugProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, 0.0, -0.03, 135.0, -100.0, 40.0, true, true, false, true, 1, true)
    TaskPlayAnim(PlayerPedId(),"mp_safehouselost@","package_dropoff",100.0, 200.0, 0.3, 120, 0.2, 0, 0, 0)
    FreezeEntityPosition(PlayerPedId(), true)
    Wait(750)
    StopAnimTask(PlayerPedId(), "mp_safehouselost@","package_dropoff", 1.0)
    DeleteEntity(drugProp)   
    FreezeEntityPosition(PlayerPedId(), false)

    for k, v in pairs(drugType) do
        if v then 
            TriggerServerEvent("qb-drugs:Server:handleDrugSales", canSell, v, zone)
            soldToPed[#soldToPed+1] = ent
            SetEntityAsNoLongerNeeded(ent)
        end
    end
end

function startPickingDrug(id, drug) -- Handling the picking of drugs
    local ply = PlayerPedId()
    if not drug then return end
    if drug == 'coke' then 
        local dict = "mini@repair"

        if not HasAnimDictLoaded(dict) then
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Wait(4)
            end
        end

        TaskPlayAnim(ply, dict, "fixing_a_ped", 8.0, -8.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(dict)

        Wait(Drugs.Info['coke'].pickTime * 1000)

        ClearPedTasks(ply) 
        TriggerServerEvent("qb-drugs:Server:itemHandling", "add", "cocaleaves", math.random(1,3))
        cokeAlreadyPicked[#cokeAlreadyPicked+1] = id
        table.removebyKey(cokeHarvestBlips, id)
        TriggerEvent("qb-drugs:Client:checkMissionStatus") 

        if not next(cokeHarvestBlips) then 
            QBCore.Functions.Notify("You've picked all of the coca currently available!", "success")
            Wait(2000)
            QBCore.Functions.Notify("You'll need to find where to process this from here", "success")
            cokeAlreadyPicked = {}
            if Drugs.enablenpcCooldown then 
                TriggerServerEvent("qb-drugs:Server:activateCooldown")
            end
        end
    end 
end

function createBlip(coords, sprite, display, scale, colour, shortRange, title) -- function for making blips 
    blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, display)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, shortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(title)
    EndTextCommandSetBlipName(blip)
end

function getCoordsFromCam(distance, coords)
    local rotation = GetGameplayCamRot()
    local adjustedRotation = vec3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vec3(-math.sin(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.cos(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.sin(adjustedRotation[1]))
    return vec3(coords[1] + direction[1] * distance, coords[2] + direction[2] * distance, coords[3] + direction[3] * distance)
end

function rayPlacement() -- RayTracing for placement of prop
    local Cam = GetGameplayCamCoord()
    local _, _, coords, _, _ = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(Cam, getCoordsFromCam(10.0, Cam), -1, PlayerPedId(), 4))
    return coords
end