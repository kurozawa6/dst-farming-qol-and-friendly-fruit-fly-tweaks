--if not GLOBAL.TheNet:GetIsServer() then return end
local TheSim = GLOBAL.TheSim
local SpawnPrefab = GLOBAL.SpawnPrefab
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

--AddPrefabPostInit -> if not nil and not in table then inst.components.lootdropper:AddChanceLoot("fruitflyfruit", 1.0)

AddPrefabPostInit("world", function(inst)
	
	
	--FRUIT FLY
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


	--FARM PLANTS
	local function call_for_reinforcements(inst, target)
		if inst.is_oversized then
			SpawnPrefab(inst.plant_def.product_oversized).Transform:SetPosition(inst.Transform:GetWorldPosition())
			target.SoundEmitter:PlaySound("dontstarve/wilson/pickup_plants")
		end
		if not target:HasTag("plantkin") then
			local x, y, z = inst.Transform:GetWorldPosition()
			local defenders = TheSim:FindEntities(x, y, z, TUNING.FARM_PLANT_DEFENDER_SEARCH_DIST, {"farm_plant_defender"})
			for _, defender in ipairs(defenders) do
				if defender.components.burnable == nil or not defender.components.burnable.burning then
					defender:PushEvent("defend_farm_plant", {source = inst, target = target})
					break
				end
			end
		end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.farm_plant_potato.fn, call_for_reinforcements, "dig_up", "call_for_reinforcements")

	local function SetupLoot(lootdropper)
		local inst = lootdropper.inst

		if inst:HasTag("farm_plant_killjoy") then -- if rotten
			lootdropper:SetLoot(inst.is_oversized and inst.plant_def.loot_oversized_rot or spoiled_food_loot)
		elseif inst.components.pickable ~= nil then
			local plant_stress = inst.components.farmplantstress ~= nil and inst.components.farmplantstress:GetFinalStressState() or FARM_PLANT_STRESS.HIGH

			if inst.is_oversized then
				lootdropper:SetLoot({}) -- old loot replaced by above SpawnPrefab
			elseif plant_stress == FARM_PLANT_STRESS.LOW or plant_stress == FARM_PLANT_STRESS.NONE then
				lootdropper:SetLoot({inst.plant_def.product, inst.plant_def.seed, inst.plant_def.seed})
			elseif plant_stress == FARM_PLANT_STRESS.MODERATE then
				lootdropper:SetLoot({inst.plant_def.product, inst.plant_def.seed})
			else -- plant_stress == FARM_PLANT_STRESS.HIGH
				lootdropper:SetLoot({inst.plant_def.product})
			end
		end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.farm_plant_potato.fn, SetupLoot, "SetupLoot")

	local OVERSIZED_PHYSICS_RADIUS = 0.1 --default, configurable
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.potato_oversized.fn, OVERSIZED_PHYSICS_RADIUS, "OVERSIZED_PHYSICS_RADIUS")
end)