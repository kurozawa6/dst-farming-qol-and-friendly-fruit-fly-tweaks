--if not GLOBAL.TheNet:GetIsServer() then return end
local TheSim = GLOBAL.TheSim
local TheWorld = GLOBAL.TheWorld
local GROUND = GLOBAL.GROUND
local SpawnPrefab = GLOBAL.SpawnPrefab
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

--AddPrefabPostInit -> if not nil and not in table then inst.components.lootdropper:AddChanceLoot("fruitflyfruit", 1.0)

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

	local GROWTH_STAGES = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs.farm_plant_potato.fn, "GROWTH_STAGES")
	print("6666")
	print(GROWTH_STAGES)
	
	local call_for_reinforcements = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs.farm_plant_potato.fn, "dig_up", "call_for_reinforcements")
	local function OnPicked(inst, doer)
		if inst.is_oversized then
			SpawnPrefab(inst.plant_def.product_oversized).Transform:SetPosition(inst.Transform:GetWorldPosition())
		end
		local x, y, z = inst.Transform:GetWorldPosition()
		if TheWorld.Map:GetTileAtPoint(x, y, z) == GROUND.FARMING_SOIL then
			local soil = SpawnPrefab("farm_soil")
			soil.Transform:SetPosition(x, y, z)
			soil:PushEvent("breaksoil")
		end

		if not inst.is_oversized and inst:HasTag("farm_plant_killjoy") and math.random() < 0.05 then
			local fruitfly = SpawnPrefab("fruitfly")
			fruitfly.Transform:SetPosition(x, y, z)
		end

		call_for_reinforcements(inst, doer)
	end

	local function MakePickable(inst, enable, product)
	    if not enable then
		inst:RemoveTag("fruitflyspawner")
		inst:RemoveComponent("pickable")
	    else
		if inst.components.pickable == nil then
		    inst:AddComponent("pickable")
		    inst.components.pickable.onpickedfn = OnPicked
				inst.components.pickable.remove_when_picked = true
		end
		    inst.components.pickable:SetUp(nil)
			inst.components.pickable.use_lootdropper_for_product = true
			inst.components.pickable.picksound = product == "spoiled_food" and "dontstarve/wilson/harvest_berries" or "dontstarve/wilson/pickup_plants"
			if not inst:HasTag("farm_plant_killjoy") then
				inst:AddTag("fruitflyspawner")
			else
				inst:RemoveTag("fruitflyspawner")
			end
	    end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.farm_plant_potato.fn, MakePickable, "MakePickable")
	
--[[
	local function oversized_onfinishwork(inst, chopper)
	    inst.components.lootdropper:DropLoot()
	    inst.components.lootdropper:DropLoot()
	    inst.components.lootdropper:DropLoot()
	    inst.components.lootdropper:DropLoot()
	    inst.components.lootdropper:DropLoot()
	    inst:Remove()
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.potato_oversized.fn, oversized_onfinishwork, "oversized_onfinishwork")
]]
--[[
	local function OnPicked(inst, doer)
		if inst.is_oversized then
			SpawnPrefab(inst.plant_def.product_oversized).Transform:SetPosition(inst.Transform:GetWorldPosition())
		end
		local x, y, z = inst.Transform:GetWorldPosition()
		if TheWorld.Map:GetTileAtPoint(x, y, z) == GROUND.FARMING_SOIL then
			local soil = SpawnPrefab("farm_soil")
			soil.Transform:SetPosition(x, y, z)
			soil:PushEvent("breaksoil")
		end

		if not inst.is_oversized and inst:HasTag("farm_plant_killjoy") and math.random() < 0.05 then
			local fruitfly = SpawnPrefab("fruitfly")
			fruitfly.Transform:SetPosition(x, y, z)
		end

		call_for_reinforcements(inst, doer)
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.farm_plant_potato.fn, OnPicked, "MakePickable", "OnPicked")
]]
end)

--AddPrefabPostInit("prefabs/farm_plants", function(inst)
--end)

--fn/makeplant -> growth_stages -> makepickable -> onpicked
