name = "Farming QoL & Tweaks"
description = [[
Giant Crops don't fly when you pick them,
Friendly Fruit Flies working (not unloading) when you're away,
Waterfowl Can refillable by sea,
Hammerless Harvest,
Up to 20 Friendly Fruit Flies,
and more!

This mod is configurable and compatible with most mods.

Enjoy!

Latest Patch Notes: Further improved mod compatibility by patching patchable functions instead of replacing them
]]

author = "Growth Mindset"

version = "1.1"

forumthread = ""

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

server_only_mod = true
client_only_mod = false
all_clients_require_mod = false

api_version = 10

local bannertweak = {{description = "", data = false,}} --needed for banners to work
configuration_options =
{
    {
		name = "banner1",
		label = "Friendly Fruit Fly",
		hover = "",
		options = bannertweak,
		default = false,
	},
    {
        name = "fffly_unloading_disabled",
        label = "Disable Unloading",
        hover = "Makes Friendly Fruit Flies able to work even when you're away or in caves!",
        options =
        {
            {description = "No", data = false},
			{description = "Yes", data = true},
        },
        default = true,
    },
    {
		name = "fffly_range",
		label = "Crop Tending Range",
		hover = "Extends Friendly Fruit Flies' tending range.",
		options =
		{
			{description = "1x", data = 1},
			{description = "1.5x", data = 1.5},
            {description = "2x", data = 2},
            {description = "3x", data = 3},
            {description = "4x", data = 4},
            {description = "5x", data = 5},
		},
		default = 1.5,
	},
    {
		name = "fffly_speed_multiplier",
		label = "Speed",
		hover = "Makes Friendly Fruit Fly fly faster",
		options =
		{
			{description = "1x", data = 1},
			{description = "2x", data = 2},
            {description = "3x", data = 3},
            {description = "4x", data = 4},
		},
		default = 2,
	},
    {
		name = "fffly_number_limit",
		label = "Many Friendly Fruit Flies",
		hover = "Change how many Friendly Fruit Flies a World can have before the Lord stops dropping Fruits.",
		options =
		{
			{description = "Off", data = 1},
			{description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
            {description = "11", data = 11},
            {description = "12", data = 12},
            {description = "13", data = 13},
            {description = "14", data = 14},
            {description = "15", data = 15},
            {description = "16", data = 16},
            {description = "17", data = 17},
            {description = "18", data = 18},
            {description = "19", data = 19},
            {description = "20", data = 20},
		},
		default = 1,
	},
    {
        name = "fffly_collision_disabled",
        label = "Disable Collision",
        hover = "Removes Friendly Fruit Flies' Collision.\nYes is strongly recommended if you have many friendly fruit flies.",
        options =
        {
            {description = "No", data = false},
			{description = "Yes", data = true},
        },
        default = false,
    },
    {
        name = "fffly_blocking_disabled",
        label = "Disable Placement Blocking",
        hover = "Disables Friendly Fruit Flies' Till/Plant Blocking when on the way.\nYes recommended when collision is Disabled. Else, you can't push 'em!.",
        options =
        {
            {description = "No", data = false},
			{description = "Yes", data = true},
        },
        default = false,
    },
    {
        name = "fffly_regen_enabled",
        label = "Enable Health Regen",
        hover = "Gives Friendly Fruit Flies 1HP/second regen :)",
        options =
        {
            {description = "No", data = false},
			{description = "Yes", data = true},
        },
        default = false,
    },
    {
        name = "fffly_muted",
        label = "Mute Friendly Fruit Fly",
        hover = "Disables Friendly Fruit Flies' sounds :(",
        options =
        {
            {description = "No", data = false},
			{description = "Yes", data = true},
        },
        default = false,
    },
    {
		name = "banner2",
		label = "Waterfowl Can",
		hover = "",
		options = bannertweak,
		default = false,
	},
    {
		name = "can_ocean_refill_wf",
		label = "Ocean Refill",
		hover = "Allows refilling of the Waterfowl Can from the ocean.",
		options =
		{
            {description = "No", data = false},
			{description = "Yes", data = true},
		},
		default = true,
	},
    {
		name = "cannot_burn_wf",
		label = "Non-Flammable",
		hover = "Makes the Waterfowl Can immune to fire.",
		options =
		{
            {description = "No", data = false},
			{description = "Yes", data = true},
		},
		default = true,
	},
    {
		name = "banner3",
		label = "Crops",
		hover = "",
		options = bannertweak,
		default = false,
	},
    {
		name = "fast_planting",
		label = "Fast Planting",
		hover = "Faster seed planting on tilled soil, as fast as planting trees, grass, etc.",
		options =
		{
            {description = "No", data = false},
			{description = "Yes", data = true},
		},
		default = true,
	},
    {
		name = "stable_giant_crops",
		label = "Giants Don't Fly When Picked",
		hover = "Makes Giant Crops stay on the same spot when you pick them.",
		options =
		{
            {description = "No", data = false},
			{description = "Yes", data = true},
		},
		default = true,
	},
    {
		name = "giant_crop_collision_size",
		label = "Giant Crop Collision Size",
		hover = "Changes picked Giant Crops collision size.\nWarning: This feature is not yet thoroughly bug tested!",
		options =
		{
			{description = "Original", data = 0.1},
            {description = "Smaller", data = -2},
			{description = "No Collision", data = -6},
		},
		default = 0.1,
	},
    {
		name = "hammerless_harvest",
		label = "Hammerless Harvest",
		hover = "Allows harvesting Giant Crops without hammers (you can still lift them).",
		options =
		{
            {description = "No", data = false},
			{description = "Yes", data = true},
		},
		default = true,
	},
}