local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("illegalmap", function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	if Player.Functions.GetItemByName(item.name) then
		TriggerClientEvent("qb-drugs:Client:mapHandling", src)
	end
end)

QBCore.Functions.CreateUseableItem("drug_baggy", function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	if Player.Functions.GetItemByName(item.name) then
		TriggerClientEvent("qb-drugs:Client:useDrugBag", src)
	end
end)

QBCore.Functions.CreateUseableItem("meth_table", function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

	if Player.Functions.GetItemByName(item.name) then
		TriggerClientEvent("qb-drugs:Client:methTableHandling", src)
	end
end)

-- This is straight from the QBCore Small Resources section, I just added it into the script as it makes more sense

QBCore.Functions.CreateUseableItem("joint", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("qb-drugs:Client:useJoint", src)
    end
end)

QBCore.Functions.CreateUseableItem("cokebaggy", function(source, item)
    local src = source
    TriggerClientEvent("qb-drugs:Client:useCokebaggy", src)
end)

QBCore.Functions.CreateUseableItem("crack_baggy", function(source, item)
    local src = source
    TriggerClientEvent("qb-drugs:Client:useCrackbaggy", src)
end)

QBCore.Functions.CreateUseableItem("xtcbaggy", function(source, item)
    local src = source
    TriggerClientEvent("qb-drugs:Client:useEcstasyBaggy", src)
end)

QBCore.Functions.CreateUseableItem("oxy", function(source, item)
    local src = source
    TriggerClientEvent("qb-drugs:Client:useoxy", src)
end)

QBCore.Functions.CreateUseableItem("meth", function(source, item)
    local src = source
    TriggerClientEvent("qb-drugs:Client:usemeth", src)
end)