-- This ability was made possible thanks to kritth.
function shootExplosiveArrow( keys )
	local ability = keys.ability
	local caster = keys.caster
	local frame = 0.03
	local forwardVec = ( keys.target_points[1] - caster:GetAbsOrigin() ):Normalized()
	local speed = ability:GetLevelSpecialValueFor( "arrow_speed", ( ability:GetLevel() - 1 ) )
	local maximum_distance = ability:GetLevelSpecialValueFor( "range", ( ability:GetLevel() - 1 ) )
	local target = caster:GetAbsOrigin() + maximum_distance * forwardVec

	if caster.ability_current_point == nil then caster.ability_current_point = {} end
	table.insert(caster.ability_current_point, caster:GetAbsOrigin() + forwardVec * speed * frame * 3) -- Multiplying by 3 to get explosion centered on the arrow
	local id = #caster.ability_current_point
	print(id)

	Timers:CreateTimer( function()
		if ( caster.ability_current_point[id] - target ):Length2D() < 50 then
			caster.ability_current_point[id] = nil
			return nil
		else
			caster.ability_current_point[id] = caster.ability_current_point[id] + forwardVec * speed * frame
			return frame
		end
	end)
end

function explodeArrow( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Effects and Sounds
	local explosion_particle = keys.explosion_particle
	local explosion_sound = keys.explosion_sound

	-- Variables from KV
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local damage = ability:GetLevelSpecialValueFor( "damage", ( ability:GetLevel() - 1 ) )
	

	PrintTable(caster.ability_current_point)
	for i, v in pairs(caster.ability_current_point) do
		if v ~= nil then
			local fxIndex = ParticleManager:CreateParticle( explosion_particle, PATTACH_POINT, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, v )

			EmitSoundOn(explosion_sound, caster)

			local units = FindUnitsInRadius( caster:GetTeamNumber(), v, caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
			for k, v in pairs( units ) do
				local damageTable = {
				victim = v,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				}
				ApplyDamage(damageTable)
			end
		end
	end
end