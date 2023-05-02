local AllocationMixin = {};

function AllocationMixin:Init(reagent, quantity)
	self:SetReagent(reagent);
	self:SetQuantity(quantity);
end

function AllocationMixin:GetReagent()
	return self.reagent;
end

function AllocationMixin:SetReagent(reagent)
	self.reagent = reagent;
end

function AllocationMixin:GetQuantity()
	return self.quantity;
end

function AllocationMixin:SetQuantity(quantity)
	self.quantity = quantity;
end

function AllocationMixin:MatchesReagent(reagent)
	return Professions.CraftingReagentMatches(self.reagent, reagent);
end

function CreateAllocation(reagent, quantity)
	return CreateAndInitFromMixin(AllocationMixin, reagent, quantity);
end

local AllocationsMixin = {};

function AllocationsMixin:Init()
	self:Clear();
end

function AllocationsMixin:SetOnChangedHandler(onChangedFunc)
	self.onChangedFunc = onChangedFunc;
end

function AllocationsMixin:Clear()
	self.allocs = {};
	self:OnChanged();
end


function AllocationsMixin:SelectFirst()
	return self.allocs[1];
end

function AllocationsMixin:Enumerate(indexBegin, indexEnd)
	return CreateTableEnumerator(self.allocs, indexBegin, indexEnd);
end

function AllocationsMixin:FindAllocationByPredicate(predicate)
	local key, allocation = FindInTableIf(self.allocs, predicate);
	return allocation;
end

function AllocationsMixin:FindAllocationByReagent(reagent)
	local function MatchesReagent(allocation)
		return allocation:MatchesReagent(reagent);
	end
	return self:FindAllocationByPredicate(MatchesReagent);
end

function AllocationsMixin:GetQuantityAllocated(reagent)
	local allocation = self:FindAllocationByReagent(reagent);
	return allocation and allocation:GetQuantity() or 0;
end

function AllocationsMixin:Accumulate()
	return AccumulateOp(self.allocs, function(allocation)
		return allocation:GetQuantity();
	end);
end

function AllocationsMixin:HasAllocations()
	return self:Accumulate() > 0;
end

function AllocationsMixin:Allocate(reagent, quantity)
	assert(reagent.itemID or reagent.currencyID);
	local allocation = self:FindAllocationByReagent(reagent);
	if quantity <= 0 then
		if allocation then
			tDeleteItem(self.allocs, allocation);
		end
	else
		if allocation then
			allocation:SetQuantity(quantity);
		else
			table.insert(self.allocs, CreateAllocation(reagent, quantity));
		end
	end

	self:OnChanged();
end

function AllocationsMixin:Overwrite(allocations)
	self.allocs = CopyTable(allocations.allocs);
	self:OnChanged();
end

function AllocationsMixin:OnChanged()
	if self.onChangedFunc ~= nil then
		self.onChangedFunc();
	end
	EventRegistry:TriggerEvent("Professions.AllocationUpdated", self);
end

ProfessionsRecipeTransactionMixin = {};

function ProfessionsRecipeTransactionMixin:Init(recipeSchematic)
	self.reagentTbls = {};
	self.allocationTbls = {};
	self.reagentSlotSchematicTbls = {};

	self.recipeID = recipeSchematic.recipeID;
	self.recipeSchematic = recipeSchematic;

	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		local allocations = CreateAndInitFromMixin(AllocationsMixin);
		table.insert(self.allocationTbls, allocations);
		table.insert(self.reagentSlotSchematicTbls, reagentSlotSchematic);
		self.reagentTbls[slotIndex] = {reagentSlotSchematic = reagentSlotSchematic, allocations = allocations};
	end
end

function ProfessionsRecipeTransactionMixin:HasReagentSlots()
	return #self.reagentSlotSchematicTbls > 0;
end

function ProfessionsRecipeTransactionMixin:SetAllocationsChangedHandler(onChangedFunc)
	-- onChangedFunc intended to be invoked when any synthesized slots (enchant, recraft, salvage) are changed.
	self.onChangedFunc = onChangedFunc;

	for index, allocations in self:EnumerateAllAllocations() do
		allocations:SetOnChangedHandler(onChangedFunc);
	end
end

function ProfessionsRecipeTransactionMixin:CallOnChangedHandler()
	if self.onChangedFunc then
		self.onChangedFunc();
	end
end

function ProfessionsRecipeTransactionMixin:SetManuallyAllocated(manuallyAllocated)
	self.manuallyAllocated = manuallyAllocated;
end

function ProfessionsRecipeTransactionMixin:IsManuallyAllocated()
	return self.manuallyAllocated;
end

function ProfessionsRecipeTransactionMixin:GetRecipeID()
	return self.recipeID;
end

function ProfessionsRecipeTransactionMixin:GetRecipeSchematic()
	return self.recipeSchematic;
end

function ProfessionsRecipeTransactionMixin:IsRecraft()
	local recipeSchematic = self:GetRecipeSchematic();
	return recipeSchematic.isRecraft;
end

function ProfessionsRecipeTransactionMixin:GetAllocations(slotIndex)
	return self.allocationTbls[slotIndex];
end

function ProfessionsRecipeTransactionMixin:GetReagentSlotSchematic(slotIndex)
	return self.reagentSlotSchematicTbls[slotIndex];
end

function ProfessionsRecipeTransactionMixin:IsRecipeType(recipeType)
	local recipeSchematic = self:GetRecipeSchematic();
	return recipeSchematic.recipeType == recipeType;
end

function ProfessionsRecipeTransactionMixin:GetQuantityRequiredInSlot(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return reagentSlotSchematic.quantityRequired;
end

function ProfessionsRecipeTransactionMixin:IsSlotRequired(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return reagentSlotSchematic.required;
end

function ProfessionsRecipeTransactionMixin:IsSlotBasicReagentType(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic;
end

function ProfessionsRecipeTransactionMixin:IsSlotModifyingRequired(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return Professions.IsReagentSlotModifyingRequired(reagentSlotSchematic);
end

function ProfessionsRecipeTransactionMixin:AccumulateAllocations(slotIndex)
	local allocations = self:GetAllocations(slotIndex);
	return allocations:Accumulate();
end

function ProfessionsRecipeTransactionMixin:IsReagentAllocated(slotIndex, reagent)
	local allocations = self:GetAllocations(slotIndex);
	return allocations and (allocations:FindAllocationByReagent(reagent) ~= nil);
end

function ProfessionsRecipeTransactionMixin:GetAllocationsCopy(slotIndex)
	return CopyTable(self:GetAllocations(slotIndex));
end

function ProfessionsRecipeTransactionMixin:EnumerateAllocations(slotIndex)
	local allocations = self:GetAllocations(slotIndex);
	return allocations:Enumerate();
end

function ProfessionsRecipeTransactionMixin:Enumerate(indexBegin, indexEnd)
	return CreateTableEnumerator(self.reagentTbls, indexBegin, indexEnd);
end

function ProfessionsRecipeTransactionMixin:EnumerateAllAllocations()
	return CreateTableEnumerator(self.allocationTbls);
end

function ProfessionsRecipeTransactionMixin:CollateSlotReagents()
	local tbl = {};
	for slotIndex, reagentSlotSchematic in ipairs(self.reagentSlotSchematicTbls) do
		table.insert(tbl, reagentSlotSchematic.reagents);
	end
	return tbl;
end

function ProfessionsRecipeTransactionMixin:EnumerateAllSlotReagents()
	return CreateTableEnumerator(self:CollateSlotReagents());
end

function ProfessionsRecipeTransactionMixin:OnChanged()
	EventRegistry:TriggerEvent("Professions.TransactionUpdated", self);
end

function ProfessionsRecipeTransactionMixin:IsModificationAllocated(reagent, slotIndex)
	local modification = self:GetModificationAtSlotIndex(slotIndex);
	return modification and (modification.itemID == reagent.itemID);
end

local function CanReagentSlotBeItemModification(reagentSlotSchematic)
	return (reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent) and
			(reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Modifying);
end

function ProfessionsRecipeTransactionMixin:GenerateExpectedItemModifications()
	local modsCopy = CopyTable(self.recraftItemMods);
	for index, modification in ipairs(modsCopy) do
		modification.itemID = 0;
	end

	self:ClearExemptedReagents();

	for slotIndex, reagentSlotSchematic in ipairs(self.recipeSchematic.reagentSlotSchematics) do
		if CanReagentSlotBeItemModification(reagentSlotSchematic) then
			local modification = modsCopy[reagentSlotSchematic.dataSlotIndex];

			local allocations = self:GetAllocations(slotIndex);
			local allocs = allocations:SelectFirst();
			if allocs then
				local reagent = allocs:GetReagent();
				modification.itemID = reagent.itemID;
				local dataSlotIndex = reagentSlotSchematic.dataSlotIndex;
				self:SetExemptedReagent(reagent, dataSlotIndex);
			else
				modification.itemID = 0;
			end
		end
	end

	self.recraftExpectedItemMods = modsCopy;
end

function ProfessionsRecipeTransactionMixin:SanitizeAllocationsInternal(index, allocations)
	local valid = true;
	for allocationsIndex, allocs in allocations:Enumerate() do
		if valid then
			local reagent = allocs:GetReagent();
			-- If the allocation is a current or pending item modification in recrafting
			-- then we don't discard it -- it needs to remain in the allocation list
			-- because it currently represents a "no change" operation.

			if not self:IsModificationAllocated(reagent, index) and self:IsReagentSanizationExempt(reagent) then
				local owned = Professions.GetReagentQuantityInPossession(reagent);
				local quantity = allocs:GetQuantity();
				if owned < quantity then
					valid = false;
				end
			end
		end
	end
	
	if not valid then
		allocations:Clear();
	end
end

function ProfessionsRecipeTransactionMixin:IsReagentSanizationExempt(reagent)
	if self.exemptedReagents then
		if self.exemptedReagents[reagent.itemID] then
			return false;
		end
	end
	return true;
end

function ProfessionsRecipeTransactionMixin:SetExemptedReagent(reagent, dataSlotIndex)
	if not self.exemptedReagents then
		self.exemptedReagents = {};
	end

	self.exemptedReagents[reagent.itemID] = dataSlotIndex;
end

function ProfessionsRecipeTransactionMixin:ClearExemptedReagents()
	self.exemptedReagents = nil;
end

function ProfessionsRecipeTransactionMixin:SanitizeOptionalAllocations()
	for index, allocations in ipairs_reverse(self.allocationTbls) do
		local reagentSlotSchematic = self:GetReagentSlotSchematic(index);
		if not reagentSlotSchematic.required then
			self:SanitizeAllocationsInternal(index, allocations);
		end
	end
end

function ProfessionsRecipeTransactionMixin:SanitizeAllocations()
	for index, allocations in ipairs_reverse(self.allocationTbls) do
		self:SanitizeAllocationsInternal(index, allocations);
	end
end

function ProfessionsRecipeTransactionMixin:SanitizeTargetAllocations()
	self:SanitizeRecraftAllocation();
	self:SanitizeEnchantAllocation();
	self:SanitizeSalvageAllocation();
end

function ProfessionsRecipeTransactionMixin:SanitizeRecraftAllocation(clearExpected)
	local itemGUID = self:GetRecraftAllocation();
	if itemGUID and not C_Item.IsItemGUIDInInventory(itemGUID) then
		self:ClearRecraftAllocation();
	end

	if clearExpected then
		self.recraftExpectedItemMods = nil;
	end
	self:CacheItemModifications();
end

function ProfessionsRecipeTransactionMixin:SanitizeEnchantAllocation(clearExpected)
	local item = self:GetEnchantAllocation();
	local itemGUID = item and item:GetItemGUID() or nil;
	if itemGUID and not C_Item.IsItemGUIDInInventory(itemGUID) then
		self:ClearEnchantAllocations();
	end
end

function ProfessionsRecipeTransactionMixin:SanitizeSalvageAllocation(clearExpected)
	local item = self:GetSalvageAllocation();
	local itemGUID = item and item:GetItemGUID() or nil;
	if itemGUID and not C_Item.IsItemGUIDInInventory(itemGUID) then
		self:ClearSalvageAllocations();
	end
end

function ProfessionsRecipeTransactionMixin:OverwriteAllocations(slotIndex, allocations)
	local currentAllocations = self:GetAllocations(slotIndex);
	currentAllocations:Overwrite(allocations);
end

function ProfessionsRecipeTransactionMixin:OverwriteAllocation(slotIndex, reagent, quantity)
	local allocations = self:GetAllocations(slotIndex);
	allocations:Clear();
	allocations:Allocate(reagent, quantity);
end

function ProfessionsRecipeTransactionMixin:ClearAllocations(slotIndex)
	local allocations = self:GetAllocations(slotIndex);
	allocations:Clear();
end

function ProfessionsRecipeTransactionMixin:HasAllocations(slotIndex)
	local allocations = self:GetAllocations(slotIndex);
	return allocations and allocations:HasAllocations();
end

function ProfessionsRecipeTransactionMixin:HasAllocatedReagent(reagent)
	for index, allocations in self:EnumerateAllAllocations() do
		if allocations:FindAllocationByReagent(reagent) then
			return true;
		end
	end
	return false;
end

function ProfessionsRecipeTransactionMixin:AreAllRequirementsAllocatedByItemID(itemID)
	local requirements = C_TradeSkillUI.GetReagentRequirementItemIDs(itemID);
	for index, requiredItemID in ipairs(requirements) do
		if not self:HasAllocatedItemID(requiredItemID) then
			return false;
		end
	end
	return true;
end

function ProfessionsRecipeTransactionMixin:AreAllRequirementsAllocated(item)
	return self:AreAllRequirementsAllocatedByItemID(item:GetItemID());
end

function ProfessionsRecipeTransactionMixin:HasAllocatedItemID(itemID)
	local reagent = Professions.CreateCraftingReagentByItemID(itemID);
	return self:HasAllocatedReagent(reagent);
end

function ProfessionsRecipeTransactionMixin:ClearSalvageAllocations()
	self:SetSalvageAllocation(nil);
end

function ProfessionsRecipeTransactionMixin:SetSalvageAllocation(salvageItem)
	local changed = self.salvageItem ~= salvageItem;	
	self.salvageItem = salvageItem;
	if changed then
		self:CallOnChangedHandler();
	end
end

function ProfessionsRecipeTransactionMixin:GetSalvageAllocation()
	return self.salvageItem;
end

function ProfessionsRecipeTransactionMixin:GetAllocationItemGUID()
	if self.salvageItem then
		return self.salvageItem:GetItemGUID();
	elseif self.enchantItem then
		return self.enchantItem:GetItemGUID();
	elseif self.recraftItemGUID then
		-- When setting the recraft allocation, we set the GUID directly so we can just return that.
		return self.recraftItemGUID;
	end
end

function ProfessionsRecipeTransactionMixin:ClearEnchantAllocations()
	self:SetEnchantAllocation(nil);
end

function ProfessionsRecipeTransactionMixin:SetEnchantAllocation(enchantItem)
	local changed = self.enchantItem ~= enchantItem;	
	self.enchantItem = enchantItem;
	if changed then
		self:CallOnChangedHandler();
	end
end

function ProfessionsRecipeTransactionMixin:GetEnchantAllocation()
	return self.enchantItem;
end

function ProfessionsRecipeTransactionMixin:SetRecraft(isRecraft)
	self.isRecraft = isRecraft;
end

function ProfessionsRecipeTransactionMixin:IsRecraft()
	return self.isRecraft;
end

function ProfessionsRecipeTransactionMixin:ClearRecraftAllocation()
	self:SetRecraftAllocation(nil);
	self:SetRecraftAllocationOrderID(nil);
end

function ProfessionsRecipeTransactionMixin:SetRecraftAllocation(itemGUID)
	local changed = self.recraftItemGUID ~= itemGUID;	
	self.recraftItemGUID = itemGUID;
	self:CacheItemModifications();
	if changed then
		self:CallOnChangedHandler();
	end
end

function ProfessionsRecipeTransactionMixin:SetRecraftAllocationOrderID(orderID)
	self.recraftOrderID = orderID;
	self:CacheItemModifications();
end

function ProfessionsRecipeTransactionMixin:CacheItemModifications()
	if self.recraftItemGUID or self.recraftOrderID then
		self.recraftItemMods = self.recraftItemGUID and C_TradeSkillUI.GetItemSlotModifications(self.recraftItemGUID) or C_TradeSkillUI.GetItemSlotModificationsForOrder(self.recraftOrderID);
		if not self.recraftExpectedItemMods then
			self:ClearExemptedReagents();
			for dataSlotIndex, modification in ipairs(self.recraftItemMods) do
				local reagent = Professions.CreateCraftingReagentByItemID(modification.itemID);
				self:SetExemptedReagent(reagent, dataSlotIndex);
			end
		end
	else
		self.recraftItemMods = nil;
	end
end

function ProfessionsRecipeTransactionMixin:GetRecraftItemMods()
	return self.recraftItemMods;
end

function ProfessionsRecipeTransactionMixin:GetRecraftAllocation()
	return self.recraftItemGUID, self.recraftOrderID;
end

function ProfessionsRecipeTransactionMixin:HasRecraftAllocation()
	return self.recraftItemGUID ~= nil or self.recraftOrderID ~= nil;
end

function ProfessionsRecipeTransactionMixin:ClearModification(dataSlotIndex)
	local modificationTable = self:GetModificationTable();
	local modification = modificationTable and modificationTable[dataSlotIndex]
	if modification then
		modification.itemID = 0;
	end
end

function ProfessionsRecipeTransactionMixin:GetModificationTable()
	return self.recraftExpectedItemMods or self.recraftItemMods;
end

function ProfessionsRecipeTransactionMixin:GetModification(dataSlotIndex)
	-- If expected item mods have been set then we've sent off the transaction to the
	-- server and we're waiting for the item mods to be officially stamped onto the item.
	return self:GetModificationInternal(dataSlotIndex, self:GetModificationTable());
end

function ProfessionsRecipeTransactionMixin:GetModificationAtSlotIndex(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return self:GetModification(reagentSlotSchematic.dataSlotIndex);
end

function ProfessionsRecipeTransactionMixin:IsModificationUnchangedAtSlotIndex(slotIndex)
	local modification = self:GetModificationAtSlotIndex(slotIndex);
	return modification and self:HasAllocatedItemID(modification.itemID);
end

function ProfessionsRecipeTransactionMixin:GetOriginalModification(dataSlotIndex)
	if self.recraftOrderID then
		-- Recrafting an order does not display previous modifications
		return nil;
	end
	return self:GetModificationInternal(dataSlotIndex, self.recraftItemMods);
end

function ProfessionsRecipeTransactionMixin:GetModificationInternal(dataSlotIndex, modificationTable)
	return modificationTable and modificationTable[dataSlotIndex] or nil;
end

function ProfessionsRecipeTransactionMixin:HasModification(dataSlotIndex)
	if self.recraftItemMods then
		return self.recraftItemMods[dataSlotIndex].itemID > 0;
	end
	return false;
end

function ProfessionsRecipeTransactionMixin:HasMetAllRequirements()
	if not self:HasMetSalvageRequirements() then
		return false;
	end

	if not self:HasMetQuantityRequirements() then
		return false;
	end

	if not self:HasMetPrerequisiteRequirements() then
		return false;
	end

	return true;
end

function ProfessionsRecipeTransactionMixin:HasMetSalvageRequirements()
	if self:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		if not self.salvageItem then
			return false;
		end

		local recipeSchematic = self:GetRecipeSchematic();
		local quantity = self.salvageItem:GetStackCount();
		if not quantity then
			return false;
		end
		
		local quantityRequired = recipeSchematic.quantityMax;
		return quantity >= quantityRequired;
	end

	return true;
end

function ProfessionsRecipeTransactionMixin:HasMetQuantityRequirements()
	for slotIndex, reagentTbl in self:Enumerate() do
		local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
		if Professions.IsReagentSlotRequired(reagentSlotSchematic) then
			local quantityRequired = reagentSlotSchematic.quantityRequired;
			local allocations = self:GetAllocations(slotIndex);
			for reagentIndex, reagent in ipairs(reagentSlotSchematic.reagents) do
				local allocation = allocations:FindAllocationByReagent(reagent);
				if allocation then
					quantityRequired = quantityRequired - allocation:GetQuantity();
				end
			end

			if quantityRequired > 0 then
				return false;
			end
		end
	end

	return true;
end

function ProfessionsRecipeTransactionMixin:HasMetPrerequisiteRequirements()
	for slotIndex, reagentTbl in self:Enumerate() do
		local allocations = self:GetAllocations(slotIndex);
		local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
		for reagentIndex, reagent in ipairs(reagentSlotSchematic.reagents) do
			local allocation = allocations:FindAllocationByReagent(reagent);
			if allocation and not self:AreAllRequirementsAllocatedByItemID(reagent.itemID) then
				return false;
			end
		end
	end
	
	return true;
end

function ProfessionsRecipeTransactionMixin:CreateCraftingReagentInfoTblIf(predicate)
	local tbl = {};
	for slotIndex, reagentTbl in self:Enumerate() do
		if predicate(reagentTbl, slotIndex) then
			local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
			local dataSlotIndex = reagentSlotSchematic.dataSlotIndex;
			for index, allocation in reagentTbl.allocations:Enumerate() do
				local quantity = allocation:GetQuantity();
				if quantity > 0 then
					-- CraftingReagentInfo can only ever be initialized with items, so we can disregard currency here.
					local reagent = allocation:GetReagent();
					local craftingReagentInfo = Professions.CreateCraftingReagentInfo(reagent.itemID, dataSlotIndex, quantity);
					table.insert(tbl, craftingReagentInfo);
				end
			end
		end
	end
	return tbl;
end

function ProfessionsRecipeTransactionMixin:CreateOptionalOrFinishingCraftingReagentInfoTbl()
	local function IsOptionalOrFinishing(reagentTbl)
		local reagentType = reagentTbl.reagentSlotSchematic.reagentType;
		return reagentType == Enum.CraftingReagentType.Modifying or reagentType == Enum.CraftingReagentType.Finishing;
	end
	return self:CreateCraftingReagentInfoTblIf(IsOptionalOrFinishing);
end

function ProfessionsRecipeTransactionMixin:CreateOptionalCraftingReagentInfoTbl()
	local function IsOptionalReagentType(reagentTbl)
		return reagentTbl.reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Modifying;
	end
	return self:CreateCraftingReagentInfoTblIf(IsOptionalReagentType);
end

function ProfessionsRecipeTransactionMixin:CreateCraftingReagentInfoTbl()
	local function IsModifiedCraftingReagent(reagentTbl)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent;
	end
	return self:CreateCraftingReagentInfoTblIf(IsModifiedCraftingReagent);
end

function ProfessionsRecipeTransactionMixin:CreateRegularReagentInfoTbl()
	local function IsRegularCraftingReagent(reagentTbl)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.Reagent;
	end
	return self:CreateCraftingReagentInfoTblIf(IsRegularCraftingReagent);
end

function CreateProfessionsRecipeTransaction(recipeSchematic)
	local transaction = CreateFromMixins(ProfessionsRecipeTransactionMixin);
	transaction:Init(recipeSchematic);
	return transaction;
end