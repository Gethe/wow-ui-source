ProfessionsReagentSlotMixin = {};

function ProfessionsReagentSlotMixin:Reset()
	self.Button.QualityOverlay:SetAtlas(nil);
	self:SetAllocateIconShown(false);
	self.unallocatable = nil;
	self.originalItem = nil;
	self.UndoButton:Hide();
	self.CustomerState:Hide();
	self.Button:Reset();
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end
	self.continuableContainer = ContinuableContainer:Create();
end

function ProfessionsReagentSlotMixin:Init(transaction, reagentSlotSchematic)
	self:Reset();
	
	self:SetTransaction(transaction);
	self:SetReagentSlotSchematic(reagentSlotSchematic);

	for index, reagent in ipairs(reagentSlotSchematic.reagents) do
		if reagent.itemID then
			local item = Item:CreateFromItemID(reagent.itemID);
			self.continuableContainer:AddContinuable(item);
		end
	end

	local function OnItemsLoaded()
		self.Name:Show();

		local function InitButton()
			local allocations = transaction:GetAllocations(self:GetSlotIndex());
			for index, allocation in allocations:Enumerate() do
				local reagent = allocation:GetReagent();
				self:SetItem(Item:CreateFromItemID(reagent.itemID));
				break;
			end
		end
		
		local modification = transaction:GetModification(reagentSlotSchematic.dataSlotIndex);
		if modification and modification.itemID > 0 then
			self:SetOriginalItem(Item:CreateFromItemID(modification.itemID));
		end

		local reagentType = reagentSlotSchematic.reagentType;
		if reagentType == Enum.CraftingReagentType.Basic then
			if Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
				self.Button.noProfessionQualityOverlay = true;
			end

			local reagent = reagentSlotSchematic.reagents[1];
			self.Button:SetItem(reagent.itemID);
		elseif reagentType == Enum.CraftingReagentType.Optional then
			local slotInfo = reagentSlotSchematic.slotInfo;
			self:SetNameText(slotInfo.slotText or OPTIONAL_REAGENT_POSTFIX);

			InitButton();
		elseif reagentType == Enum.CraftingReagentType.Finishing then
			self.Name:Hide();

			InitButton();
		end

		self:Update();
	end

	self.continuableContainer:ContinueOnLoad(OnItemsLoaded);

	self.Button:SetScript("OnLeave", function()
		self.Button.InputOverlay.AddIconHighlight:SetShown(false);
		GameTooltip:Hide();
	end);
end

function ProfessionsReagentSlotMixin:Update()
	self:UpdateAllocationText();
	self:UpdateQualityOverlay();

	if self.Name:IsShown() and self.nameText ~= nil then
		local transaction = self:GetTransaction();
		local color = (self:GetReagentSlotSchematic().reagentType == Enum.CraftingReagentType.Optional or transaction:HasAllocations(self:GetSlotIndex()))
					  and HIGHLIGHT_FONT_COLOR 
					  or DISABLED_REAGENT_COLOR;
		self.Name:SetText(color:WrapTextInColorCode(self.nameText));
	end
end

function ProfessionsReagentSlotMixin:UpdateAllocationText()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
		-- First try only allocations
		local foundMultiple, foundIndex = self:GetAllocationDetails();

		-- Then include inventory if necessary
		if not foundMultiple and not foundIndex then
			foundMultiple, foundIndex = self:GetInventoryDetails();
		end

		local quantity = 0;
		if foundMultiple then
			quantity = TRADESKILL_QUANTITY_MULTIPLE;
		else
			if foundIndex then
				local reagent = reagentSlotSchematic.reagents[foundIndex];
				quantity = Professions.GetReagentQuantityInPossession(reagent);
			else
				quantity = Professions.AccumulateReagentsInPossession(reagentSlotSchematic.reagents);
			end
		end

		local reagent = reagentSlotSchematic.reagents[1];
		local item = Item:CreateFromItemID(reagent.itemID);
		self:SetNameText(("%s %s"):format(TRADESKILL_REAGENT_COUNT:format(quantity, reagentSlotSchematic.quantityRequired), item:GetItemName()));
	end
end

function ProfessionsReagentSlotMixin:GetAllocationDetails()
	local transaction = self:GetTransaction();
	local foundMultiple = nil;
	local foundIndex = nil;
	local quantities = Professions.GetQuantitiesAllocated(transaction, self:GetReagentSlotSchematic());
	for index, quantity in ipairs(quantities) do
		if quantity > 0 then
			if foundIndex then
				foundMultiple = true;
			end
			foundIndex = index;
		end
	end
	return foundMultiple, foundIndex;
end

function ProfessionsReagentSlotMixin:GetInventoryDetails()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	local foundMultiple = nil;
	local foundIndex = nil;
	for index, reagent in ipairs(reagentSlotSchematic.reagents) do
		local quantity = Professions.GetReagentQuantityInPossession(reagent);
		if quantity > 0 then
			if foundIndex then
				foundMultiple = true;
			end
			foundIndex = index;
		end
	end
	return foundMultiple, foundIndex;
end

function ProfessionsReagentSlotMixin:UpdateQualityOverlay()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	if Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
		-- First try only allocations
		local foundMultiple, foundIndex = self:GetAllocationDetails();

		-- Then include inventory if necessary
		if not foundMultiple and not foundIndex then
			foundMultiple, foundIndex = self:GetInventoryDetails();
		end

		if foundMultiple then
			self.Button.QualityOverlay:SetAtlas("Professions-Icon-Quality-Mixed-Inv", TextureKitConstants.UseAtlasSize);
		elseif foundIndex then
			self.Button.QualityOverlay:SetAtlas(("Professions-Icon-Quality-Tier%d-Inv"):format(foundIndex), TextureKitConstants.UseAtlasSize);
		else
			self.Button.QualityOverlay:SetAtlas(nil);
		end
	end
end

function ProfessionsReagentSlotMixin:SetNameText(text)
	self.nameText = text;
end

function ProfessionsReagentSlotMixin:SetUnallocatable(unallocatable)
	self.unallocatable = unallocatable;
end

function ProfessionsReagentSlotMixin:IsUnallocatable()
	return self.unallocatable;
end

function ProfessionsReagentSlotMixin:ClearItem()
	self:SetItem(nil);
end

function ProfessionsReagentSlotMixin:RestoreOriginalItem()
	self:SetItem(self.originalItem);
end

function ProfessionsReagentSlotMixin:SetOriginalItem(item)
	self.originalItem = item;
end

function ProfessionsReagentSlotMixin:SetItem(item)
	self.Button:Reset();

	if item then
		self.Button:SetItem(item:GetItemID());
		self:SetNameText(item:GetItemName());
	else
		local reagentSlotSchematic = self:GetReagentSlotSchematic();
		local slotInfo = reagentSlotSchematic.slotInfo;
		self:SetNameText(slotInfo.slotText or OPTIONAL_REAGENT_POSTFIX);
	end

	if not self.originalItem or Item:DoItemsMatch(self.originalItem, item) then
		self.UndoButton:Hide();
	else
		self.UndoButton:Show();
	end

	self:Update();
end

function ProfessionsReagentSlotMixin:GetSlotIndex()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	return reagentSlotSchematic.slotIndex;
end

function ProfessionsReagentSlotMixin:SetTransaction(transaction)
	self.transaction = transaction;
end

function ProfessionsReagentSlotMixin:GetTransaction()
	return self.transaction;
end

function ProfessionsReagentSlotMixin:SetReagentSlotSchematic(reagentSlotSchematic)
	self.reagentSlotSchematic = reagentSlotSchematic;
end

function ProfessionsReagentSlotMixin:GetReagentSlotSchematic()
	return self.reagentSlotSchematic;
end

function ProfessionsReagentSlotMixin:SetAllocateIconShown(shown)
	self.Button.AddIcon:SetShown(shown);
end