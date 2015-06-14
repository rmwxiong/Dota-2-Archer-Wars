function summonHawk ( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local level = ability:GetLevel()
	local origin = caster:GetAbsOrigin()

	if caster.hawk and IsValidEntity(caster.hawk) and caster.hawk:IsAlive() then
		FindClearSpaceForUnit(caster.hawk, origin, true)
		caster.hawk:SetHealth(caster.hawk:GetMaxHealth())
	
		-- Spawn particle
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.hawk)	
	else
		-- Create the unit and make it controllable
		caster.hawk = CreateUnitByName("npc_scout_hawk"..level, origin, true, caster, caster, caster:GetTeamNumber())
		caster.hawk:SetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		if ability ~= nil then
			ability:ApplyDataDrivenModifier(caster, caster.hawk, "modifier_animal_bond", nil)
			caster.hawk:AddNewModifier(caster, nil, "modifier_invisible", nil)
		end
	end

end

function upgradeHawk ( keys )
	local caster = keys.caster
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local level = ability:GetLevel()

	if caster.hawk and caster.hawk:IsAlive() then 
		-- Remove the old hawk in its position
		local origin = caster.hawk:GetAbsOrigin()
		caster.hawk:RemoveSelf()

		-- Create the unit and make it controllable
		caster.hawk = CreateUnitByName("npc_scout_hawk"..level, origin, true, caster, caster, caster:GetTeamNumber())
		caster.hawk:SetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		ability:ApplyDataDrivenModifier(caster, caster.hawk, "modifier_animal_bond", nil)
		caster.hawk:AddNewModifier(caster, nil, "modifier_invisible", nil)
	end

end

function deathHawk ( keys )
	local caster = keys.caster
	local killer = keys.attacker
	local ability = keys.ability
	local casterHP = caster:GetMaxHealth()
	local backlash_damage = ability:GetLevelSpecialValueFor( "backlash_damage", ability:GetLevel() - 1 ) * 0.01

	-- Calculate and do the damage
	local damage = casterHP * backlash_damage

	ApplyDamage({ victim = caster, attacker = killer, damage = damage, damage_type = DAMAGE_TYPE_PURE })
end