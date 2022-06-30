--if not GLOBAL.TheNet:GetIsServer() then return end
local TheSim = GLOBAL.TheSim
local LootTables = GLOBAL.LootTables
local SpawnPrefab = GLOBAL.SpawnPrefab
local FARM_PLANT_STRESS = GLOBAL.FARM_PLANT_STRESS
local FindEntity = GLOBAL.FindEntity
local BufferedAction = GLOBAL.BufferedAction
local distsq = GLOBAL.distsq
local SUCCESS = GLOBAL.SUCCESS
local FAILED = GLOBAL.FAILED
local READY = GLOBAL.READY
local RUNNING = GLOBAL.RUNNING
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

--AddPrefabPostInit -> if not nil and not in table then inst.components.lootdropper:AddChanceLoot("fruitflyfruit", 1.0)


-- FRUIT FLY
AddPrefabPostInit("friendlyfruitfly", function(inst) --stats and tweaks
	if inst.components.locomotor == nil then return end
	inst.components.locomotor.walkspeed = 2 * inst.components.locomotor.walkspeed
end)
AddPrefabPostInit("lordfruitfly", function(inst) --below is the function that attempts to add fruitfly fruit when necessary non-invasively
	if inst.components.lootdropper == nil then return end
	local function inLootTable(table, element)
		for k,v in pairs(table) do
			if v["prefab"] == element or v[1] == element then return true end
		end
		return false
	end
	if inst.components.lootdropper.chanceloot == nil then return end
	local chanceLootTable = inst.components.lootdropper.chanceloot
	local sharedLootTable = LootTables[inst.components.lootdropper.chanceloottable]
	if not inLootTable(chanceLootTable, "fruitflyfruit") and not inLootTable(sharedLootTable, "fruitflyfruit") then
		--print("7777 FALSE AND FALSE DETECTED, WILL ATTEMPT TO ADD ONE") --debugging
		table.insert(sharedLootTable, {"fruitflyfruit", 1.0 })
	elseif inLootTable(chanceLootTable, "fruitflyfruit") and inLootTable(sharedLootTable, "fruitflyfruit") then
		local index = nil
		for k,v in pairs(sharedLootTable) do
			if v[1] == "fruitflyfruit" then index = k break end
		end
		--print("6666 TRUE AND TRUE DETECTED, WILL ATTEMPT TO REMOVE ONE") -debugging
		table.remove(sharedLootTable, index)
	end
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
end)
AddBrainPostInit("friendlyfruitflybrain", function(brain)
	local SEE_DIST_NEW = 30 --replaces local variable SEE_DIST from original
	local function ModifiedIsNearFollowPos(self, plant) --a local fn from original, only SEE_DIST is changed
		local followpos = self.getfollowposfn(self.inst)
		local plantpos = plant:GetPosition()
		return distsq(followpos.x, followpos.z, plantpos.x, plantpos.z) < SEE_DIST_NEW * SEE_DIST_NEW --main function change
	end

	local FARMPLANT_MUSTTAGS = { "farmplantstress" }
	local FARMPLANT_NOTAGS = { "farm_plant_killjoy" }
	local function ModifiedPickTarget(self) --important picktarget function to modify
		self.inst.planttarget = FindEntity(self.inst, SEE_DIST_NEW, function(plant) --main function modification
			if ModifiedIsNearFollowPos(self, plant) and (self.validplantfn == nil or self.validplantfn(self.inst, plant)) and --modification2
			(plant.components.growable == nil or plant.components.growable:GetCurrentStageData().tendable) then
				return plant.components.farmplantstress and plant.components.farmplantstress.stressors.happiness == self.wantsstressed
			end
		end, FARMPLANT_MUSTTAGS, FARMPLANT_NOTAGS)
	end

	local function ModifiedVisit(self) --mostly copy-pasted from the original, modifying only IsNearFollowPos
		if self.status == READY then
			self:PickTarget()--must be PickTarget instead of ModifiedPickTarget as it is from self
			if self.inst.planttarget then
				local action = BufferedAction(self.inst, self.inst.planttarget, self.action, nil, nil, nil, 0.1)
				self.inst.components.locomotor:PushAction(action, self.shouldrun)
				self.status = RUNNING
			else
				self.status = FAILED
			end
		end
		if self.status == RUNNING then
			local plant = self.inst.planttarget
			if not plant or not plant:IsValid() or not ModifiedIsNearFollowPos(self, plant) or --main function change, using ModifiedIsNearFollowPos as IsNearFollowPos is a local fn
			not (self.validplantfn == nil or self.validplantfn(self.inst, plant)) or not (plant.components.growable == nil or plant.components.growable:GetCurrentStageData().tendable) then
				self.inst.planttarget = nil
				self.status = FAILED
			--we don't need to test for the component, since we won't ever set clostest plant to anything that lacks that component --dev comment, not mine
			elseif plant.components.farmplantstress.stressors.happiness ~= self.wantsstressed then
				self.inst.planttarget = nil
				self.status = SUCCESS
			end
		end
	end

	local index = nil
	for i,v in ipairs(brain.bt.root.children) do
		if v.name == "FindFarmPlant" then
			index = i
			break
		end
	end
	brain.bt.root.children[index].PickTarget = function(self) return ModifiedPickTarget(self) end
	brain.bt.root.children[index].Visit = function(self) return ModifiedVisit(self) end
end)


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
	local function SpawnPseudoCropLoot(inst) --important function to spawnprefab a pseudo loot from loot source location
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
			target.SoundEmitter:PlaySound("dontstarve/wilson/pickup_plants") --pseudo-sound?, sound can't be made from empty loot
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


--WATERFOWL CAN
AddPrefabPostInit("premiumwateringcan", function(inst)
	if inst.components.fillable == nil then return end
	inst.components.fillable.acceptsoceanwater = true
	inst.components.burnable = nil --makes it non-flammable
	inst:RemoveTag("canlight") --removes "Light" action text when hovered by mouse
end)