local SetSharedLootTable = GLOBAL.SetSharedLootTable

local function inChanceLootTable(loot, table)
	for k, v in pairs(table) do
		if v["prefab"] == loot then
			return true
		end
	end
	return false
end

local function AddFruitFlyFruitLoot(inst)
	if inst.components.lootdropper then
		if inChanceLootTable("fruitflyfruit", inst.components.lootdropper.chanceloot) then
			return
		end
		local items = {
					{'plantmeat',     1.00},
					{'fruitflyfruit', 1.00},
				}
		SetSharedLootTable(inst, items)
		inst.components.lootdropper:SetChanceLootTable(inst)
	end
end

AddPrefabPostInit("lordfruitfly", AddFruitFlyFruitLoot)
