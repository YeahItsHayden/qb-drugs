fx_version 'cerulean'
game 'gta5'

description 'Custom Drug System written for the QBCore Community'
author 'Hayden#6789'
version '1.0.0'

shared_script '**/sh_*.lua'
client_script {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '**/cl_*.lua'
}
server_script '**/sv_*.lua'

lua54 'yes'

-- TO DO
-- Police ALerts
-- More XP required to lvl up 
-- Test Drug Sales
-- Complete other drugs