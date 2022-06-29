local _G = GLOBAL
local require = _G.require
local TUNING = _G.TUNING
local TECH = _G.TECH
local eventhelpers = require("event_helpers")

TUNING.SHADOWWAXWELLSEESSHADOWS = GetModConfigData("SHADOWWAXWELLSEESSHADOWS")
TUNING.SHADOWWAXWELLONATTACKED = GetModConfigData("SHADOWWAXWELLONATTACKED")
TUNING.SHADOWDUELISTHEALTHABSORPTION = GetModConfigData("SHADOWDUELISTHEALTHABSORPTION")
TUNING.SHADOWWORKERHEALTHABSORPTION = GetModConfigData("SHADOWWORKERHEALTHABSORPTION")
TUNING.SHADOWWORKERHEALTHREGENRATE = GetModConfigData("SHADOWWORKERHEALTHREGENRATE")
TUNING.SHADOWWORKERHEALTHREGEN = GetModConfigData("SHADOWWORKERHEALTHREGEN")
TUNING.SHADOWDUELISTHEALTHREGENRATE = GetModConfigData("SHADOWDUELISTHEALTHREGENRATE")
TUNING.SHADOWDUELISTHEALTHREGEN = GetModConfigData("SHADOWDUELISTHEALTHREGEN")
TUNING.SHADOWWORKERHEALTH = GetModConfigData("SHADOWWORKERHEALTH")
TUNING.SHADOWDUELISTHEALTH = GetModConfigData("SHADOWDUELISTHEALTH")
TUNING.SHADOWDUELISTATTACKPERIOD = GetModConfigData("SHADOWDUELISTATTACKPERIOD")
TUNING.SHADOWRECIPESALWAYSCRAFTABLE = GetModConfigData("SHADOWRECIPESALWAYSCRAFTABLE")
TUNING.SHADOWRECIPESENABLED = GetModConfigData("SHADOWRECIPESENABLED")
TUNING.SHADOWDUELISTDAMAGE = GetModConfigData("SHADOWDUELISTDAMAGE")
TUNING.SHADOWWAXWELL_SANITY_PENALTY =
{
    SHADOWLUMBER = GetModConfigData("SHADOWWORKERSANITYPENALTY"),
    SHADOWMINER = GetModConfigData("SHADOWWORKERSANITYPENALTY"),
    SHADOWDIGGER = GetModConfigData("SHADOWWORKERSANITYPENALTY"),
    SHADOWDUELIST = GetModConfigData("SHADOWDUELISTSANITYPENALTY"),
}

if TUNING.SHADOWRECIPESALWAYSCRAFTABLE ~= 0 then
	TECH.SHADOWRECIPESALWAYSCRAFTABLE = TECH.NONE
else
	TECH.SHADOWRECIPESALWAYSCRAFTABLE = TECH.SHADOW_TWO
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker.components.petleash ~= nil and
            data.attacker.components.petleash:IsPet(inst) then
            if inst.components.lootdropper == nil then
                inst:AddComponent("lootdropper")
            end
			if TUNING.SHADOWWAXWELLONATTACKED ~= 0 then
				inst.components.lootdropper:SpawnLootPrefab("nightmarefuel", inst:GetPosition())
			end
            data.attacker.components.petleash:DespawnPet(inst)
        elseif data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end

local function ShadowDuelistPostInit(inst)
	if inst.components.health ~= nil then
		if TUNING.SHADOWDUELISTHEALTHREGEN ~= 0 then
			inst.components.health:StartRegen(TUNING.SHADOWDUELISTHEALTHREGEN,TUNING.SHADOWDUELISTHEALTHREGENRATE)
		else
			inst.components.health:StopRegen()
		end
		if TUNING.SHADOWWAXWELLSEESSHADOWS ~= 0 then
			inst:AddTag("crazy")
		end
		inst.components.health:SetMaxHealth(TUNING.SHADOWDUELISTHEALTH)
		inst.components.health:SetAbsorptionAmount(TUNING.SHADOWDUELISTHEALTHABSORPTION)
		inst.components.combat:SetDefaultDamage(TUNING.SHADOWDUELISTDAMAGE)
		inst.components.combat:SetAttackPeriod(TUNING.SHADOWDUELISTATTACKPERIOD)
		eventhelpers.MyListenForEvent(inst,"attacked",OnAttacked)
	end
end
	
local function ShadowWorkerPostInit(inst)
	if inst.components.health ~= nil then
		if TUNING.SHADOWWORKERHEALTHREGEN ~= 0 then
			inst.components.health:StartRegen(TUNING.SHADOWWORKERHEALTHREGEN,TUNING.SHADOWWORKERHEALTHREGENRATE)
		else
			inst.components.health:StopRegen()
		end
		if TUNING.SHADOWWAXWELLSEESSHADOWS ~= 0 then
			inst:AddTag("crazy")
		end
		inst.components.health:SetAbsorptionAmount(TUNING.SHADOWWORKERHEALTHABSORPTION)
		inst.components.health:SetMaxHealth(TUNING.SHADOWWORKERHEALTH)
		eventhelpers.MyListenForEvent(inst,"attacked",OnAttacked)
	end
end

local function MaxwellPostInit(inst)
	if inst.components.petleash then
		inst.components.petleash:SetMaxPets(math.inf)
	end
end

AddPrefabPostInit("shadowlumber", ShadowWorkerPostInit)
AddPrefabPostInit("shadowminer", ShadowWorkerPostInit)
AddPrefabPostInit("shadowdigger", ShadowWorkerPostInit)
AddPrefabPostInit("shadowduelist", ShadowDuelistPostInit)
AddPrefabPostInit("waxwell", MaxwellPostInit)


modimport("scripts/recipes.lua")