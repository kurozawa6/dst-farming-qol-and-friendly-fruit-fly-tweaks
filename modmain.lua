local SetSharedLootTable = GLOBAL.SetSharedLootTable

local function AddFruitFlyFruitLoot(inst)
	if inst.components.lootdropper ~= nil then
		local mystery = 'cutgrass'
		if inst.components.lootdropper.chanceloot[1]["prefab"] == "fruitflyfruit" then
			mystery = 'powcake'
		else
			mystery = 'cutgrass'
		end
		local items = {
					{'plantmeat',             1.00},
					{mystery,         1.00},
				}
		SetSharedLootTable(inst, items)
		inst.components.lootdropper:SetChanceLootTable(inst)
	end
end

AddPrefabPostInit("lordfruitfly", AddFruitFlyFruitLoot)
