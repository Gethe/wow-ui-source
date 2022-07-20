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

function AllocationsMixin:Clear()
	self.allocs = {};

	self:OnChanged();
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

function AllocationsMixin:GetTransaction()
	return self.transaction;
end

function AllocationsMixin:OnChanged()
	if self.onChangedFunc ~= nil then
		self.onChangedFunc();
	end
end

function CreateProfessionsAllocations(onChangedFunc)
	local allocations = CreateAndInitFromMixin(AllocationsMixin);
	allocations.onChangedFunc = onChangedFunc;
	return allocations;
end

ProfessionsRecipeTransactionMixin = {};

function ProfessionsRecipeTransactionMixin:Init(recipeSchematic, onChangedFunc)
	self.reagentTbls = {};
	self.recipeID = recipeSchematic.recipeID;
	self.recipeSchematic = recipeSchematic;

	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		local allocations = CreateProfessionsAllocations(onChangedFunc);
		self.reagentTbls[slotIndex] = {reagentSlotSchematic = reagentSlotSchematic, allocations = allocations};
	end
end

function ProfessionsRecipeTransactionMixin:GetRecipeID()
	return self.recipeID;
end

function ProfessionsRecipeTransactionMixin:GetRecipeSchematic()
	return self.recipeSchematic;
end

function ProfessionsRecipeTransactionMixin:IsRecipeType(recipeType)
	local recipeSchematic = self:GetRecipeSchematic();
	return recipeSchematic.recipeType == recipeType;
end

function ProfessionsRecipeTransactionMixin:GetReagentTbl(slotIndex)
	return self.reagentTbls[slotIndex];
end

function ProfessionsRecipeTransactionMixin:GetQuantityRequiredInSlot(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return reagentSlotSchematic.quantityRequired;
end

function ProfessionsRecipeTransactionMixin:IsSlotRequiredToCraft(slotIndex)
	local reagentSlotSchematic = self:GetReagentSlotSchematic(slotIndex);
	return reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic;
end

function ProfessionsRecipeTransactionMixin:GetReagentSlotSchematic(slotIndex)
	local reagentTbl = self:GetReagentTbl(slotIndex);
	return reagentTbl.reagentSlotSchematic;
end

function ProfessionsRecipeTransactionMixin:AccumulateAllocations(slotIndex)
	local allocations = self:GetAllocations(slotIndex);
	return allocations:Accumulate();
end

function ProfessionsRecipeTransactionMixin:IsReagentAllocated(slotIndex, reagent)
	local allocations = self:GetAllocations(slotIndex);
	return allocations and (allocations:FindAllocationByReagent(reagent) ~= nil);
end

function ProfessionsRecipeTransactionMixin:GetAllocations(slotIndex)
	local reagentTbl = self:GetReagentTbl(slotIndex);
	return reagentTbl.allocations;
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
	local tbl = {};
	local recipeSchematic = self:GetRecipeSchematic();
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		local allocations = self:GetAllocations(slotIndex);
		if allocations then
			table.insert(tbl, allocations);
		end
	end
	return CreateTableEnumerator(tbl);
end

function ProfessionsRecipeTransactionMixin:EnumerateAllSlotReagents()
	local tbl = {};
	local recipeSchematic = self:GetRecipeSchematic();
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		table.insert(tbl, reagentSlotSchematic.reagents);
	end
	return CreateTableEnumerator(tbl);
end

function ProfessionsRecipeTransactionMixin:OnChanged()
	EventRegistry:TriggerEvent("Professions.TransactionUpdated");
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
	return allocations:HasAllocations();
end

function ProfessionsRecipeTransactionMixin:ClearSalvageAllocations()
	self:SetSalvageAllocation(nil);
end

function ProfessionsRecipeTransactionMixin:SetSalvageAllocation(salvageItem)
	self.salvageItem = salvageItem;
end

function ProfessionsRecipeTransactionMixin:GetSalvageAllocation()
	return self.salvageItem;
end

function ProfessionsRecipeTransactionMixin:HasAllocatedSalvageRequirements()
	if not self:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		return false;
	end

	return self.salvageItem ~= nil;
end

function ProfessionsRecipeTransactionMixin:HasAllocatedReagentRequirements()
	if not self:IsRecipeType(Enum.TradeskillRecipeType.Item) then
		return false;
	end

	for slotIndex, reagentTbl in self:Enumerate() do
		local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
		if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
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

function ProfessionsRecipeTransactionMixin:CreateCraftingReagentInfoTblIf(predicate)
	local tbl = {};
	for slotIndex, reagentTbl in self:Enumerate() do
		if predicate(reagentTbl) then
			local reagentSlotSchematic = reagentTbl.reagentSlotSchematic;
			local mcrSlotIndex = reagentSlotSchematic.mcrSlotIndex;
			for index, allocation in reagentTbl.allocations:Enumerate() do
				local quantity = allocation:GetQuantity();
				if quantity > 0 then
					-- CraftingReagentInfo can only ever be initialized with items, so we can disregard currency here.
					local reagent = allocation:GetReagent();
					local craftingReagentInfo = Professions.CreateCraftingReagentInfo(reagent.itemID, mcrSlotIndex, quantity);
					table.insert(tbl, craftingReagentInfo);
				end
			end
		end
	end
	return tbl;
end

function ProfessionsRecipeTransactionMixin:CreateOptionalCraftingReagentInfoTbl()
	local function IsOptionalReagentType(reagentTbl)
		return reagentTbl.reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Optional;
	end
	return self:CreateCraftingReagentInfoTblIf(IsOptionalReagentType);
end

function ProfessionsRecipeTransactionMixin:CreateCraftingReagentInfoTbl()
	local function IsModifiedCraftingReagent(reagentTbl)
		return reagentTbl.reagentSlotSchematic.mcrSlotIndex ~= nil;
	end
	return self:CreateCraftingReagentInfoTblIf(IsModifiedCraftingReagent);
end

function CreateProfessionsRecipeTransaction(recipeSchematic, onChangedFunc)
	local transaction = CreateFromMixins(ProfessionsRecipeTransactionMixin);
	transaction:Init(recipeSchematic, onChangedFunc);
	return transaction;
end