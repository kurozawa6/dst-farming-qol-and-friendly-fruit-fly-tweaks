--if not GLOBAL.TheNet:GetIsServer() then return end
local TheSim = GLOBAL.TheSim
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

AddPrefabPostInit("world", function(inst)
	local SpawnFriendlyFruitFly = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs.fruitflyfruit.fn, "OnInit", "SpawnFriendlyFruitFly")
	local function OnInit(inst)
	    if inst:HasTag("fruitflyfruit") then
		--Rebind Friendly Fruit Fly
		local fruitfly = TheSim:FindFirstEntityWithTag("friendlyfruitfly") or SpawnFriendlyFruitFly(inst)
		if fruitfly ~= nil and
		    fruitfly.components.health ~= nil and
		    not fruitfly.components.health:IsDead() and
		    fruitfly.components.follower.leader ~= inst then
		        fruitfly.components.follower:SetLeader(inst)
		end
	    end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.fruitflyfruit.fn, OnInit, "OnInit")
	
	local pickseed = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs.lordfruitfly.fn, "LordLootSetupFunction", "pickseed")
	local function LordLootSetupFunction(lootdropper)
		lootdropper.chanceloot = nil
		lootdropper:AddChanceLoot("fruitflyfruit", 1.0)
		for i = 1, 4 do
			lootdropper:AddChanceLoot(pickseed(), 1.0)
			lootdropper:AddChanceLoot(pickseed(), 0.25)
		end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.lordfruitfly.fn, LordLootSetupFunction, "LordLootSetupFunction")
end)
