fx_version 'adamant'
game 'gta5'

author 'Code Service'
name 'cs_advent'
version '1.0'

lua54 "yes"

escrow_ignore {
	'config/translations.lua',
    'config/shared.lua',
    'config/config_c.lua',
    'config/config_sv.lua',
    'config/webhook.lua',
}

shared_scripts {
	'config/translations.lua',
    'config/shared.lua',
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'config/config_sv.lua',
    'config/webhook.lua',
	'server/**/*.*',
}

client_scripts {
    'config/config_c.lua',
	'client/**/*.*',
}

ui_page 'html/index.html'

files {
	"html/**/*.*",
    "ped.meta",
}

data_file "PED_METADATA_FILE" "ped.meta"

dependencies {
    'oxmysql',
}