require('archer_wars')
require('timers')
require('multiteam')
require('Heroes.arrow')
require('Heroes.locate')
require('itemabilities')

-- Load Stat collection (statcollection should be available from any script scope)
require('lib.statcollection')
statcollection.addStats({
	modID = 'cc535d721531d6e5aeaf3663bcc0baf4' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	--Ward
	PrecacheResource( "model", "models/items/wards/ward_bramble_snatch/ward_bramble_snatch.vmdl", context )
	PrecacheResource( "model", "models/heroes/beastmaster/beastmaster_bird.mdl", context )
	--Effect
	PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/storm_spirit/storm_spirit_orchid_hat/stormspirit_orchid_ball_sphere_arcs.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_wings_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/earth_spirit/earth_spirit_demonstone_summons/espirit_stoneremnant_base_demonstone.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap.vpcf", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_earth_spirit.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.ArcherWars = ArcherWarsGameMode()
	GameRules.ArcherWars:InitGameMode()
end