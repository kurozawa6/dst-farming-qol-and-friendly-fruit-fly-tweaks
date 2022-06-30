--if not GLOBAL.TheNet:GetIsServer() then return end
local TheSim = GLOBAL.TheSim
local SpawnPrefab = GLOBAL.SpawnPrefab
local FindEntity = GLOBAL.FindEntity
local distsq = GLOBAL.distsq
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

--AddPrefabPostInit -> if not nil and not in table then inst.components.lootdropper:AddChanceLoot("fruitflyfruit", 1.0)


-- FRUIT FLY
AddPrefabPostInit("friendlyfruitfly", function(inst)
	if inst.components == nil or inst.components.locomotor == nil then return end
	inst.components.locomotor.walkspeed = 2 * inst.components.locomotor.walkspeed
end)
AddPrefabPostInit("world", function(inst)
	local SpawnFriendlyFruitFly = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs.fruitflyfruit.fn, "OnInit", "SpawnFriendlyFruitFly")
	local function OnInit(inst)
		if inst:HasTag("fruitflyfruit") then
			--Rebind Friendly Fruit Fly
			local fruitfly = TheSim:FindFirstEntityWithTag("friendlyfruitfly") or SpawnFriendlyFruitFly(inst) --TO FINISH
			if fruitfly ~= nil and
				fruitfly.components.health ~= nil and
				not fruitfly.components.health:IsDead() and
				fruitfly.components.follower.leader ~= inst then
					fruitfly.components.follower:SetLeader(inst)
			end
	    end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.fruitflyfruit.fn, OnInit, "OnInit")

	local pickseed = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs.lordfruitfly.fn, "LordLootSetupFunction", "pickseed") --to be replaced with addchanceloot w/o hack
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
AddBrainPostInit("friendlyfruitflybrain", function(brain)

	local SEE_DIST_NEW = 40
	local SEE_DIST = 20
	local function ModifiedGetFollowPos(inst, plant)
		local followpos = inst.components.follower.leader and inst.components.follower.leader:GetPosition() or inst:GetPosition()
		if plant == nil then return followpos end
		local plantpos = plant:GetPosition()
		if distsq(followpos.x, followpos.z, plantpos.x, plantpos.z) < SEE_DIST_NEW * SEE_DIST_NEW then
			followpos.x = plantpos.x
			followpos.z = plantpos.z
			print("6666 followpos set to plantpos")
		else
			followpos.x = plantpos.x + SEE_DIST + 1
			followpos.z = plantpos.z + SEE_DIST + 1
			print("6666 followpos set to far from plantpos")
		end
		print(followpos.x)
		print(followpos.z)
		return followpos
	end

	local function ModifiedIsNearFollowPos(self, plant)
		local followpos = self.getfollowposfn(self.inst)
		local plantpos = plant:GetPosition()
		return distsq(followpos.x, followpos.z, plantpos.x, plantpos.z) < SEE_DIST_NEW * SEE_DIST_NEW
	end

	local FARMPLANT_MUSTTAGS = { "farmplantstress" }
	local FARMPLANT_NOTAGS = { "farm_plant_killjoy" }
	local function ModifiedPickTarget(self)
		self.inst.planttarget = FindEntity(self.inst, SEE_DIST_NEW, function(plant)
			if ModifiedIsNearFollowPos(self, plant) and (self.validplantfn == nil or self.validplantfn(self.inst, plant)) and
			(plant.components.growable == nil or plant.components.growable:GetCurrentStageData().tendable) then
				return plant.components.farmplantstress and plant.components.farmplantstress.stressors.happiness == self.wantsstressed
			end
		end, FARMPLANT_MUSTTAGS, FARMPLANT_NOTAGS)
	end

	local index = nil
    for i,v in ipairs(brain.bt.root.children) do
        if v.name == "FindFarmPlant" then
            index = i
            break
        end
    end

	--local planttarget = brain.bt.root.children[index].inst.planttarget --always nil for some reason
	brain.bt.root.children[index].getfollowposfn = function(inst) return ModifiedGetFollowPos(brain.inst, brain.bt.root.children[index].inst.planttarget) end
	brain.bt.root.children[index].PickTarget = function(self) return ModifiedPickTarget(self) end
	--local SEE_DIST = 100
	--UpvalueHacker.SetUpvalue(brain.bt.root.children[index].PickTarget, SEE_DIST, "SEE_DIST")
end)

--Prefabs.friendlyfruitfly.fn -> *FriendlyFruitFlyBrain -> OnStart -> *FindFarmPlant -> IsNearFollowPos -> SEE_DIST
--friendlybrain


-- FARM PLANTS
AddPrefabPostInitAny(function(inst)
	if not (inst:HasTag("oversized_veggie") and inst:HasTag("waxable")) then return end
	if inst.components == nil then return end
	inst:AddComponent("pickable")
	inst.components.pickable.remove_when_picked = true
	inst.components.pickable:SetUp(nil)
	inst.components.pickable.use_lootdropper_for_product = true
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	--inst.components.pickable.droppicked = true --experiment, picksound doesn't work when on
end)
AddPrefabPostInit("world", function(inst)
	local function SpawnPseudoCropLoot(inst) --function to spawnprefab a pseudo loot from loot source location
		local pseudoloot = SpawnPrefab(inst.plant_def.product_oversized)
		if pseudoloot ~= nil then
			pseudoloot.Transform:SetPosition(inst.Transform:GetWorldPosition())
			pseudoloot.from_plant = true --fixes pseudoloot produce scale new record not being registered
			--return pseudoloot
		end
	end
	local function call_for_reinforcements(inst, target) --the only function I found reachable by upvalue hack
		if inst.is_oversized then
			SpawnPseudoCropLoot(inst) --pseudo-loot, main function change
			target.SoundEmitter:PlaySound("dontstarve/wilson/pickup_plants") --pseudo-sound, sound can't be made from empty loot
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

		if inst:HasTag("farm_plant_killjoy") then --if rotten
			lootdropper:SetLoot(inst.is_oversized and inst.plant_def.loot_oversized_rot or spoiled_food_loot)
		elseif inst.components.pickable ~= nil then
			local plant_stress = inst.components.farmplantstress ~= nil and inst.components.farmplantstress:GetFinalStressState() or FARM_PLANT_STRESS.HIGH

			if inst.is_oversized then
				lootdropper:SetLoot({}) --old loot replaced by above SpawnPrefab, main function change
			elseif plant_stress == FARM_PLANT_STRESS.LOW or plant_stress == FARM_PLANT_STRESS.NONE then
				lootdropper:SetLoot({inst.plant_def.product, inst.plant_def.seed, inst.plant_def.seed})
			elseif plant_stress == FARM_PLANT_STRESS.MODERATE then
				lootdropper:SetLoot({inst.plant_def.product, inst.plant_def.seed})
			else --plant_stress == FARM_PLANT_STRESS.HIGH
				lootdropper:SetLoot({inst.plant_def.product})
			end
		end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.farm_plant_potato.fn, SetupLoot, "SetupLoot")

	local OVERSIZED_PHYSICS_RADIUS = 0.1 --default, configurable
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.potato_oversized.fn, OVERSIZED_PHYSICS_RADIUS, "OVERSIZED_PHYSICS_RADIUS")
end)