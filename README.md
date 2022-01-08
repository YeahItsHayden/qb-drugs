# QBCore Drug System
This is a drug system I created for the QBCore Community. It contains the old weed growing system (as there was nothing wrong with that), alongside new drugs such as:
- Coke
- Crack
- Ecstasy
- Oxy
- Meth

## Installation
1) Remove The Coke Teleporters in qb-smallresources (line 89 in config file)
2) Add the following into your shared.lua (core)
```
['illegal-map'] = {['name']='illegal-map',['label'] = 'Weird Map',['weight'] = 1,['type'] = 'item',['image'] = 'map.png',['unique'] = true,['useable'] = true,['shouldClose'] = true,['combinable']=nil,['description']='A map that could be useful'},

['cocaleaves'] 				 	 = {['name'] = 'cocaleaves',					['label'] = 'Coke Leaves',				['weight'] = 0,			['type'] = 'item',		['image'] = '',							['unique'] = false,		['useable'] = false,		['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Coke Leaves, I wonder what these can make'},
['purecoke'] 				 	 = {['name'] = 'purecoke',					['label'] = 'Pure Coke',				['weight'] = 0,			['type'] = 'item',		['image'] = '',							['unique'] = false,		['useable'] = false,		['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'You should probably bag these'},
['drug_baggy'] 				 	 = {['name'] = 'drug_baggy',					['label'] = 'Drug Bag',				['weight'] = 0,			['type'] = 'item',		['image'] = '',							['unique'] = false,		['useable'] = false,		['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A small drug bag, perfect for pure coke'},
['meth_table'] 				 	 = {['name'] = 'meth_table',					['label'] = 'Meth Table',				['weight'] = 0,			['type'] = 'item',		['image'] = '',							['unique'] = false,		['useable'] = true,		['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A very cool meth table'},
['puremeth'] 					 = {['name'] = 'puremeth', 						['label'] = 'Pure Meth', 				['weight'] = 5, 		['type'] = 'item', 		['image'] = '', 			['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Pure Meth, maybe a table might help you with this'},

```

## Features 
Missions:
    - An NPC is spawned on Cayo Perico when you enter the island. If you find this NPC you can then start a drug mission with complete configurable locations. 

Drug Effects for all items: 
    - All drugs have specific effects and perks that allow you to add more realism to your server (these effects were always there within the qb-smallresources, however, I just incorporated them into this script)

Meth Table:
    - Meth Tables are used to create meth. These tables have a random chance of exploding on use.

## Dependencies 
This requires the Cayo Perico Island for Coke to function

[qb-drawtext](https://github.com/idrisdose/qb-drawtext)

## Credits
Thank you to the QBCore community for giving me ideas, and for others helping me find shorter ways of doing this. 