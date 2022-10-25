ProfessionsCraftingQueue = {};

function ProfessionsCraftingQueue:CalculatePartitions(transaction, count, ascending)
	count = count or math.huge;
	self.partitions = {};

	local inventory = {};
	local recipeSchematic = transaction:GetRecipeSchematic();
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
			local inventoryTbl = {
				reagentSlotSchematic = reagentSlotSchematic,
				required = reagentSlotSchematic.quantityRequired, 
				reagentTbls = {},
			};
			table.insert(inventory, inventoryTbl);

			local iterator = ascending and ipairs or ipairs_reverse;
			for reagentIndex, reagent in iterator(reagentSlotSchematic.reagents) do
				local dataSlotIndex = reagentSlotSchematic.dataSlotIndex;
				local quantity = Professions.GetReagentQuantityInPossession(reagent);
				table.insert(inventoryTbl.reagentTbls, {
					itemID = reagent.itemID, 
					quantity = quantity, 
					dataSlotIndex = dataSlotIndex,
				});
			end
		end
	end

	-- Optionals and finishers are all quantity 1 and can be appended to each partition because we've already
	-- determined we have at least [count] of them.
	local optionalAndFinishingReagentTbl = transaction:CreateOptionalOrFinishingCraftingReagentInfoTbl();

	while count > 0 do
		local pass = false;
		local craftingReagentInfos = {};
		for slotIndex, inventoryTbl in ipairs(inventory) do
			local reagentSlotSchematic = inventoryTbl.reagentSlotSchematic;
			local required = inventoryTbl.required;
			local reagentTbls = inventoryTbl.reagentTbls;

			for index, reagentTbl in ipairs(reagentTbls) do
				local newQuantity = math.min(reagentTbl.quantity, required);
				reagentTbl.quantity = reagentTbl.quantity - newQuantity;
				required = required - newQuantity;

				if newQuantity > 0 then
					if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
						local craftingReagentInfo = Professions.CreateCraftingReagentInfo(reagentTbl.itemID, reagentTbl.dataSlotIndex, newQuantity);
						table.insert(craftingReagentInfos, craftingReagentInfo);
					end
				end

				if required <= 0 then
					break;
				end
			end

			assert(required >= 0);
			pass = required == 0;
			if not pass then
				break;
			end
		end

		if pass then
			local partition = self.partitions[#self.partitions];
			local depth = 3;
			if partition and tCompare(partition.craftingReagentInfos, craftingReagentInfos, depth) then
				partition.quantity = partition.quantity + 1;
			else
				tAppendAll(craftingReagentInfos, optionalAndFinishingReagentTbl);
				table.insert(self.partitions, {
					quantity = 1, 
					craftingReagentInfos = craftingReagentInfos,
				});
			end
			count = count - 1;
		else
			break;
		end
	end

	--Dump(self.partitions);
end

function ProfessionsCraftingQueue:SetPartitions(transaction, quantity)
	local craftingReagentInfos = transaction:CreateCraftingReagentInfoTbl();
	self.partitions = {{
			quantity = quantity,
			craftingReagentInfos = CopyTable(craftingReagentInfos),
		}
	};

	--Dump(self.partitions);
end

function ProfessionsCraftingQueue:GetTotal()
	return AccumulateOp(self.partitions, function(partition)
		return partition.quantity;
	end);
end

function ProfessionsCraftingQueue:Front()
	return self.partitions[1];
end

function ProfessionsCraftingQueue:Pop()
	return table.remove(self.partitions, 1);
end

function CreateProfessionsCraftingQueue()
	return CreateFromMixins(ProfessionsCraftingQueue);
end