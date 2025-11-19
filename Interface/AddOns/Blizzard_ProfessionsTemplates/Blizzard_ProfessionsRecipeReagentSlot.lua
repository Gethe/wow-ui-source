ProfessionsReagentSlotMixin = CreateFromMixins(ProfessionsRecipeSlotBaseMixin);

function ProfessionsReagentSlotMixin:Init(transaction, reagentSlotSchematic)
	ProfessionsRecipeSlotBaseMixin.Init(self);

	self:SetCheckboxShown(false);
	self:SetCheckboxCallback(nil);
	self:SetCheckboxTooltipText(nil);
	self:SetHighlightShown(false);
	local skipUpdate = true;
	self:SetOverrideNameColor(nil, skipUpdate)
	self:SetShowOnlyRequired(false, skipUpdate);
	self:SetCheckmarkShown(false);
	self:SetCheckmarkTooltipText(nil);
	self:SetOverrideQuantity(nil, skipUpdate)
	self:SetColorOverlay(nil);
	self:SetAddIconDesaturated(false);

	local isModifyingRequired = ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic);
	self.Button:SetModifyingRequired(isModifyingRequired);

	self:SetTransaction(transaction);
	self:SetReagentSlotSchematic(reagentSlotSchematic);

	Professions.ForEachItemReagent(reagentSlotSchematic.reagents, function(itemID)
		local item = Item:CreateFromItemID(itemID);
		self.continuableContainer:AddContinuable(item);
	end);

	local function OnItemsLoaded()
		self.Name:Show();
		
		local function InitButton()
			local slotIndex = self:GetSlotIndex();
			local allocations = transaction:GetAllocations(slotIndex);
			local firstAllocation = allocations:GetFirstAllocation();
			if firstAllocation then
				local reagent = firstAllocation:GetReagent();
				self:SetReagent(reagent);
			else
				self:ClearReagent();
			end
		end
		
		local modification = transaction:GetOriginalModification(reagentSlotSchematic.dataSlotIndex);
		if Professions.IsValidModification(modification) then
			local reagent = modification.reagent;
			self:SetOriginalReagent(reagent)
		end

		local reagentType = reagentSlotSchematic.reagentType;
		if reagentType == Enum.CraftingReagentType.Basic then
			if Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
				self.Button.noProfessionQualityOverlay = true;
			end

			local reagent = reagentSlotSchematic.reagents[1];
			self:SetReagent(reagent);
		elseif ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
			InitButton();
		elseif reagentType == Enum.CraftingReagentType.Modifying or reagentType == Enum.CraftingReagentType.Finishing then
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

function ProfessionsReagentSlotMixin:SetOverrideNameColor(color, skipUpdate)
	self.overrideNameColor = color;
	if not skipUpdate then
		self:Update();
	end
end

function ProfessionsReagentSlotMixin:SetOverrideQuantity(quantity, skipUpdate)
	self.overrideQuantity = quantity;
	if not skipUpdate then
		self:Update();
	end
end

function ProfessionsReagentSlotMixin:GetReagent()
	return self.Button:GetReagent();
end

function ProfessionsReagentSlotMixin:GetNameColor()
	local transaction = self:GetTransaction();

	if self.overrideNameColor then
		return self.overrideNameColor;
	end

	if self:GetReagentSlotSchematic().reagentType == Enum.CraftingReagentType.Optional or transaction:HasAnyAllocations(self:GetSlotIndex()) then
		return HIGHLIGHT_FONT_COLOR;
	end

	return DISABLED_REAGENT_COLOR;
end

function ProfessionsReagentSlotMixin:Update()
	--[[
	Accessing the item information prior to the loads being complete will
	result in a Lua error. Bail here and wait for the Update() call in the
	load complete handler.
	]]--
	if self.continuableContainer:AreAnyLoadsOutstanding() then
		return;
	end

	self:UpdateAllocationText();
	self:UpdateQualityOverlay();
	self.Button:Update();

	if self.Name:IsShown() and self.nameText ~= nil then
		self.Name:SetText(self:GetNameColor():WrapTextInColorCode(self.nameText));
	end
end

function ProfessionsReagentSlotMixin:SetShowOnlyRequired(value, skipUpdate)
	self.showOnlyRequired = value;
	if not skipUpdate then
		self:Update();
	end
end

function ProfessionsReagentSlotMixin:UpdateAllocationText()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	if not reagentSlotSchematic then
		return;
	end

	local currentReagent = self:GetReagent();
	if currentReagent then
		self:SetNameText(Professions.GetReagentName(currentReagent));
	end

	-- Optional slots do not currently use the name text.
	if not ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic) then
		return;
	end

	local slotInfo = reagentSlotSchematic.slotInfo;
	local slotText = slotInfo and slotInfo.slotText or OPTIONAL_REAGENT_POSTFIX;

	local foundMultiple, foundIndex = false, nil;
	local isModifyingRequired = ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic);
	if isModifyingRequired then
		if self:GetTransaction():IsModificationUnchangedAtSlotIndex(self:GetSlotIndex()) then
			-- The current allocation is the currently installed modification, the currently allocated reagent name will be displayed.
			return;
		end

		for allocationIndex, allocation in self:GetTransaction():EnumerateAllocations(reagentSlotSchematic.slotIndex) do
			-- Only one allocation is expected, and is an error otherwise
			assert(foundIndex == nil, "Cannot have multiple allocations within a modifying-required slot.");
			foundIndex = Professions.FindReagentInTable(reagentSlotSchematic.reagents, allocation.reagent);
		end
		
		if foundIndex == nil then
			-- There is no allocation, the slot name will be displayed.
			if reagentSlotSchematic:HasVariableQuantities() then
				self:SetNameText(slotText);
			else
				local quantityText = nil;
				if self.showOnlyRequired then
					quantityText = reagentSlotSchematic.quantityRequired;
				else
					quantityText = TRADESKILL_REAGENT_COUNT:format(0, reagentSlotSchematic.quantityRequired);
				end
				self:SetNameText(("%s %s"):format(quantityText, slotText));
			end
			return;
		end
	else
		foundMultiple, foundIndex = self:GetAllocationDetails();
	end

	-- Then include inventory if necessary
	if not foundMultiple and not foundIndex then
		foundMultiple, foundIndex = self:GetInventoryDetails();
	end

	local quantity = 0;
	if self.overrideQuantity then
		quantity = self.overrideQuantity;
	else
		if foundMultiple then
			quantity = TRADESKILL_QUANTITY_MULTIPLE;
		else
			if foundIndex then
				local reagent = reagentSlotSchematic.reagents[foundIndex];
				quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent, self:GetTransaction():ShouldUseCharacterInventoryOnly());
			else
				quantity = ProfessionsUtil.AccumulateReagentsInPossession(reagentSlotSchematic.reagents, self:GetTransaction():ShouldUseCharacterInventoryOnly());
			end
		end
	end
	
	local quantityRequired = nil;
	if foundIndex then
		local reagent = reagentSlotSchematic.reagents[foundIndex];
		quantityRequired = reagentSlotSchematic:GetQuantityRequired(reagent);
	else
		quantityRequired = reagentSlotSchematic.quantityRequired;
	end

	local quantityText = nil;
	if self.showOnlyRequired then
		quantityText = quantityRequired;
	else
		quantityText = TRADESKILL_REAGENT_COUNT:format(quantity, quantityRequired);
	end

	-- For basic slots, index 1 corresponds to either a fixed reagent or a
	-- quality reagent whose name is identical to the adjacent reagents in the table.
	local reagent = reagentSlotSchematic.reagents[foundIndex or 1];
	local reagentName = Professions.GetReagentName(reagent);
	self:SetNameText(("%s %s"):format(quantityText, reagentName));
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
	local useCharacterInventoryOnly = self:GetTransaction():ShouldUseCharacterInventoryOnly();
	for index, reagent in ipairs(reagentSlotSchematic.reagents) do
		local quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent, useCharacterInventoryOnly);
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
	local icon = nil;
	
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	if reagentSlotSchematic and Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
		-- First try only allocations
		local transaction = self:GetTransaction();
		for allocationIndex, allocation in transaction:EnumerateAllocations(reagentSlotSchematic.slotIndex) do
			local qualityInfo = Professions.GetReagentQualityInfo(allocation.reagent);
			if qualityInfo then
				if icon == nil then
					icon = qualityInfo.iconInventory;
				else
					icon = qualityInfo.iconMixed;
					break;
				end
			end
		end

		-- Then include inventory if necessary
		if icon == nil then
			local useCharacterInventoryOnly = transaction:ShouldUseCharacterInventoryOnly();
			for index, reagent in ipairs(reagentSlotSchematic.reagents) do
				local quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent, useCharacterInventoryOnly);
				if quantity > 0 then
					local qualityInfo = Professions.GetReagentQualityInfo(reagent);
					if qualityInfo then
						if icon == nil then
							icon = qualityInfo.iconInventory;
						else
							icon = qualityInfo.iconMixed;
							break;
						end
					end
				end
			end
		end
	end

	self.Button.QualityOverlay:SetAtlas(icon, TextureKitConstants.UseAtlasSize);
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

function ProfessionsReagentSlotMixin:RestoreOriginalReagent()
	self:SetReagent(self.originalReagent);
end

function ProfessionsReagentSlotMixin:IsOriginalReagentSet()
	if not self.originalReagent then
		return true;
	end

	local reagent = self:GetReagent();
	if not reagent then
		return false;
	end

	return ProfessionsUtil.CraftingReagentMatches(self.originalReagent, self:GetReagent());
end

function ProfessionsReagentSlotMixin:SetOriginalReagent(reagent)
	self.originalReagent = reagent;
end

function ProfessionsReagentSlotMixin:GetOriginalReagent()
	return self.originalReagent;
end

function ProfessionsReagentSlotMixin:SetReagent(reagent)
	self.Button:SetReagent(reagent);

	self:Update();
end

function ProfessionsReagentSlotMixin:ClearReagent()
	self.Button:Clear();

	self:Update();
end

function ProfessionsReagentSlotMixin:GetSlotIndex()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	return reagentSlotSchematic.slotIndex;
end

function ProfessionsReagentSlotMixin:GetReagentType()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	return reagentSlotSchematic.reagentType;
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

local function SetElementTooltipText(text, element, tooltipParent)
	if text then
		element:SetScript("OnEnter", function()
			GameTooltip:SetOwner(tooltipParent or element, "ANCHOR_RIGHT", 0, 0);
			GameTooltip_AddNormalLine(GameTooltip, text);
			GameTooltip:Show();
		end);
	else
		element:SetScript("OnEnter", nil);
	end
end

function ProfessionsReagentSlotMixin:SetCheckboxShown(shown)
	return self.Checkbox:SetShown(shown);
end

function ProfessionsReagentSlotMixin:SetCheckboxChecked(checked)
	self.Checkbox:SetChecked(checked);
end

function ProfessionsReagentSlotMixin:SetCheckboxEnabled(enabled)
	self.Checkbox:SetEnabled(enabled);
end

function ProfessionsReagentSlotMixin:SetCheckboxCallback(cb)
	if cb then
		self.Checkbox:SetScript("OnClick", function() cb(self.Checkbox:GetChecked()); end);
	else
		self.Checkbox:SetScript("OnClick", nil);
	end
end

function ProfessionsReagentSlotMixin:SetCheckboxTooltipText(text)
	SetElementTooltipText(text, self.Checkbox);
end

function ProfessionsReagentSlotMixin:SetHighlightShown(shown)
	self.Button.HighlightTexture:SetShown(shown);
end

function ProfessionsReagentSlotMixin:SetCheckmarkShown(shown)
	self.Checkmark:SetShown(shown);
end

function ProfessionsReagentSlotMixin:SetCheckmarkAtlas(atlas)
	self.Checkmark.Check:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

function ProfessionsReagentSlotMixin:SetCheckmarkTooltipText(text)
	SetElementTooltipText(text, self.Checkmark);
end

function ProfessionsReagentSlotMixin:SetColorOverlay(color, alpha)
	self.Button.ColorOverlay:SetShown(color ~= nil);
	if color then
		local r, g, b = color:GetRGB();
		self.Button.ColorOverlay:SetColorTexture(r, g, b, alpha or 0.5);
	end
end

function ProfessionsReagentSlotMixin:SetAddIconDesaturated(desaturated)
	self.Button.InputOverlay.AddIcon:SetDesaturated(desaturated);
end
