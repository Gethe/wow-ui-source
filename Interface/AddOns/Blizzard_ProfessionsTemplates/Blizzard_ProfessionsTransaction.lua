local function AssertReagentArgumentValid(reagent)
	if not Professions.IsValidReagent(reagent) then
		assert(false, "AssertReagentArgumentValid: Argument 'reagent' is invalid.");
	end
end

local function AssertReagentArgumentNonNil(reagent)
	if reagent == nil then
		assert(false, "AssertReagentArgumentNonNil: Argument 'reagent' is nil.");
	end
end

local function ReagentToTableKey(reagent)
	if reagent.itemID then
		return reagent.itemID;
	end

	if reagent.currencyID then
		return reagent.currencyID;
	end

	return nil;
end

local AllocationMixin = {};

function AllocationMixin:Init(reagent, quantity)
	AssertReagentArgumentValid(reagent);

	self:SetReagent(reagent);
	self:SetQuantity(quantity);
end

function AllocationMixin:GetReagent()
	return self.reagent;
end

function AllocationMixin:SetReagent(reagent)
	AssertReagentArgumentValid(reagent);

	self.reagent = reagent;
end

function AllocationMixin:GetQuantity()
	return self.quantity;
end

function AllocationMixin:SetQuantity(quantity)
	self.quantity = quantity;
end

function AllocationMixin:MatchesReagent(reagent)
	AssertReagentArgumentNonNil(reagent);

	return ProfessionsUtil.CraftingReagentMatches(self.reagent, reagent);
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

function AllocationsMixin:GetSize()
	return #self.allocs;
end

function AllocationsMixin:Enumerate(indexBegin, indexEnd)
	return CreateTableEnumerator(self.allocs, indexBegin, indexEnd);
end

function AllocationsMixin:GetFirstAllocation()
	return self.allocs[1];
end

function AllocationsMixin:FindAllocationByPredicate(predicate)
	local key, allocation = FindInTableIf(self.allocs, predicate);
	return allocation;
end

function AllocationsMixin:FindAllocationByReagent(reagent)
	AssertReagentArgumentNonNil(reagent);

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

function AllocationsMixin:HasAnyAllocations()
	return self:Accumulate() > 0;
end

function AllocationsMixin:Allocate(reagent, quantity)
	AssertReagentArgumentValid(reagent);

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
	self.exemptedReagents = {};
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

	self.applyConcentration = false;
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

function ProfessionsRecipeTransactionMixin:GetQuantityRequiredInSlot(slotIndex, reagent)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	if reagent then
		return reagentSlotSchematic:GetQuantityRequired(reagent);
	end
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
	return ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic);
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

function ProfessionsRecipeTransactionMixin:IsAllocatedAsModification(reagent, slotIndex)
	local modification = self:GetModificationAtSlotIndex(slotIndex);
	if not modification then
		return false;
	end

	return Professions.DoesModificationContainReagent(modification, reagent);
end

local function DoesReagentSlotSupportModification(reagentSlotSchematic)
	return (reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent) and
			(reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Modifying);
end

function ProfessionsRecipeTransactionMixin:GetCraftingReagentInfos()
	if self:IsManuallyAllocated() then
		return self:CreateCraftingReagentInfoTbl();
	end

	return self:CreateOptionalOrFinishingCraftingReagentInfoTbl();
end

function ProfessionsRecipeTransactionMixin:RecraftRecipe()
	local craftingReagentTbl = self:CreateCraftingReagentInfoTbl();
	local removedModifications = Professions.PrepareRecipeRecraft(self, craftingReagentTbl);

	local result = C_TradeSkillUI.RecraftRecipe(self:GetRecraftAllocation(), craftingReagentTbl, removedModifications, self:IsApplyingConcentration());
	if result then
		-- Create an expected table of item modifications so that we don't incorrectly deallocate
		-- an item modification slot on form refresh that has just been installed but hasn't been stamped
		-- with the item modification yet.
		local modsCopy = CopyTable(self.recraftItemMods);
		for index, modification in ipairs(modsCopy) do
			modification.reagent = {};
		end

		self:ClearExemptedReagents();

		for slotIndex, reagentSlotSchematic in ipairs(self.recipeSchematic.reagentSlotSchematics) do
			if DoesReagentSlotSupportModification(reagentSlotSchematic) then
				local dataSlotIndex = reagentSlotSchematic.dataSlotIndex;
				local modification = modsCopy[dataSlotIndex];

				local allocations = self:GetAllocations(slotIndex);
				local allocation = allocations:GetFirstAllocation();
				local reagent = allocation and allocation:GetReagent();
				if reagent then
					modification.reagent = CopyTable(reagent);

					self:SetExemptedReagent(modification.reagent, dataSlotIndex);
				end
			end
		end

		self.recraftExpectedItemMods = modsCopy;
	end
	return result;
end

--[[
The recipe id may be different than the schematic recipe id if this is for a legacy recipe where multiple recipe ids were
used to implement varied levels of the item.
]]
function ProfessionsRecipeTransactionMixin:CraftRecipe(recipeID, count, recipeLevel)
	local craftingOrderID = nil;
	C_TradeSkillUI.CraftRecipe(recipeID, count, self:GetCraftingReagentInfos(),
		recipeLevel, craftingOrderID, self:IsApplyingConcentration());
end

function ProfessionsRecipeTransactionMixin:CraftEnchant(recipeID, count)
	C_TradeSkillUI.CraftEnchant(recipeID, count, self:GetCraftingReagentInfos(),
		self:GetEnchantAllocation():GetItemLocation(), self:IsApplyingConcentration());
end

function ProfessionsRecipeTransactionMixin:CraftSalvage(count)
	local itemLocation = C_Item.GetItemLocation(self:GetSalvageAllocation():GetItemGUID());
	C_TradeSkillUI.CraftSalvage(self.recipeID, count, itemLocation, self:CreateCraftingReagentInfoTbl(), self:IsApplyingConcentration());
end

function ProfessionsRecipeTransactionMixin:SanitizeAllocationsInternal(index, allocations)
	local valid = true;
	for allocationsIndex, allocs in allocations:Enumerate() do
		if valid then
			local reagent = allocs:GetReagent();
			-- If the allocation is a current or pending item modification in recrafting
			-- then we don't discard it -- it needs to remain in the allocation list
			-- because it currently represents a "no change" operation.

			if (not self:IsAllocatedAsModification(reagent, index)) and (not self:IsReagentSanitizationExempt(reagent)) then
				local owned = ProfessionsUtil.GetReagentQuantityInPossession(reagent, self.useCharacterInventoryOnly);
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

function ProfessionsRecipeTransactionMixin:IsReagentSanitizationExempt(reagent)
	AssertReagentArgumentValid(reagent);

	return self.exemptedReagents[ReagentToTableKey(reagent)];
end

function ProfessionsRecipeTransactionMixin:SetExemptedReagent(reagent, dataSlotIndex)
	AssertReagentArgumentValid(reagent);

	self.exemptedReagents[ReagentToTableKey(reagent)] = dataSlotIndex;
end

function ProfessionsRecipeTransactionMixin:ClearExemptedReagents()
	self.exemptedReagents = {};
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

function ProfessionsRecipeTransactionMixin:SanitizeRecraftAllocation(clearExpectedItemMods)
	local itemGUID = self:GetRecraftAllocation();
	if itemGUID and not C_Item.IsItemGUIDInInventory(itemGUID) then
		self:ClearRecraftAllocation();
	end

	if clearExpectedItemMods then
		self.recraftExpectedItemMods = nil;
	end
	self:CacheItemModifications();
end

function ProfessionsRecipeTransactionMixin:SanitizeEnchantAllocation()
	local item = self:GetEnchantAllocation();
	local itemGUID = item and item:GetItemGUID() or nil;
	if itemGUID and not C_Item.IsItemGUIDInInventory(itemGUID) then
		self:ClearEnchantAllocations();
	end
end

function ProfessionsRecipeTransactionMixin:SanitizeSalvageAllocation()
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

function ProfessionsRecipeTransactionMixin:HasAnyAllocations(slotIndex)
	local allocations = self:GetAllocations(slotIndex);
	return allocations and allocations:HasAnyAllocations();
end

function ProfessionsRecipeTransactionMixin:HasAllAllocations(slotIndex)
	local allocations = self:GetAllocations(slotIndex);
	if allocations then
		local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
		if reagentSlotSchematic:HasVariableQuantities() then
			-- Slots with variable quantity reagents expect one reagent to satisfy
			-- the required quantity.
			for reagentIndex, reagent in ipairs(reagentSlotSchematic.reagents) do
				local quantityRequired = reagentSlotSchematic:GetQuantityRequired(reagent);
				local quantityAllocated = allocations:GetQuantityAllocated(reagent);
				if quantityAllocated >= quantityRequired then
					return true;
				end
			end
		else
			local quantityRequired = reagentSlotSchematic.quantityRequired;
			local quantityAllocated = 0;
			for reagentIndex, reagent in ipairs(reagentSlotSchematic.reagents) do
				local allocation = allocations:FindAllocationByReagent(reagent);
				quantityAllocated = quantityAllocated + (allocation and allocation:GetQuantity() or 0);
				if quantityAllocated >= quantityRequired then
					return true;
				end
			end
		end
	end

	return false;
end

function ProfessionsRecipeTransactionMixin:HasAllocatedReagent(reagent)
	AssertReagentArgumentNonNil(reagent);

	for index, allocations in self:EnumerateAllAllocations() do
		if allocations:FindAllocationByReagent(reagent) then
			return true;
		end
	end
	return false;
end

function ProfessionsRecipeTransactionMixin:HasAllocatedItemID(itemID)
	local reagent = Professions.CreateItemReagent(itemID);
	return self:HasAllocatedReagent(reagent);
end

function ProfessionsRecipeTransactionMixin:HasAllocatedCurrencyID(currencyID)
	local reagent = Professions.CreateCurrencyReagent(currencyID);
	return self:HasAllocatedReagent(reagent);
end

-- Reagent requirements are separate reagents that must also be allocated in order for
-- the argument reagent to be considered valid. 
function ProfessionsRecipeTransactionMixin:AreDependentReagentsAllocated(reagent)
	AssertReagentArgumentValid(reagent);

	local dependentReagents = C_TradeSkillUI.GetDependentReagents(reagent);
	for index, dependentReagent in ipairs(dependentReagents) do
		if not self:HasAllocatedReagent(dependentReagent) then
			return false;
		end
	end
	return true;
end

function ProfessionsRecipeTransactionMixin:AreDependentReagentsAllocatedByCurrencyID(currencyID)
	local reagent = Professions.CreateCurrencyReagent(currencyID);
	return self:AreDependentReagentsAllocated(reagent);
end

function ProfessionsRecipeTransactionMixin:AreDependentReagentsAllocatedByItemID(itemID)
	local reagent = Professions.CreateItemReagent(itemID);
	return self:AreDependentReagentsAllocated(reagent);
end

function ProfessionsRecipeTransactionMixin:AreDependentReagentsAllocatedByItem(item)
	return self:AreDependentReagentsAllocatedByItemID(item:GetItemID());
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
	if self.recraftItemGUID then
		self.recraftItemMods = C_TradeSkillUI.GetItemSlotModifications(self.recraftItemGUID);
	elseif self.recraftOrderID then
		self.recraftItemMods = C_TradeSkillUI.GetItemSlotModificationsForOrder(self.recraftOrderID);
	else
		self.recraftItemMods = nil;
	end

	if self.recraftExpectedItemMods then
		-- Do not continue past this point because we're waiting on the server to notify the client
		-- that the item was successfully stamped with new item modifications.
		return;
	end

	if self.recraftItemMods then
		self:ClearExemptedReagents();

		for dataSlotIndex, modification in ipairs(self.recraftItemMods) do
			if Professions.IsValidReagent(modification.reagent) then
				self:SetExemptedReagent(modification.reagent, dataSlotIndex);
			end
		end
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
	local modification = self:GetModification(dataSlotIndex);
	if modification then
		modification.reagent = {};
	end
end

-- Modifications are only present in recrafting contexts.
function ProfessionsRecipeTransactionMixin:HasModifications()
	return self:GetModificationTable() ~= nil;
end

function ProfessionsRecipeTransactionMixin:GetModificationTable()
	--[[
	The expected mods table has priority over the regular mods table when the
	the crafting attempt is in-transit to the server so that any queries
	into the transaction state refer to the mods we expect to be applied.
	]]--
	return self.recraftExpectedItemMods or self.recraftItemMods;
end

local function GetModificationInTable(modificationTable, dataSlotIndex)
	return modificationTable and modificationTable[dataSlotIndex] or nil;
end

function ProfessionsRecipeTransactionMixin:GetModification(dataSlotIndex)
	return GetModificationInTable(self:GetModificationTable(), dataSlotIndex);
end

function ProfessionsRecipeTransactionMixin:GetModificationAtSlotIndex(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return self:GetModification(reagentSlotSchematic.dataSlotIndex);
end

function ProfessionsRecipeTransactionMixin:IsModificationUnchangedAtSlotIndex(slotIndex)
	local modification = self:GetModificationAtSlotIndex(slotIndex);
	return modification and self:HasAllocatedReagent(modification.reagent);
end

function ProfessionsRecipeTransactionMixin:GetOriginalModification(dataSlotIndex)
	if self.recraftOrderID then
		-- Recrafting an order does not display previous modifications
		return nil;
	end
	return GetModificationInTable(self.recraftItemMods, dataSlotIndex);
end

function ProfessionsRecipeTransactionMixin:HasModification(dataSlotIndex)
	local modification = self:GetModification(dataSlotIndex);
	return Professions.IsValidModification(modification);
end

function ProfessionsRecipeTransactionMixin:HasMetAllRequirements()
	if self:FailsSalvageRequirements() then
		return false;
	end

	if self:FailsQuantityRequirements() then
		return false;
	end

	if self:HasMissingDependentReagents() then
		return false;
	end

	return true;
end

function ProfessionsRecipeTransactionMixin:FailsSalvageRequirements()
	if not self:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		return false;
	end

	if not self.salvageItem then
		return true;
	end

	local recipeSchematic = self:GetRecipeSchematic();
	local quantity = self.salvageItem:GetStackCount() or 0;
	return quantity < recipeSchematic.quantityMax;
end

function ProfessionsRecipeTransactionMixin:FailsQuantityRequirements()
	for slotIndex, reagentTbl in self:Enumerate() do
		local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
		if ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic) then
			if not self:HasAllAllocations(slotIndex) then
				return true;
			end
		end
	end

	return false;
end

function ProfessionsRecipeTransactionMixin:HasMissingDependentReagents()
	for slotIndex, reagentTbl in self:Enumerate() do
		local allocations = self:GetAllocations(slotIndex);
		local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
		for reagentIndex, reagent in ipairs(reagentSlotSchematic.reagents) do
			-- If the reagent is allocated, we need to check if any dependent reagents
			-- are also allocated. An example of this is Crest reagents that can only
			-- be used if a Spark is also allocated.
			local allocation = allocations:FindAllocationByReagent(reagent);
			if allocation and not self:AreDependentReagentsAllocated(reagent) then
				return true;
			end
		end
	end
	
	return false;
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
					local reagent = allocation:GetReagent();
					local craftingReagentInfo = Professions.CreateCraftingReagentInfo(reagent, dataSlotIndex, quantity);
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

function ProfessionsRecipeTransactionMixin:CreateReagentInfoTbl()
	local function IsReagent(reagentTbl)
		local dataSlotType = reagentTbl.reagentSlotSchematic.dataSlotType;
		return dataSlotType == Enum.TradeskillSlotDataType.Reagent or
			dataSlotType == Enum.TradeskillSlotDataType.Currency;
	end
	return self:CreateCraftingReagentInfoTblIf(IsReagent);
end

function ProfessionsRecipeTransactionMixin:CreateRegularItemReagentInfoTbl()
	local function IsRegularItemReagent(reagentTbl)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.Reagent;
	end
	return self:CreateCraftingReagentInfoTblIf(IsRegularItemReagent);
end

function ProfessionsRecipeTransactionMixin:CreateRegularCurrencyReagentInfoTbl()
	local function IsRegularCurrencyReagent(reagentTbl)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.Currency;
	end
	return self:CreateCraftingReagentInfoTblIf(IsRegularCurrencyReagent);
end

function ProfessionsRecipeTransactionMixin:IsApplyingConcentration()
	return self.applyConcentration;
end

function ProfessionsRecipeTransactionMixin:SetApplyConcentration(applyConcentration)
	if self.applyConcentration ~= applyConcentration then
		self.applyConcentration = applyConcentration;

		-- Update stat lines
		self:CallOnChangedHandler();

		-- Update toggle button state
		self:OnChanged();
	end
end

function ProfessionsRecipeTransactionMixin:SetUseCharacterInventoryOnly(useCharacterInventoryOnly)
	self.useCharacterInventoryOnly = useCharacterInventoryOnly;
end

function ProfessionsRecipeTransactionMixin:ShouldUseCharacterInventoryOnly()
	return self.useCharacterInventoryOnly;
end

function CreateProfessionsRecipeTransaction(recipeSchematic)
	local transaction = CreateFromMixins(ProfessionsRecipeTransactionMixin);
	transaction:Init(recipeSchematic);
	return transaction;
end
