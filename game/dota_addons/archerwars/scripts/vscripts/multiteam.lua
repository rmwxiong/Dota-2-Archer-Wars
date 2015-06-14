if MultiTeam == nil then
  MultiTeam = class({})
end

---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function MultiTeam:InitGameMode()
  print( "Multiteam Example addon is loaded." )

  self.m_TeamColors = {}
  self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 255, 0, 0 }
  self.m_TeamColors[DOTA_TEAM_BADGUYS] = { 0, 255, 0 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 0, 0, 255 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 128, 64 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 255, 255, 0 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 128, 255, 0 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 128, 0, 255 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 255, 0, 128 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 0, 255, 255 }
  self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 255, 255, 255 }

  self.m_GatheredShuffledTeams = {}
  self.m_PlayerTeamAssignments = {}
  self.m_NumAssignedPlayers = 0

  ---------------------------------------------------------------------------

  self:GatherValidTeams()

  -- Show the ending scoreboard immediately
  GameRules:SetCustomGameEndDelay( 0 )
  GameRules:SetCustomVictoryMessageDuration( 0 )
  GameRules:SetHideKillMessageHeaders( true )

  ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( MultiTeam, 'OnGameRulesStateChange' ), self )
end


---------------------------------------------------------------------------
-- Game state change handler
---------------------------------------------------------------------------
function MultiTeam:OnGameRulesStateChange()
  local nNewState = GameRules:State_Get()
  print( "OnGameRulesStateChange: " .. nNewState )

  if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    GameRules:GetGameModeEntity():SetThink( "EnsurePlayersOnCorrectTeam", self, 0 )
    GameRules:GetGameModeEntity():SetThink( "BroadcastPlayerTeamAssignments", self, 1 )
  end
end


---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function MultiTeam:ColorForTeam( teamID )
  local color = self.m_TeamColors[ teamID ]
  if color == nil then
    color = { 255, 255, 255 } -- default to white
  end
  return color
end


---------------------------------------------------------------------------
-- Determine a good team assignment for the next player
---------------------------------------------------------------------------
function MultiTeam:GetTeamReassignmentForPlayer( playerID )
  if #self.m_GatheredShuffledTeams == 0 then
    return nil
  end

  if nil == PlayerResource:GetPlayer( playerID ) then
    return nil -- no player yet
  end
  
  -- see if we've already assigned the player 
  local existingAssignment = self.m_PlayerTeamAssignments[ playerID ]
  if existingAssignment ~= nil then
    if existingAssignment == PlayerResource:GetTeam( playerID ) then
      return nil -- already assigned to this team and they're still on it
    else
      return existingAssignment -- something else pushed them out of the desired team - set it back
    end
  end

  -- haven't assigned this player to a team yet
  print( "m_NumAssignedPlayers = " .. self.m_NumAssignedPlayers )
  
  -- If the number of players per team doesn't divide evenly (ie. 10 players on 4 teams => 2.5 players per team)
  -- Then this floor will round that down to 2 players per team
  -- If you want to limit the number of players per team, you could just set this to eg. 1
  local playersPerTeam = 1
  print( "playersPerTeam = " .. playersPerTeam )

  local teamIndexForPlayer = math.floor( self.m_NumAssignedPlayers / playersPerTeam )
  print( "teamIndexForPlayer = " .. teamIndexForPlayer )

  -- Then once we get to the 9th player from the case above, we need to wrap around and start assigning to the first team
  if teamIndexForPlayer >= #self.m_GatheredShuffledTeams then
    teamIndexForPlayer = teamIndexForPlayer - #self.m_GatheredShuffledTeams
    print( "teamIndexForPlayer => " .. teamIndexForPlayer )
  end
  
  teamAssignment = self.m_GatheredShuffledTeams[ 1 + teamIndexForPlayer ]
  print( "teamAssignment = " .. teamAssignment )

  self.m_PlayerTeamAssignments[ playerID ] = teamAssignment

  self.m_NumAssignedPlayers = self.m_NumAssignedPlayers + 1

  return teamAssignment
end


---------------------------------------------------------------------------
-- Put a label over a player's hero so people know who is on what team
---------------------------------------------------------------------------
--[[function MultiTeam:MakeLabelForPlayer( nPlayerID )
  if not PlayerResource:HasSelectedHero( nPlayerID ) then
    return
  end

  local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
  if hero == nil then
    return
  end

  local teamID = PlayerResource:GetTeam( nPlayerID )
  local color = self:ColorForTeam( teamID )
  hero:SetCustomHealthLabel( GetTeamName( teamID ), color[1], color[2], color[3] )
end]]--


---------------------------------------------------------------------------
-- Tell everyone the team assignments during hero selection
---------------------------------------------------------------------------
function MultiTeam:BroadcastPlayerTeamAssignments()
  print( "BroadcastPlayerTeamAssignments" )
  for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
    print( "nPlayerID = "..nPlayerID )
    local nTeamID = PlayerResource:GetTeam( nPlayerID )
    if nTeamID ~= DOTA_TEAM_NOTEAM then
      print( "nTeamID = "..nTeamID )
      --GameRules:SendCustomMessage( "#TeamAssignmentMessage", nPlayerID, -1 )
    end
  end
end

---------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------
function ShuffledList( list )
  local result = {}
  local count = #list
  for i = 1, count do
    local pick = RandomInt( 1, #list )
    result[ #result + 1 ] = list[ pick ]
    table.remove( list, pick )
  end
  return result
end

function TableCount( t )
  local n = 0
  for _ in pairs( t ) do
    n = n + 1
  end
  return n
end


---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function MultiTeam:GatherValidTeams()
--  print( "GatherValidTeams:" )

  local foundTeams = {}
  for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
    foundTeams[  playerStart:GetTeam() ] = true
  end

  print( "GatherValidTeams - Found spawns for a total of " .. TableCount(foundTeams) .. " teams" )
  
  local foundTeamsList = {}
  for t, _ in pairs( foundTeams ) do
    table.insert( foundTeamsList, t )
  end

  self.m_GatheredShuffledTeams = ShuffledList( foundTeamsList )

  print( "Final shuffled team list:" )
  for _, team in pairs( self.m_GatheredShuffledTeams ) do
    print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
  end
end


---------------------------------------------------------------------------
-- Assign all real players to a team
---------------------------------------------------------------------------
function MultiTeam:EnsurePlayersOnCorrectTeam()
--  print( "Assigning players to teams..." )
  for playerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
    local teamReassignment = self:GetTeamReassignmentForPlayer( playerID )
    if nil ~= teamReassignment then
      print( " - Player " .. playerID .. " reassigned to team " .. teamReassignment )
      PlayerResource:SetCustomTeamAssignment( playerID, teamReassignment )
    end
  end
  
  return 1 -- Check again later in case more players spawn
end


---------------------------------------------------------------------------
-- When a team gets credit for a kill, see if anyone won
---------------------------------------------------------------------------
--[[function MultiTeam:OnTeamKillCredit( event )
--  print( "OnKillCredit" )
--  DeepPrint( event )
  
  local nKillerID = event.killer_userid
  local nTeamID = event.teamnumber
  local nTeamKills = event.herokills
  local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
  
  if nKillsRemaining <= 0 then
    GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
    GameRules:SetGameWinner( nTeamID )
  elseif nKillsRemaining == 1 then
    ShowCustomHeaderMessage( "#OneKillRemainingMessage", nKillerID, -1, 5 )
    EmitGlobalSound( "ui.npe_objective_complete" )
  elseif nKillsRemaining < 5 then
    ShowCustomHeaderMessage( "#KillsRemainingMessage", nKillerID, nKillsRemaining, 5 )
    EmitGlobalSound( "ui.npe_objective_given" )
  end
end]]--