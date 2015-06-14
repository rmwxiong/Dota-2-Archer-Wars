function swap( args )
	local Caster = args.caster
	local Target = args.target
	local Pos1 = Caster:GetCenter()
	local Pos2 = Target:GetCenter()

	FindClearSpaceForUnit(Caster, Pos2, false)
	FindClearSpaceForUnit(Target, Pos1, false)
	Target:Stop()
end

function pull( args )
	local Caster = args.caster
	local Target = args.target
	local cPos = Caster:GetCenter()
	local tPos = Target:GetCenter()
	local Distance = args.Distance
	local Duration = args.Duration
	local loops = 30
	local Power = (Distance / loops) * -1
	for l=0, loops do
		local Rotation = math.atan2(tPos.y - cPos.y, tPos.x - cPos.x)
		local VectorTowards = Vector(math.cos( Rotation ) * Power, math.sin( Rotation ) * Power, tPos.z)
		Timers:CreateTimer(Duration/loops * l, function() FindClearSpaceForUnit(Target, Target:GetCenter() + VectorTowards, false) end)
	end
end