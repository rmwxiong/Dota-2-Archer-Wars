--ArcherWars

STARTING_GOLD = 0						-- How much gold each player starts with
KILLS_TO_WIN = 20						-- How many kills required to win

ENABLE_HERO_RESPAWN = true				-- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true				-- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true		-- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0				-- How long should we let people select their hero?
FIXED_RESPAWN_TIME = 4.0				-- How long should the respawn timer be for heroes?
PRE_GAME_TIME = 20.0					-- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 20.0					-- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 5.0					-- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 10						-- How much gold should players get per tick?
GOLD_AND_XP_TICK_TIME = 6				-- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = true		-- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1800.0		-- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1					-- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1				-- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1				-- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120					-- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = false		-- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false	-- Should we use a custom buyback time?
BUYBACK_ENABLED = false					-- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false		-- Should we disable fog of war entirely for both teams?
USE_STANDARD_DOTA_BOT_THINKING = false	-- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_FIXED_HERO_GOLD_BOUNTY = true		-- Should we give gold for hero kills by the units bounty values?

USE_CUSTOM_TOP_BAR_VALUES = false		-- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = false					-- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = false			-- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

REMOVE_ILLUSIONS_ON_DEATH = true		-- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false				-- Should we disable the gold sound when players get gold?

USE_CUSTOM_HERO_LEVELS = true			-- Should we allow heroes to have custom levels?
MAX_LEVEL = 12							-- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true				-- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Required XP per level
XP_PER_LEVEL_TABLE = {
	0, -- 1
	100, -- 2
	400, -- 3
	700, -- 4
	1000, -- 5
	1300, -- 6
	1600, -- 7
	1900, -- 8
	2200, -- 9
	2500, -- 10
	2800, -- 11
	3100  -- 12
}

ARCHERS = {}							-- Here we store all the heroes for each player
KILLS = {}								-- Score tracker
KILLS[0] = 0
KILLS[1] = 0
KILLS[2] = 0
KILLS[3] = 0
KILLS[4] = 0
KILLS[5] = 0
KILLS[6] = 0
KILLS[7] = 0
KILLS[8] = 0
KILLS[9] = 0

PLAYER_COLORS = {}						-- Hex values for all players where 0 is radiant and 1 is dire, rest are custom team 1-8
PLAYER_COLORS[0] = "2e6ae6"				-- Blue
PLAYER_COLORS[1] = "e67ab0"				-- Pink
PLAYER_COLORS[2] = "5de6ad"				-- Teal
PLAYER_COLORS[3] = "ad00ad"				-- Purple
PLAYER_COLORS[4] = "dcd90a"				-- Yellow
PLAYER_COLORS[5] = "e66200"				-- Orange
PLAYER_COLORS[6] = "92a440"				-- Green
PLAYER_COLORS[7] = "5cc5e0"				-- Light Blue
PLAYER_COLORS[8] = "00771f"				-- Dark Green
PLAYER_COLORS[9] = "956000"				-- Brown
PLAYER_COLORS2 = {}						-- RGB values for all players where 0 is radiant and 1 is dire, rest are custom team 1-8
PLAYER_COLORS2[0] = {R = 42, G = 106, B = 230}				-- Blue
PLAYER_COLORS2[1] = {R = 230, G = 122, B = 176}				-- Pink
PLAYER_COLORS2[2] = {R = 93, G = 230, B = 173}				-- Teal
PLAYER_COLORS2[3] = {R = 173, G = 0, B = 173}				-- Purple
PLAYER_COLORS2[4] = {R = 220, G = 217, B = 10}				-- Yellow
PLAYER_COLORS2[5] = {R = 230, G = 98, B = 0}				-- Orange
PLAYER_COLORS2[6] = {R = 146, G = 164, B = 64}				-- Green
PLAYER_COLORS2[7] = {R = 92, G = 197, B = 224}				-- Light Blue
PLAYER_COLORS2[8] = {R = 0, G = 119, B = 31}				-- Dark Green
PLAYER_COLORS2[9] = {R = 149, G = 96, B = 0}				-- Brown

if ArcherWarsGameMode == nil then
	ArcherWarsGameMode = class({})
end

function ArcherWarsGameMode:InitGameMode()
	ArcherWarsGameMode = self
	GameMode = GameRules:GetGameModeEntity()

	-- Normal income gives unreliable gold(now what we want)
	GameRules:SetGoldPerTick(0)
	GameRules:SetGoldTickTime(60)

	-- Setup Gamerules
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  	-- Hero Selection
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	-- Game Phases
	GameRules:SetPreGameTime( PRE_GAME_TIME )
	GameRules:SetPostGameTime( POST_GAME_TIME )
	-- Gameplay
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetRuneSpawnTime( RUNE_SPAWN_TIME )
	GameRules:SetUseBaseGoldBountyOnHeroes( USE_FIXED_HERO_GOLD_BOUNTY )
	-- Minimap
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )

	-- Camera Distance
	GameMode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
	-- Recomended Items
	GameMode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
	-- Hero Levels and XP
	GameMode:SetCustomHeroMaxLevel( MAX_LEVEL )
	GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	GameMode:SetUseCustomHeroLevels( USE_CUSTOM_HERO_LEVELS )
	GameMode:SetBuybackEnabled( BUYBACK_ENABLED )
	GameMode:SetFixedRespawnTime( FIXED_RESPAWN_TIME )

	GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
	
	GameRules:SetHideKillMessageHeaders(true)
	GameRules:SetFirstBloodActive(false)	-- Disables x2 first blood bonus
	GameRules:SetTimeOfDay(0)

	--[[self.m_GatheredShuffledTeams = {}
	self.m_PlayerTeamAssignments = {}
	self.m_NumAssignedPlayers = 0]]--

	-- Setup GameMode, and Initial Top Bar Values
	GameMode:SetTopBarTeamValuesOverride(true)
	GameMode:SetTopBarTeamValue(2, 0)
	GameMode:SetTopBarTeamValue(3, 0)

	-- Setup thinkState for later switching of thinkstates
	self.thinkState = Dynamic_Wrap(ArcherWarsGameMode, '_thinkState_PreGame')

	-- Setup game Hooks
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(ArcherWarsGameMode, 'LearnLocate'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(ArcherWarsGameMode, 'TeleportSpawn'), self)
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( ArcherWarsGameMode, 'OnGameRulesStateChange' ), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(ArcherWarsGameMode, 'UpdateScore'), self)

	self:RegisterCommands()

	MultiTeam:InitGameMode()

	GameMode:SetThink("Think", self, 0.25)

	print('ArcherWars Init Gamemode finished')
end

function ArcherWarsGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--self.AssignTeams()
	end
end

function ArcherWarsGameMode:Think()
	-- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
	local now = GameRules:GetGameTime()
	if ArcherWarsGameMode.t0 == nil then
		ArcherWarsGameMode.t0 = now
	end

	self:UpdateScoreboard()

	local dt = now - ArcherWarsGameMode.t0
	ArcherWarsGameMode.t0 = now

	ArcherWarsGameMode:thinkState( dt )
	return 0.25
end

function ArcherWarsGameMode:RegisterCommands()
	print('commands')
	--Convars:RegisterCommand('assigntoteams', function(),'Assign all players to teams.', FCVAR_CHEAT)
end

-- PreGame, runs during pre game time, so the doesn't start until it ends.
function ArcherWarsGameMode:_thinkState_PreGame()
	-- Check if game is still in pre game, or earlier state, if so do nothing.
	if GameRules:State_Get() <= DOTA_GAMERULES_STATE_PRE_GAME then
		return
	end
	GameRules:SendCustomMessage('<font color="#72C49E">Archer Wars</font>', 0, 0)
	GameRules:SendCustomMessage('First player to get <font color="#cb215d">' .. KILLS_TO_WIN ..'</font> kills win! GLHF!', 0, 0)
	EmitGlobalSound( "ui.npe_objective_given" )

	GameMode:SetThink("GiveXp", self, 6.0 )
	for npcId, v in pairs(ARCHERS) do
		ARCHERS[npcId]:RemoveModifierByName("modifier_spawnshield")
		ARCHERS[npcId]:RemoveModifierByName("modifier_burst")
	end

	-- Now that the game isn't in pregame, start the warmup phase.
	print('[[ArcherWars]] GameState Entering WarmUp')
	self.thinkState = Dynamic_Wrap( ArcherWarsGameMode, '_thinkState_Game' )
end

-- PreGame, runs during pre game time, so the doesn't start until it ends.
function ArcherWarsGameMode:_thinkState_Game()
end

function ArcherWarsGameMode:UpdateScore( keys )
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local victim = EntIndexToHScript(keys.entindex_killed)
	local attackerPlayer = attacker:GetPlayerOwner()
	local attackerID = attackerPlayer:GetPlayerID()
	local attackerTeam = attackerPlayer:GetAssignedHero():GetTeam()

	local attackerName = PlayerResource:GetPlayerName(attackerID)

	if attacker:IsHero() and victim:IsHero() then
		KILLS[attackerID] = KILLS[attackerID] + 1
		-- 5 kills
		if KILLS[attackerID] == KILLS_TO_WIN-5 then
			GameRules:SendCustomMessage('<font color="#' .. PLAYER_COLORS[attackerID] .. '">' .. attackerName .. '</font> needs <font color="#cb215d">5</font> more kills to win!', 0, 0)
		end
		-- 1 kill
		if KILLS[attackerID] == KILLS_TO_WIN-1 then
			GameRules:SendCustomMessage('<font color="#' .. PLAYER_COLORS[attackerID] .. '">' .. attackerName .. '</font> needs <font color="#cb215d">1</font> more kill to win!', 0, 0)
			EmitGlobalSound( "ui.npe_objective_complete" )
		end
		-- Winner
		if KILLS[attackerID] >= KILLS_TO_WIN then
			GameRules:SendCustomMessage('<font color="#' .. PLAYER_COLORS[attackerID] .. '">' .. attackerName .. '</font> is the best archer. Congratulations!', 0, 0)
			GameRules:SetGameWinner(attackerTeam)
		end
	end
end

---------------------------------------------------------------------------
-- Simple scoreboard using debug text
---------------------------------------------------------------------------
function ArcherWarsGameMode:UpdateScoreboard()
  local sortedTeams = {}
  for i, archer in pairs( ARCHERS ) do
    table.insert( sortedTeams, { name = PlayerResource:GetPlayerName(i), teamScore = KILLS[i] } )
  end

  -- reverse-sort by score
  table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

  UTIL_ResetMessageTextAll()
  UTIL_MessageTextAll( "#ScoreboardTitle", 235, 211, 3, 255 )
for n, t in pairs( sortedTeams ) do
	local smallName = string.sub(t.name, 0, 13)
	local nameLength = string.len(smallName)
    UTIL_MessageTextAll( "▌" .. t.teamScore .. "	" .. smallName, PLAYER_COLORS2[n-1].R , PLAYER_COLORS2[n-1].G, PLAYER_COLORS2[n-1].B, 255 )
  end
end

function ArcherWarsGameMode:GiveXp()
	-- Check if the game is over
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end

	local highestXP = 0
	local playerXP = 0

	-- Get the highest XP in the game
	for npcId, v in pairs(ARCHERS) do
		playerXP = PlayerResource:GetPlayer(npcId):GetAssignedHero():GetCurrentXP()
		if highestXP < playerXP then
			highestXP = playerXP
		end
	end

	-- Give all players XP depending on the difference in XP to the highest
	for npcId, v in pairs(ARCHERS) do
		playerXP = PlayerResource:GetPlayer(npcId):GetAssignedHero():GetCurrentXP()
		local xpGive = (highestXP - playerXP)/10
		-- All players below 100 XP gets a base gain of 10 XP
		if playerXP < 100 then
			xpGive = xpGive + 10
		end
		ARCHERS[npcId]:AddExperience(xpGive, false, false)
		-- Give gold per tick
		PlayerResource:SetGold(npcId, PlayerResource:GetGold(npcId) + GOLD_PER_TICK, true)
	end

	return 6.0
end

-- Learns the Track ability without spending a point
function ArcherWarsGameMode:LearnLocate( keys )
	local hero = EntIndexToHScript(keys.entindex)
	if hero:IsHero() then
		local Ability = hero:FindAbilityByName("archer_locate")
		if Ability then
			Ability:SetLevel(1)
		end
	end
end

-- Send the player to a random spawn location and gives them a shield buff
function ArcherWarsGameMode:TeleportSpawn( keys )
	local npc = EntIndexToHScript(keys.entindex)
	local points = Entities:FindAllByName( "*_point_teleport_spot" )
	local point = points[math.random(table.getn(points))]:GetAbsOrigin()

	if npc:IsHero() then
		if ARCHERS[npc:GetPlayerOwnerID()] == nil then
			npc:SetGold( 0, false)
			if GameRules:State_Get() <= DOTA_GAMERULES_STATE_PRE_GAME then
				giveUnitDataDrivenModifier(npc, npc, "modifier_spawnshield", 60)
				giveUnitDataDrivenModifier(npc, npc, "modifier_burst", 60)
			end
			ARCHERS[npc:GetPlayerOwnerID()] = npc
		end

		FindClearSpaceForUnit(npc, point, false)
		npc:Stop()
		giveUnitDataDrivenModifier(npc, npc, "modifier_spawnshield", 3.0)
	end
end