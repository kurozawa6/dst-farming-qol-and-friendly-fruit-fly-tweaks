local DISABLE_COLLISION = GetModConfigData("collision")
local DISABLE_BLOCKING = GetModConfigData("blocking")
local DISABLE_SLEEPING = GetModConfigData("sleeping")
local DISABLE_SOUNDS = GetModConfigData("sounds")
local ADD_HEALTH_REGEN = GetModConfigData("regen")
AddPrefabPostInit("friendlyfruitfly", function(inst)
	if DISABLE_COLLISION then
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(GLOBAL.COLLISION.GROUND)
	end
	if DISABLE_BLOCKING then
		inst:AddTag("NOBLOCK")
	end
	if DISABLE_SLEEPING then
		inst.entity:SetCanSleep(false)
	end
	if DISABLE_SOUNDS then
		inst.SoundEmitter:SetMute(true)
	end
	if ADD_HEALTH_REGEN then
		if inst.components.health ~= nil then
			inst.components.health:StartRegen(1, 1) --1hp/sec
		end
	end
end)