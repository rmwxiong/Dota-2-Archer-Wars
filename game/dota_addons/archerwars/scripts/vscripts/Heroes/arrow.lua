-- Used to keep track of projectiles after creation
ProjectileHolder = {}
BeamStacks = {0,0,0,0,0,0,0,0,0,0}
MultishotStacks = {0,0,0,0,0,0,0,0,0,0}
 
-- Constants
MODIFIER_DUR = {15.0, 3.0, 5.0}
CUSTOM_ARROWS = {"fire", "frost", "lightning"}
CUSTOM_ARROWS_ITEM = {"item_fire_arrows", "item_frost_arrows", "item_lightning_arrows"}
MODIFIER_NAMES = {"modifier_burn", "modifier_slow", "modifier_armor"}
 
function normalArrow( args )
        local caster = args.caster
 
        local info =
        {
                Ability = args.ability,
                EffectName = "particles/arrow/archer_normal_arrow.vpcf",
                iMoveSpeed = args.MoveSpeed,
                vSpawnOrigin = caster:GetAbsOrigin(),
                fDistance = args.FixedDistance,
                fStartRadius = args.StartRadius,
                fEndRadius = args.EndRadius,
                Source = args.caster,
                bHasFrontalCone = false,
                bReplaceExisting = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                fExpireTime = GameRules:GetGameTime() + 10.0,
                bDeleteOnHit = true,
                vVelocity = caster:GetForwardVector() * args.MoveSpeed,
                modifiersList = {},
                modifiersNumber = {},
                fDamageMultiplier = 1.0
        }
 
        if (caster:HasModifier("modifier_aiming")) then
                local ability = caster:FindAbilityByName("archer_take_aim")
                local level = ability:GetLevel()
                info.vVelocity = info.vVelocity + caster:GetForwardVector() * (level * 500)
                info.fDistance = info.fDistance + (level * 500)
        end
 
        local PROC_CHANCE = {18, 15, 15}
        local particleString = ""
        local randomProc = 0
 
        -- Elemental Arrow
        for i, v in pairs(CUSTOM_ARROWS_ITEM) do
                randomProc = RandomInt(0, 100)
                if caster:HasItemInInventory(CUSTOM_ARROWS_ITEM[i]) and randomProc <= PROC_CHANCE[i] then
                        particleString = particleString .. CUSTOM_ARROWS[i] .. "_"
                        table.insert(info.modifiersList, MODIFIER_NAMES[i])
                        table.insert(info.modifiersNumber, i)
                        -- Lightning Arrow
                        if CUSTOM_ARROWS_ITEM[i] == "item_lightning_arrows" then
                                info.vVelocity = info.vVelocity * 1.25
                        end
                end
        end
        -- Arrow Particles
        if particleString ~= "" then
                info.EffectName = "particles/arrow/archer_" .. particleString .."arrow.vpcf"
        end
 
        -- Dual Arrow
        if caster:HasItemInInventory("item_dual_arrows") then
                MultishotStacks[caster:GetMainControllingPlayer() +1] = MultishotStacks[caster:GetMainControllingPlayer() +1] +1
                if MultishotStacks[caster:GetMainControllingPlayer() +1] >= 4 then
                        MultishotStacks[caster:GetMainControllingPlayer() +1] = MultishotStacks[caster:GetMainControllingPlayer() +1] -4
                        Timers:CreateTimer('Multishot Delay', {
                                                useGameTime = false,
                                                endTime = 0.2,
                                                callback = function()
                                                EmitSoundOn("Hero_Windrunner.PowershotDamage", caster)
                                                -- Create Dual Arrow
                                                local info2 = info
                                                info2.fDamageMultiplier = 0.25
                                                local projectileID2 = ProjectileManager:CreateLinearProjectile(info2)
                                                addToProjectileHolder(info2, projectileID2)
                                                end    
                                        })
                end
        end
 
        -- Create Arrow
        local projectileID = ProjectileManager:CreateLinearProjectile(info)
        addToProjectileHolder(info, projectileID)
end
 
function arrowHit( args )
        local caster = args.caster
        local target = args.target
        local distance = 0
        local projectileID = 0
        projectileID,distance = findClosestInProjectileHolder(args.target_points[1])
        local totalDamage = math.floor((args.Damage + getArrowDamageIncrease(caster)) * ProjectileHolder[getProjectileHolderID(projectileID)].info.fDamageMultiplier)	-- Also adds bonus damage from [Arrow Damage]
 
        local damageTable = {
        	victim = target,
			attacker = caster,
			damage = totalDamage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
        local randomProc = RandomInt(0, 100)
        -- Critical Arrow (MM Luck)
        if (caster:HasItemInInventory("item_mm_luck_3")) and randomProc <= 20 then
                damageTable.damage = damageTable.damage * 1.25
        elseif (caster:HasItemInInventory("item_mm_luck_2")) and randomProc <= 15 then
                damageTable.damage = damageTable.damage * 1.33
        elseif (caster:HasItemInInventory("item_mm_luck")) and randomProc <= 10 then
                damageTable.damage = damageTable.damage * 1.50
        end
 
        -- Arrow Damage
        ApplyDamage(damageTable)
 
        -- Mana Steal
        randomProc = RandomInt(0, 100)
        if (caster:HasItemInInventory("item_mana_steal")) then
                if randomProc <= 35 then
                        target:ReduceMana(50)
                        caster:GiveMana(50)
                end
        end
        -- Life Steal
        stealLife( damageTable.damage, caster )
 
        -- Astral Compass
        if caster:HasItemInInventory("item_astral_compass") then
                BeamStacks[caster:GetMainControllingPlayer() +1] = BeamStacks[caster:GetMainControllingPlayer() +1] +1
                if BeamStacks[caster:GetMainControllingPlayer() +1] >= 3 then
                        BeamStacks[caster:GetMainControllingPlayer() +1] = BeamStacks[caster:GetMainControllingPlayer() +1] -3
                        local lunarDamageTable = {
                        victim = target,
                        attacker = caster,
                        damage = 90,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                }
                giveUnitDataDrivenModifier(caster, target, "modifier_beam", 1.0)
                Timers:CreateTimer('Lunar Delay', {
                                                useGameTime = false,
                                                endTime = 0.3,
                                                callback = function()
                                                -- Lunar Damage
                                                ApplyDamage(lunarDamageTable)
                                                end    
                                        })
                end
        end
 
        -- Elemental Arrow Debuffs
        if ProjectileHolder[getProjectileHolderID(projectileID)].info.modifiersList ~= nil then
                local modList = ProjectileHolder[getProjectileHolderID(projectileID)].info.modifiersList
                local modNumber = ProjectileHolder[getProjectileHolderID(projectileID)].info.modifiersNumber
                for j, v in pairs(modList) do
                        giveUnitDataDrivenModifier(caster, target, modList[j], MODIFIER_DUR[modNumber[j]])
                end
        end
end
 
function getArrowDamageIncrease( caster )
        local inventory = { caster:GetItemInSlot(0), caster:GetItemInSlot(1), caster:GetItemInSlot(2), caster:GetItemInSlot(3), caster:GetItemInSlot(4), caster:GetItemInSlot(5), }
        local bonusDamage = 0
 
        for i, v in pairs(inventory) do
                for j, v in pairs(CUSTOM_ARROWS_ITEM) do
                        if inventory[i]:GetName() == CUSTOM_ARROWS_ITEM[j] then
                                bonusDamage = bonusDamage + 25
                                break
                        end
                        if inventory[i]:GetName() == "item_reinforced_arrows" then
                                bonusDamage = bonusDamage + 25
                                break
                        end
                end
        end
 
        return bonusDamage
end
 
function getItemsAmount( caster, name)
        local inventory = { caster:GetItemInSlot(0), caster:GetItemInSlot(1), caster:GetItemInSlot(2), caster:GetItemInSlot(3), caster:GetItemInSlot(4), caster:GetItemInSlot(5), }
        local itemsFound = 0
 
        for i, _ in pairs(inventory) do
                if inventory[i]:GetName() == name then
                        itemsFound = itemsFound + 1
                end
        end
 
        return itemsFound
end
 
function stealLife( damageDone, caster )
        local amount = math.floor(damageDone * 0.10)
 
        if (caster:HasItemInInventory("item_lifesteal_mask")) then
                caster:Heal(amount, caster)
        end
end
 
function giveUnitDataDrivenModifier(source, target, modifier,dur)
        local item = CreateItem( "item_apply_modifiers", source, source)
        item:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end
 
-- /////////////////////////////////////////////////////////////////////////////
-- //////////////////////////// Projectile Handlers ////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////
function addToProjectileHolder(infoTable, projectileID)
        local projectileEntry =
        {
                projectileID = projectileID,
                creationTime = GameRules:GetGameTime(),
                SpawnOrigin = infoTable.vSpawnOrigin,
                VelocityVector = infoTable.vVelocity,
                info = infoTable
        }
        table.insert(ProjectileHolder, projectileEntry)
        Timers:CreateTimer(30, function() return projectileHolderCleaner() end)
end
 
function projectileHolderCleaner()
        table.remove(ProjectileHolder,1)
end
 
function getProjectileHolderID(projectileID)
        for i, v in pairs(ProjectileHolder) do
                if projectileID == ProjectileHolder[i].projectileID then
                        return i
                end
        end
        return nil
end
 
function findClosestInProjectileHolder(locationVector)
	local currentTime = GameRules:GetGameTime()
	local BestProjectile = 1
	local BestDistanceDiff = 999999 -- Basically just a large number to start with
	for listCount = 1, #ProjectileHolder do
		--PrintTable(ProjectileHolder)
		projectile = ProjectileHolder[listCount]
		projectileLocation = projectile.SpawnOrigin + ( projectile.VelocityVector * ( currentTime - projectile.creationTime))
		DistanceDiff = (projectileLocation - locationVector):Length2D()
		if DistanceDiff < BestDistanceDiff then
			BestProjectile = listCount
			BestDistanceDiff = DistanceDiff
		end
	end
	local projectile = ProjectileHolder[BestProjectile]
	local travilDistanceVector = projectile.VelocityVector * ( currentTime - projectile.creationTime)
	--local travilDistanceFloat = math.sqrt((travilDistanceVector.x * travilDistanceVector.x) + (travilDistanceVector.y * travilDistanceVector.y))
	local travilDistanceFloat = travilDistanceVector:Length2D()
	local projectileReturnID = projectile.projectileID
	projectileLocation = projectile.SpawnOrigin + ( projectile.VelocityVector * ( currentTime - projectile.creationTime))
	--print (projectileLocation)
	--PrintTable(ProjectileHolder)
	return projectileReturnID, travilDistanceFloat
end

function PrintTable( tableToPrint )
	print("Printing table!")
	for key,value in pairs(tableToPrint) do print(key,value) end
end