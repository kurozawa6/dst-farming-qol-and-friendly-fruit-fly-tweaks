--if not GLOBAL.TheNet:GetIsServer() then return end
local COLLISION = GLOBAL.COLLISION
local GetTime = GLOBAL.GetTime
local TheSim = GLOBAL.TheSim
local SpawnPrefab = GLOBAL.SpawnPrefab
local Prefabs = GLOBAL.Prefabs
local Ents = GLOBAL.Ents
local LootTables = GLOBAL.LootTables
local FindWalkableOffset = GLOBAL.FindWalkableOffset
local PI = GLOBAL.PI
local Vector3 = GLOBAL.Vector3
local FindEntity = GLOBAL.FindEntity
local BufferedAction = GLOBAL.BufferedAction
local distsq = GLOBAL.distsq
local SUCCESS = GLOBAL.SUCCESS
local FAILED = GLOBAL.FAILED
local READY = GLOBAL.READY
local RUNNING = GLOBAL.RUNNING
local ACTIONS = GLOBAL.ACTIONS
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")


-- FRUIT FLY
local function idnumToString(idnum)
	local result = "idnum-"..(idnum or "invalid")
	return result
end
--Stats and Tweaks
AddPrefabPostInit("friendlyfruitfly", function(inst)
	if GetModConfigData("fffly_unloading_disabled") then
		inst.entity:SetCanSleep(false)
	end
	if GetModConfigData("fffly_collision_disabled") then
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.GROUND)
	end
	if GetModConfigData("fffly_blocking_disabled") then
		inst:AddTag("NOBLOCK")
	end
	if GetModConfigData("fffly_muted") then
		inst.SoundEmitter:SetMute(true)
	end
	if inst.components.locomotor ~= nil then
		inst.components.locomotor.walkspeed = GetModConfigData("fffly_speed_multiplier") * inst.components.locomotor.walkspeed
	end
	if GetModConfigData("fffly_regen_enabled") and inst.components.health ~= nil then
		inst.components.health:StartRegen(1,1)
	end
end)
AddBrainPostInit("friendlyfruitflybrain", function(brain) --modifies fffly's tending radius
	local SEE_DIST_NEW = 20 * GetModConfigData("fffly_range") --replaces local variable SEE_DIST from original
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
			if not plant or not plant:IsValid() or not ModifiedIsNearFollowPos(self, plant) or --main function change
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
	brain.bt.root.children[index].PickTarget = function(self) return ModifiedPickTarget(self) end --applies changes on instance's FindFarmPlant functions
	brain.bt.root.children[index].Visit = function(self) return ModifiedVisit(self) end
end)
--More FFFlies prerequisites
local function countprefabs(prefab)
	local count = 0
	for k,v in pairs(Ents) do
		if v.prefab == prefab then count = count + 1 end
	end
	return count
end
AddPrefabPostInit("lordfruitfly", function(inst) --functions that attempt to add or limit fruitfly fruit when necessary non-invasively
	if inst.components.lootdropper == nil then return end
	local function inLootTable(table, element)
		for k,v in pairs(table) do
			if v["prefab"] == element or v[1] == element then return true end
		end
		return false
	end
	local function getSharedLootTableIndex(table)
		local index = nil
		for k,v in pairs(table) do
			if v[1] == "fruitflyfruit" then index = k break end
		end
		return index
	end
	if inst.components.lootdropper.chanceloot == nil then return end
	local shared_loot_table = LootTables[inst.components.lootdropper.chanceloottable]
--Fruit Fly Fruit Loot Limiter based on Friendly Fruit Fly Prefab Count
	if countprefabs("friendlyfruitfly") >= GetModConfigData("fffly_number_limit") then --this limits fruit fly fruit loots based on a number
		if inLootTable(shared_loot_table, "fruitflyfruit") then
			local index = getSharedLootTableIndex(shared_loot_table)
			table.remove(shared_loot_table, index)
		end
		return
	end
	local chance_loot_table = inst.components.lootdropper.chanceloot
	if not inLootTable(chance_loot_table, "fruitflyfruit") and not inLootTable(shared_loot_table, "fruitflyfruit") then
		table.insert(shared_loot_table, {"fruitflyfruit", 1.0 })
	elseif inLootTable(chance_loot_table, "fruitflyfruit") and inLootTable(shared_loot_table, "fruitflyfruit") then
		local index = getSharedLootTableIndex(shared_loot_table)
		table.remove(shared_loot_table, index)
	end
end)
AddPrefabPostInit("fruitflyfruit", function(inst) --idnum attribute for fffruit used by custom functions below
	inst.idnum = GetTime()
end)
AddPrefabPostInit("world", function() --custom functions for multiple ffflies binding via idnum
	local function SpawnFriendlyFruitFly(inst, idnum) --added idnum argument to the original
		local x, y, z = inst.Transform:GetWorldPosition()
		local offset = FindWalkableOffset(Vector3(x, y, z), math.random() * 2 * PI, 35, 12, true)
		local fruitfly = SpawnPrefab("friendlyfruitfly")
		if fruitfly ~= nil then
			fruitfly.Physics:Teleport(offset ~= nil and offset.x + x or x, 0, offset ~= nil and offset.z + z or z)
			fruitfly:FacePoint(x, y, z)
			fruitfly.idnum = idnum --added idnum to original
			fruitfly:AddTag(idnumToString(idnum)) --uses idnum to add tag
			return fruitfly
		end
	end
	local function OnInit(inst)
		if inst:HasTag("fruitflyfruit") then
			--Rebind Friendly Fruit Fly --dev comment
			local fruitfly = TheSim:FindFirstEntityWithTag(idnumToString(inst.idnum)) or SpawnFriendlyFruitFly(inst, inst.idnum) --changed to use idnum
			if fruitfly ~= nil and
				fruitfly.components.health ~= nil and
				not fruitfly.components.health:IsDead() and
				fruitfly.components.follower.leader ~= inst then
					fruitfly.components.follower:SetLeader(inst)
			end
		end
	end
	UpvalueHacker.SetUpvalue(Prefabs.fruitflyfruit.fn, OnInit, "OnInit")
	local orig_OnPreLoadFruit = UpvalueHacker.GetUpvalue(Prefabs.fruitflyfruit.fn, "OnPreLoad")
	local function OnPreLoadFruit(inst, data) --OnPreLoad and OnSave functions modified to load and save idnum
		orig_OnPreLoadFruit(inst, data)
		if data ~= nil and data.idnum then
			inst.idnum = data.idnum
		end
	end
	local orig_OnSaveFruit = UpvalueHacker.GetUpvalue(Prefabs.fruitflyfruit.fn, "OnSave")
	local function OnSaveFruit(inst, data)
		orig_OnSaveFruit(inst, data)
		data.idnum = inst.idnum or GetTime()
	end
	UpvalueHacker.SetUpvalue(Prefabs.fruitflyfruit.fn, OnPreLoadFruit, "OnPreLoad")
	UpvalueHacker.SetUpvalue(Prefabs.fruitflyfruit.fn, OnSaveFruit, "OnSave")
end)
local function OnPreLoadFly(inst, data)
	if data ~= nil and data.idnum then
		inst.idnum = data.idnum
	end
	inst:AddTag(idnumToString(inst.idnum))
end
local function OnSaveFly(inst, data)
	data.idnum = inst.idnum
end
AddPrefabPostInit("friendlyfruitfly", function(inst) --modifies OnPreLoad and OnSave functions of fffly
	inst.idnum = GetTime()
	inst.OnPreLoad = OnPreLoadFly
	inst.OnSave = OnSaveFly
end)


-- WATERFOWL CAN
AddPrefabPostInit("premiumwateringcan", function(inst)
	if GetModConfigData("can_ocean_refill_wf") and inst.components.fillable ~= nil then
		inst.components.fillable.acceptsoceanwater = true
	end
	if GetModConfigData("cannot_burn_wf") and inst.components.burnable ~= nil then
		inst.components.burnable = nil --makes it non-flammable
		inst:RemoveTag("canlight") --removes "Light" action text when hovered by mouse
	end
end)


-- FARM PLANTS
--Fast Crop Seed Planting
AddStategraphPostInit("wilson", function(inst)
	if not GetModConfigData("fast_planting") or ACTIONS.PLANTSOIL == nil then return end
	if inst.actionhandlers[ACTIONS.PLANTSOIL].deststate == nil then return end
	inst.actionhandlers[ACTIONS.PLANTSOIL].deststate = function() return "doshortaction" end
end)
AddPrefabPostInit("world", function()
--Giant Crop Obstacle Radius
	local OVERSIZED_PHYSICS_RADIUS = GetModConfigData("giant_crop_collision_size")
	UpvalueHacker.SetUpvalue(Prefabs.potato_oversized.fn, OVERSIZED_PHYSICS_RADIUS, "OVERSIZED_PHYSICS_RADIUS")
--Giant Crops Don't Fly Around When Picked
	if GetModConfigData("stable_giant_crops") == false then
		return
	end
	local function SpawnPseudoCropLoot(inst) --important function to spawnprefab a pseudo loot from loot source location
		local pseudoloot = SpawnPrefab(inst.plant_def.product_oversized)
		if pseudoloot ~= nil then
			pseudoloot.Transform:SetPosition(inst.Transform:GetWorldPosition())
			pseudoloot.from_plant = true --fixes pseudoloot produce scale new record not being registered
			--return pseudoloot
		end
	end
	local orig_call_for_reinforcements = UpvalueHacker.GetUpvalue(Prefabs.farm_plant_potato.fn, "dig_up", "call_for_reinforcements")
	local function call_for_reinforcements(inst, target) --the only function I found reachable by upvalue hack
		if inst.is_oversized and not inst:HasTag("farm_plant_killjoy") then
			SpawnPseudoCropLoot(inst) --pseudo-loot, main function change
			target.SoundEmitter:PlaySound("dontstarve/wilson/pickup_plants") --pseudo-sound?, sound can't be made from empty loot
		end
		return orig_call_for_reinforcements(inst, target)
	end
	UpvalueHacker.SetUpvalue(Prefabs.farm_plant_potato.fn, call_for_reinforcements, "dig_up", "call_for_reinforcements")
	local orig_SetupLoot = UpvalueHacker.GetUpvalue(Prefabs.farm_plant_potato.fn, "SetupLoot")
	local function SetupLoot(lootdropper)
		orig_SetupLoot(lootdropper)
		local inst = lootdropper.inst
		if not inst:HasTag("farm_plant_killjoy") and inst.components.pickable ~= nil then
			if inst.is_oversized then
				lootdropper:SetLoot({}) --old loot replaced by above SpawnPrefab, main function change
			end
		end
	end
	UpvalueHacker.SetUpvalue(Prefabs.farm_plant_potato.fn, SetupLoot, "SetupLoot")
end)
--Hammerless Harvest
AddPrefabPostInitAny(function(inst)
	if not GetModConfigData("hammerless_harvest") then return end
	if not (inst:HasTag("oversized_veggie") and inst:HasTag("waxable")) then return end
	if inst.components == nil then return end
	inst:AddComponent("pickable")
	inst.components.pickable.remove_when_picked = true
	inst.components.pickable:SetUp(nil)
	inst.components.pickable.use_lootdropper_for_product = true
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	--inst.components.pickable.droppicked = true --experiment, picksound doesn't work when on
end)