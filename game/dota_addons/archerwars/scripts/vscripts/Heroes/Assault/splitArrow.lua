function splitArrow( args )
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
        }
 
        for i=-18,18,18 do
                info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * args.MoveSpeed
                projectile = ProjectileManager:CreateLinearProjectile(info)
        end
end
 
function splitHit( args )
        local caster = args.caster
        local totalDamage = args.Damage
        local target = args.target
        local damageTable = {
                        victim = target,
                        attacker = caster,
                        damage = totalDamage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                }
        ApplyDamage(damageTable)
end