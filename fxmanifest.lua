fx_version 'cerulean'
game 'gta5'
author 'Neon'
description 'Neon-Garage'
ui_page {
	'html/index.html',
}

files {
	'html/*.css',
	'html/*.js',
	'html/*.html',
	'html/*.ogg',
	'html/images/*.png',
	'html/images/*.svg',
}

shared_script{
	'config.lua',
}

dependencies {
	'/server:5104',
	'/gameBuild:1868',
	'/onesync',
	'qb-core',
	'oxmysql',
}

client_scripts {
	'GetFrameworkObject.lua',
	'client/*.lua',
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'GetFrameworkObject.lua',
	'server/*.lua',
}

lua54 'yes'
