Drugs = {}
Drugs.npcMissionModel = `a_m_y_skater_02` -- Model of NPC for coke mission

Drugs.enablenpcCooldown = false -- Turn on cooldown for missions?
Drugs.npcCooldown = false -- Don't touch this setting, touch the above one only


Drugs.Info = { -- Big table with all the drugs
    ['coke'] = {
        level = {
            start = 0, -- DO NOT TOUCH 
            repToLvl = 5, -- How much reputation to lvl up
            repToLvlAdd = 5, -- How much XP is added to the RepToLvl after lvl up - makes it harder to lvl up as you go
            maxLvl = 10, -- Max lvl 
        }, -- Don't touch
        missionDrug = true, -- Should this drug be shown at the mission NPC?
        pickTime = 10, -- Time to pick, in seconds
        effectTime = 10, -- Time in seconds a coke effect will go for
        startPrice = 2000, -- Cost to start the coke mission
    },
    ['meth'] = {
        level = {
            start = 0, -- DO NOT TOUCH 
            repToLvl = 5, -- How much reputation to lvl up
            repToLvlAdd = 5, -- How much XP is added to the RepToLvl after lvl up - makes it harder to lvl up as you go
            maxLvl = 10, -- Max lvl 
        }, -- Don't touch
        missionDrug = false, -- Should this drug be shown at the mission NPC?
        startPrice = 2500, -- AMount to start the mission
        sellForMin = 150, -- How much does the drug sell for min?
        sellForMax = 200, -- How much does the drug sell for max?
        removeMin = 1, -- How many drugs are removed on drug sale min
        removeMax = 2, -- How many drugs are removed on drug sale max
        xpMin = 5, -- How much XP is given at end of sale min
        xpMax = 10, -- How much XP is given at end of sale Max
        callPoliceChance = 5, -- Chance of police being called to sale (percentage, IE: 5 = 5%)
    },
    ['oxy'] = {
        level = {
            start = 0, -- DO NOT TOUCH 
            repToLvl = 5, -- How much reputation to lvl up
            repToLvlAdd = 5, -- How much XP is added to the RepToLvl after lvl up - makes it harder to lvl up as you go
            maxLvl = 10, -- Max lvl 
        }, -- Don't touch
        missionDrug = true, -- Should this drug be shown at the mission NPC?
        startPrice = 2500, -- Amount to start the mission
        sellForMin = 150, -- How much does the drug sell for min?
        sellForMax = 200, -- How much does the drug sell for max?
        removeMin = 1, -- How many drugs are removed on drug sale min
        removeMax = 2, -- How many drugs are removed on drug sale max
        xpMin = 5, -- How much XP is given at end of sale min
        xpMax = 10, -- How much XP is given at end of sale Max
        callPoliceChance = 5, -- Chance of police being called to sale (percentage, IE: 5 = 5%)
    },
    ['opium'] = {
        level = {
            start = 0, -- DO NOT TOUCH 
            repToLvl = 5, -- How much reputation to lvl up
            repToLvlAdd = 5, -- How much XP is added to the RepToLvl after lvl up - makes it harder to lvl up as you go
            maxLvl = 10, -- Max lvl 
        }, -- Don't touch
        missionDrug = true, -- Should this drug be shown at the mission NPC?
        startPrice = 2500, -- Amount to start the mission
        sellForMin = 150, -- How much does the drug sell for min?
        sellForMax = 200, -- How much does the drug sell for max?
        removeMin = 1, -- How many drugs are removed on drug sale min
        removeMax = 2, -- How many drugs are removed on drug sale max
        xpMin = 5, -- How much XP is given at end of sale min
        xpMax = 10, -- How much XP is given at end of sale Max
        callPoliceChance = 5, -- Chance of police being called to sale (percentage, IE: 5 = 5%)
    }
}

Drugs.Processing = { -- All of the processing elements
    ['cocaleaves'] = { -- Name of the item
        requires = 5, -- How many of above item are required to process into next drug
        turnsInto = 'purecoke' -- Name of the item the itemName will turn into
    }, 
}

Drugs.Packaging = { -- Drugs that can be packaged with drug_baggy
    ['purecoke'] = { -- ITEM NAME IN SHARED.LUA
        itemName = 'Pure Coke', -- Display Name 
        requires = 2, -- How many of above item are required to process into next drug
        turnsInto = 'cokebaggy', -- Name of the itme the itemName will turn into
        needs = 'drug_baggy', -- An Additional item that is required to turn it into a coke baggy
    }
}

Drugs.Selling = { -- all of the drug selling config
    ['cokebaggy'] = { -- Name of the drug in the shared.lua
        sellForMin = 150, -- How much does the drug sell for min?
        sellForMax = 200, -- How much does the drug sell for max?
        removeMin = 1, -- How many drugs are removed on drug sale min
        removeMax = 2, -- How many drugs are removed on drug sale max
        xpMin = 5, -- How much XP is given at end of sale min
        xpMax = 10, -- How much XP is given at end of sale Max
        callPoliceChance = 5, -- Chance of police being called to sale (percentage, IE: 5 = 5%)
    },
    ['coke_brick'] = { -- Name of the drug in the shared.lua
        sellForMin = 150, -- How much does the drug sell for min?
        sellForMax = 200, -- How much does the drug sell for max?
        removeMin = 1, -- How many drugs are removed on drug sale min
        removeMax = 2, -- How many drugs are removed on drug sale max
        xpMin = 5, -- How much XP is given at end of sale min
        xpMax = 10, -- How much XP is given at end of sale Max
        callPoliceChance = 5, -- Chance of police being called to sale (percentage, IE: 5 = 5%)
    }
}

Drugs.methTable = {
    tableProp = `v_ret_ml_tableb`,
    chanceOfExplosion = 20, -- Chance of explosion (in %)
    chanceToCallCops = 30, -- Chance for table to call police when processing
}

Drugs.Items = { -- These are the items that are checked when removing/adding items, it's for exploit reasons
    'cocaleaves',
    'joint',
    'cokebaggy',
    'crack_baggy',
    'xtcbaggy',
    'weed_brick',
    'coke_brick',
    'coke_small_brick', 
    'oxy',
    'meth',
    'purecoke',
}