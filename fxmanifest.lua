fx_version 'cerulean'
game 'gta5'

author 'jan Xeaks scripts'
description 'Simple weapon store script. Made for Xeaks scripts.'
version '1.1'
lua54 'yes'

files {
    'locales/en.json',
    'locales/nl.json',
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_script 'src/client/main.lua'
server_script 'src/server/main.lua'
shared_script 'shared/config.lua'