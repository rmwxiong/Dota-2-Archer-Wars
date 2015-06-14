function locate( args )
	local ability = keys.ability
	local caster = args.caster

	local duration = ability:GetLevelSpecialValueFor( "sight_duration", ( ability:GetLevel() - 1 ) )
	duration = duration * 10
	local radius = ability:GetLevelSpecialValueFor( "sight_radius", ( ability:GetLevel() - 1 ) )

	local targets = Entities:FindAllByClassname( "npc_dota_hero_windrunner" )
	local targets2 = Entities:FindAllByClassname( "npc_dota_hero_clinkz" )
	local targets3 = Entities:FindAllByClassname( "npc_dota_hero_mirana" )

	for k,v in pairs(targets2) do table.insert(targets ,v) end
	for k,v in pairs(targets3) do table.insert(targets ,v) end


	for i=1, table.getn(targets) do
		for l=0, duration do
			Timers:CreateTimer(0.1 * l, function() targets[i]:MakeVisibleToTeam(caster:GetTeam(), 0.1) end)
		end
	end
end

function unitKiller(unit)
	unit:RemoveSelf()
	return nil
end