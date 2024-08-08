fx_version 'cerulean'
game 'gta5'

author 'jan Xeaks scripts'
description 'Simple weapon store script. Made for Xeaks scripts.'
version '1.0'
lua54 'yes'

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
}

client_script 'src/client/*.lua'
server_script 'src/server/*.lua'
shared_script 'shared/*.lua'