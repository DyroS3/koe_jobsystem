fx_version 'adamant'
game 'gta5'
version '1.0.0'
lua54 'yes'

client_scripts {
	'config.lua',
	'client.lua'
 }
 
 server_scripts {
	'config.lua',
	'@mysql-async/lib/MySQL.lua',
	'server.lua'
 }

 shared_script '@ox_lib/init.lua'