ProfessionsReagentSlotMixin = {};

function ProfessionsReagentSlotMixin:Reset()
	self.Button.QualityOverlay:SetAtlas(nil);
	self:SetAllocateIconShown(false);
	self.unallocatable = nil;
	self.originalItem = nil;
	self.CustomerState:Hide();
	self.Button:Reset();
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end
	self.continuableContainer = ContinuableContainer:Create();
	self:SetCheckboxShown(false);
	self:SetCheckboxCallback(nilCallback);
	self:SetCheckboxTooltipText(nilTooltipText);
	self:SetHighlightShown(false);
	local skipUpdate = true;
	self:SetOverrideNameColor(nilOverrideColor, skipUpdate)
	self:SetShowOnlyRequired(false, skipUpdate);
	self:SetCheckmarkShown(false);
	self:SetCheckmarkTooltipText(nilTooltipText);
	self:SetOverrideQuantity(nilOverrideQuantity, skipUpdate)
	self:SetColorOverlay(nilOverlayColor);
	self:SetAddIconDesaturated(false);
end

function ProfessionsReagentSlotMixin:SetSlotBehaviorModifyingRequired(isModifyingRequired)
	if isModifyingRequired then
		local scale = .65;
		self.Button:SetNormalAtlas("itemupgrade_greenplusicon", false);
		self.Button:GetNormalTexture():SetScale(scale);

		self.Button:SetPushedAtlas("itemupgrade_greenplusicon_pressed", false);
		self.Button:GetPushedTexture():SetScale(scale);

		self.Button:ClearHighlightTexture();

		self.Button:SetCropOverlayShown(true);
	else	
		local scale = 1;
		self.Button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		self.Button:GetNormalTexture():SetScale(scale);

		self.Button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
		self.Button:GetPushedTexture():SetScale(scale);
		
		self.Button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
	end
end

function ProfessionsReagentSlotMixin:Init(transaction, reagentSlotSchematic)
	local isModifyingRequired = ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic);
	self.Button:SetModifyingRequired(isModifyingRequired);
	self.Button:SetCropOverlayShown(isModifyingRequired);

	self:SetTransaction(transaction);
	self:SetReagentSlotSchematic(reagentSlotSchematic);

	for index, reagent in ipairs(reagentSlotSchematic.reagents) do
		if reagent.itemID then
			local item = Item:CreateFromItemID(reagent.itemID);
			self.continuableContainer:AddContinuable(item);
		end
	end
	
	self:SetSlotBehaviorModifyingRequired(isModifyingRequired);

	local function OnItemsLoaded()
		self.Name:Show();
		
		local function InitButton()
			local allocations = transaction:GetAllocations(self:GetSlotIndex());
			for index, allocation in allocations:Enumerate() do
				local reagent = allocation:GetReagent();
				self:SetItem(Item:CreateFromItemID(reagent.itemID));
				return;
			end

			self:SetItem(nil);
		end
		
		local modification = transaction:GetOriginalModification(reagentSlotSchematic.dataSlotIndex);
		if modification and modification.itemID > 0 then
			self:SetOriginalItem(Item:CreateFromItemID(modification.itemID));
		end

		local reagentType = reagentSlotSchematic.reagentType;
		if reagentType == Enum.CraftingReagentType.Basic then
			if Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
				self.Button.noProfessionQualityOverlay = true;
			end

			local reagent = reagentSlotSchematic.reagents[1];
			if reagent.currencyID then
				self.Button:SetCurrency(reagent.currencyID);
			else
				self.Button:SetItem(reagent.itemID);
			end
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

	if not ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic) then
		return;
	end

	-- The allocation text will not be applied to this slot if it is a modifying-required reagent meeting certain conditions. See ApplySlotInfo() for the
	-- fallback text behavior.
	local foundMultiple, foundIndex = false, nil;
	if ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
		if self:GetTransaction():IsModificationUnchangedAtSlotIndex(self:GetSlotIndex()) then
			-- The current allocation is the currently installed modification, the currently allocated reagent name will be displayed.
			return;
		end

		for allocationIndex, allocation in self:GetTransaction():EnumerateAllocations(reagentSlotSchematic.slotIndex) do
			-- Only one allocation is expected, and is an error otherwise
			assert(foundIndex == nil, "Cannot have multiple allocations within a modifying-required slot.");
			foundIndex = FindInTableIf(reagentSlotSchematic.reagents, function(reagent)
				return Professions.CraftingReagentMatches(reagent, allocation.reagent);
			end);
		end
		
		if foundIndex == nil then
			-- There is no allocation, the slot name will be displayed.
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
				quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent);
			else
				quantity = ProfessionsUtil.AccumulateReagentsInPossession(reagentSlotSchematic.reagents);
			end
		end
	end

	local quantityText = self.showOnlyRequired and reagentSlotSchematic.quantityRequired or TRADESKILL_REAGENT_COUNT:format(quantity, reagentSlotSchematic.quantityRequired);
	-- If this is a modifying-required reagent and an allocation was found, this will select the correct reagent whereas
	-- other basic slots with reagents sharing the same name would have all been selected correctly using the first index,
	-- because the names all were identical.
	local reagent = reagentSlotSchematic.reagents[foundIndex or 1];
	local reagentName;
	if reagent.currencyID then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
		reagentName = currencyInfo and currencyInfo.name or UNKNOWN;
	else
		local item = Item:CreateFromItemID(reagent.itemID);
		reagentName = item:GetItemName() or UNKNOWN;
	end
	
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
	for index, reagent in ipairs(reagentSlotSchematic.reagents) do
		local quantity = ProfessionsUtil.GetReagentQuantityInPossession(reagent);
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
	if reagentSlotSchematic and Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
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
	else
		self.Button.QualityOverlay:SetAtlas(nil);
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

function ProfessionsReagentSlotMixin:IsOriginalItemSet()
	return not self.originalItem or Item:DoItemsMatch(self.originalItem, self.item);
end

function ProfessionsReagentSlotMixin:SetOriginalItem(item)
	self.originalItem = item;
end

function ProfessionsReagentSlotMixin:GetOriginalItem(item)
	return self.originalItem;
end

function ProfessionsReagentSlotMixin:ApplySlotInfo()
	local reagentSlotSchematic = self:GetReagentSlotSchematic();
	local slotInfo = reagentSlotSchematic.slotInfo;
	local slotText = slotInfo and slotInfo.slotText or OPTIONAL_REAGENT_POSTFIX;

	local isModifyingRequired = ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic);
	if isModifyingRequired and not self:GetTransaction():IsModificationUnchangedAtSlotIndex(self:GetSlotIndex()) then
		local quantityText = self.showOnlyRequired and reagentSlotSchematic.quantityRequired or TRADESKILL_REAGENT_COUNT:format(0, reagentSlotSchematic.quantityRequired);
		self:SetNameText(("%s %s"):format(quantityText, slotText));
	else
		self:SetNameText(slotText);
	end
end

function ProfessionsReagentSlotMixin:SetItem(item)
	ItemButtonMixin.Reset(self.Button);
	self.item = item;
	self.currencyID = nil;

	if item then
		self:SetSlotBehaviorModifyingRequired(false);

		self.Button:SetItem(item:GetItemID());
		self.Button.InputOverlay.AddIcon:Hide();
		self:SetNameText(item:GetItemName());
	else
		if self.Button:IsModifyingRequired() then
			self:SetSlotBehaviorModifyingRequired(true);
		end

		self:ApplySlotInfo();
	end

	self:Update();
end

function ProfessionsReagentSlotMixin:SetCurrency(currencyID)
	ItemButtonMixin.Reset(self.Button);
	self.item = nil;
	self.currencyID = currencyID;

	if currencyID then
		self.Button:SetCurrency(currencyID);
		self.Button.InputOverlay.AddIcon:Hide();
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
		self:SetNameText(currencyInfo and currencyInfo.name or UNKNOWN);
	else
		self:ApplySlotInfo();
	end

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

function ProfessionsReagentSlotMixin:SetAllocateIconShown(shown)
	self.Button.AddIcon:SetShown(shown);
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