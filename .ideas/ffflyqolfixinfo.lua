name = "Friendly Fruit Fly no Unloading & Collision QoL"
description = "Fixes the Friendly Fruit Fly unloading when far away + other QoL features.\n\nUnloading, Collision, and plant/till Blocking tweaks Enabled by default.\n\nOriginally by Electroely, I just fixed a crash issue."
author = "Electroely"
version = "1.4c"
forumthread = "/"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
client_only_mod = false
all_clients_require_mod = false
server_only_mod = true
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
api_version = 10

configuration_options = {
	{
		name = "sleeping",
		label = "Remove Unloading",
		hover = "\"Yes\" will allow the Friendly Fruit Fly to work even with no players nearby.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = true,
	},
	{
		name = "collision",
		label = "Remove Collision",
		hover = "\"Yes\" will allow the fruit fly to fly through other entities, such as players.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = true,
	},
	{
		name = "blocking",
		label = "Remove Blocking",
		hover = "\"Yes\" will allow tilling soil/planting seeds near the Friendly Fruit Fly.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = true,
	},
	{
		name = "regen",
		label = "Add Health Regen",
		hover = "\"Yes\" will give the Friendly Fruit Fly passive health regeneration.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = false,
	},
	{
		name = "sounds",
		label = "Remove Sounds",
		hover = "Mute the sounds of the Friendly Fruit Fly.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = false,
	},
	
}name = "Friendly Fruit Fly no Unloading & Collision QoL"
description = "Fixes the Friendly Fruit Fly unloading when far away + other QoL features.\n\nUnloading, Collision, and plant/till Blocking tweaks Enabled by default.\n\nOriginally by Electroely, I just fixed a crash issue."
author = "Electroely"
version = "1.4c"
forumthread = "/"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
client_only_mod = false
all_clients_require_mod = false
server_only_mod = true
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
api_version = 10

configuration_options = {
	{
		name = "sleeping",
		label = "Remove Unloading",
		hover = "\"Yes\" will allow the Friendly Fruit Fly to work even with no players nearby.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = true,
	},
	{
		name = "collision",
		label = "Remove Collision",
		hover = "\"Yes\" will allow the fruit fly to fly through other entities, such as players.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = true,
	},
	{
		name = "blocking",
		label = "Remove Blocking",
		hover = "\"Yes\" will allow tilling soil/planting seeds near the Friendly Fruit Fly.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = true,
	},
	{
		name = "regen",
		label = "Add Health Regen",
		hover = "\"Yes\" will give the Friendly Fruit Fly passive health regeneration.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = false,
	},
	{
		name = "sounds",
		label = "Remove Sounds",
		hover = "Mute the sounds of the Friendly Fruit Fly.",
		options = {
			{description="Yes",data=true},
			{description="No",data=false},
		},
		default = false,
	},
	
}