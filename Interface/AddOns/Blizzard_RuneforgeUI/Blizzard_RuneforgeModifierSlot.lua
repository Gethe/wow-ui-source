
RuneforgeModifierSlotMixin = CreateFromMixins(RuneforgeEffectOwnerMixin);

function RuneforgeModifierSlotMixin:OnLoad()
	local normalTexture = self:GetNormalTexture();
	normalTexture:ClearAllPoints();
	normalTexture:SetPoint("CENTER"); -- Remove the standard -1 offset.
	normalTexture:SetAtlas("runecarving-icon-reagent-empty", true);
	normalTexture:SetAlpha(0);

	local pushedTexture = self:GetPushedTexture();
	pushedTexture:ClearAllPoints();
	pushedTexture:SetPoint("CENTER");
	pushedTexture:SetAtlas("runecarving-icon-reagent-pressed", true);
	pushedTexture:SetAlpha(0);

	self.IconBorder:SetAlpha(0);

	self:AddEffectData("primary", RuneforgeUtil.Effect.ModifierSlotted, RuneforgeUtil.EffectTarget.None);

	local effectID = (self:GetID() == 1) and RuneforgeUtil.Effect.FirstModifierChainsEffect or RuneforgeUtil.Effect.SecondModifierChainsEffect;
	self:AddEffectData("chains", effectID, RuneforgeUtil.EffectTarget.ItemSlot);
end

function RuneforgeModifierSlotMixin:OnEnter()
	local itemID = self:GetItemID();
	if itemID then
		GameTooltip:SetOwner(self);
		self:GetModifierFrame():SetModifierTooltip(GameTooltip, self:GetID(), itemID);
		GameTooltip:Show();
	elseif self:HasError() then
		local errorText, errorDescription = self:GetError();
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, errorText, RED_FONT_COLOR);
		if errorDescription ~= nil then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddNormalLine(GameTooltip, errorDescription);
		end

		GameTooltip:Show();
	end
end

function RuneforgeModifierSlotMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgeModifierSlotMixin:OnClick(buttonName)
	if self:GetRuneforgeFrame():IsRuneforgeUpgrading() then
		return;
	end
	
	local modifierFrame = self:GetModifierFrame();
	if buttonName == "RightButton" then
		modifierFrame:SetModifierSlot(self:GetID(), nil);
		modifierFrame:CloseSelector();
		GameTooltip:Hide();
	elseif self:IsSelectable() then
		modifierFrame:OnSlotSelected(self);
	end
end

function RuneforgeModifierSlotMixin:SetSelectable(selectable, errorText, errorDescription)
	self.selectable = selectable;
	self.errorText = errorText;
	self.errorDescription = errorDescription;

	self:UpdateButtonState();
end

function RuneforgeModifierSlotMixin:IsSelectable()
	return self.selectable and not self:HasError();
end

function RuneforgeModifierSlotMixin:GetError()
	return self.errorText, self.errorDescription;
end

function RuneforgeModifierSlotMixin:HasError()
	return self:GetError() ~= nil;
end

function RuneforgeModifierSlotMixin:SetItem(item)
	local hasItem = item ~= nil;
	self.SelectedTexture:SetShown(hasItem);

	local isUpgrading = self:GetModifierFrame():IsRuneforgeUpgrading();
	local slotAlpha = isUpgrading and 0.35 or 1.0;
	self.SelectedTexture:SetAlpha(slotAlpha);
	self:SetAlpha(slotAlpha);

	local showEffects = hasItem and not isUpgrading;
	self:SetEffectShown("primary", showEffects);
	self:SetEffectShown("chains", showEffects);

	ItemButtonMixin.SetItem(self, item);

	self:UpdateButtonState();
end

function RuneforgeModifierSlotMixin:UpdateButtonState()
	local isSelectable = self:IsSelectable();
	self:GetHighlightTexture():SetAlpha(isSelectable and 1 or 0);

	local hasItem = self:GetItem() ~= nil;
	local isUpgrading = self:GetModifierFrame():IsRuneforgeUpgrading();
	local buttonAlpha = (isSelectable and not hasItem and not isUpgrading) and 1 or 0;
	self:GetNormalTexture():SetAlpha(buttonAlpha);
	self:GetPushedTexture():SetAlpha(buttonAlpha);

	self.ErrorTexture:SetShown(self:HasError());
end

function RuneforgeModifierSlotMixin:SetArrowShown(shown)
	self.Arrow:SetShown(shown);
end

function RuneforgeModifierSlotMixin:GetModifierFrame()
	return self:GetParent();
end

function RuneforgeModifierSlotMixin:GetRuneforgeFrame()
	return self:GetParent():GetRuneforgeFrame();
end


RuneforgeModifierSelectionMixin = {};

local RuneforgeModifierSelectionState = {
	Available = 1,
	Unavailable = 2,
	SelectedInOtherSlot = 3,
	SelectedInThisSlot = 4,
};

function RuneforgeModifierSelectionMixin:SetState(state)
	if state == RuneforgeModifierSelectionState.Available then
		self.StateTexture:SetAtlas("runecarving-icon-reagent-border", true);
		self:SetAlpha(1.0);
		self.icon:SetDesaturated(false);
		self:SetEnabled(true);
	elseif state == RuneforgeModifierSelectionState.SelectedInThisSlot then
		self.StateTexture:SetAtlas("runecarving-menu-reagent-selected", true);
		self:SetAlpha(1.0);
		self.icon:SetDesaturated(false);
		self:SetEnabled(true);
	elseif state == RuneforgeModifierSelectionState.SelectedInOtherSlot then
		self.StateTexture:SetAtlas("runecarving-icon-reagent-selectedother", true);
		self:SetAlpha(0.3);
		self.icon:SetDesaturation(0.5);
		self:SetEnabled(false);
	elseif state == RuneforgeModifierSelectionState.Unavailable then
		self.StateTexture:SetAtlas("runecarving-icon-reagent-border", true);
		self:SetAlpha(0.5);
		self.icon:SetDesaturation(1.0);
		self:SetEnabled(false);
	end
end

function RuneforgeModifierSelectionMixin:GetState(count)
	if self.selectedInThisSlot then
		return RuneforgeModifierSelectionState.SelectedInThisSlot;
	end

	if self.selectedInOtherSlot then
		return RuneforgeModifierSelectionState.SelectedInOtherSlot;
	end

	count = count or ItemUtil.GetCraftingReagentCount(self:GetItemID());
	if count <= 0 then
		return RuneforgeModifierSelectionState.Unavailable;
	end

	return RuneforgeModifierSelectionState.Available;
end

function RuneforgeModifierSelectionMixin:RefreshState(count)
	self:SetState(self:GetState(count));
end

function RuneforgeModifierSelectionMixin:SetModifierItem(itemID, selectedInThisSlot, selectedInOtherSlot)
	self.selectedInThisSlot = selectedInThisSlot;
	self.selectedInOtherSlot = selectedInOtherSlot;
	self:SetItem(itemID);

	local count = ItemUtil.GetCraftingReagentCount(itemID);
	self:RefreshState(count);
end

function RuneforgeModifierSelectionMixin:OnLoad()
	self:GetNormalTexture():SetAlpha(0);
	self.IconBorder:SetAlpha(0);
end

function RuneforgeModifierSelectionMixin:OnEnter()
	local itemID = self:GetItemID();
	if itemID then
		GameTooltip:SetOwner(self);
		self:GetModifierFrame():SetModifierTooltip(GameTooltip, self:GetParent():GetSelectedSlot(), self:GetItemID());

		local wrap = true;
		local state = self:GetState();
		if state == RuneforgeModifierSelectionState.Unavailable then
			GameTooltip_AddErrorLine(GameTooltip, RUNEFORGE_LEGENDARY_MODIFIER_UNAVAIBLE_TOOLTIP, wrap);
		elseif state == RuneforgeModifierSelectionState.Selected then
			GameTooltip_AddErrorLine(GameTooltip, RUNEFORGE_LEGENDARY_MODIFIER_SELECTED_TOOLTIP, wrap);
		end

		GameTooltip:Show();
	end
end

function RuneforgeModifierSelectionMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgeModifierSelectionMixin:OnClick()
	self:GetParent():SetModifierItemID(self:GetItemID());
end

function RuneforgeModifierSelectionMixin:GetModifierFrame()
	return self:GetParent():GetModifierFrame();
end


RuneforgeModifierSelectorFrameMixin = {};

function RuneforgeModifierSelectorFrameMixin:OnLoad()
	self.selectionPool = CreateFramePool("ItemButton", self, "RuneforgeModifierSelectionTemplate");
end

function RuneforgeModifierSelectorFrameMixin:GenerateSelections(slotID)
	self.selectionPool:ReleaseAll();

	local modifierItemIDs = C_LegendaryCrafting.GetRuneforgeModifiers();

	local selectedMap = tInvert(self:GetParent():GetModifiers());

	local previousSelection = nil;
	for i, itemID in ipairs(modifierItemIDs) do
		local selection = self.selectionPool:Acquire();
		if not previousSelection then
			selection:SetPoint("TOPLEFT", 20, -30);
		else
			selection:SetPoint("TOPLEFT", previousSelection, "BOTTOMLEFT", 0, -11);
		end

		local selectedSlot = selectedMap[itemID];
		local selectedInThisSlot = slotID == selectedSlot;
		local selectedInOtherSlot = not selectedInThisSlot and (selectedSlot ~= nil);
		selection:SetModifierItem(itemID, selectedInThisSlot, selectedInOtherSlot);
		selection:Show();

		previousSelection = selection;
	end
end

function RuneforgeModifierSelectorFrameMixin:Open(button)
	if self.selectedButton then
		self.selectedButton:SetArrowShown(false);
	end

	button:SetArrowShown(true);

	self:ClearAllPoints();
	self:SetPoint("LEFT", button, "RIGHT", 10, 0);
	self.selectedButton = button;
	self:GenerateSelections(button:GetID());
end

function RuneforgeModifierSelectorFrameMixin:Close()
	if self.selectedButton then
		self.selectedButton:SetArrowShown(false);
		self.selectedButton = nil;
	end
	
	self.selectionPool:ReleaseAll();
	self:Hide();
end

function RuneforgeModifierSelectorFrameMixin:GetSelectedButton()
	return self.selectedButton;
end

function RuneforgeModifierSelectorFrameMixin:GetSelectedSlot()
	return self:GetSelectedButton():GetID();
end

function RuneforgeModifierSelectorFrameMixin:SetModifierItemID(itemID)
	self:GetModifierFrame():SetModifierSlot(self.selectedButton:GetID(), itemID);
	self:Close();
end

function RuneforgeModifierSelectorFrameMixin:GetModifierFrame()
	return self:GetParent();
end


RuneforgeModifierFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgeModifierFrameMixin:OnShow()
	self:RegisterRefreshMethod(self.Refresh);
	self:UpdateEnabledState();
end

function RuneforgeModifierFrameMixin:OnHide()
	self:UnregisterRefreshMethod();
end

function RuneforgeModifierFrameMixin:Refresh(eventName)
	if eventName == "BaseItemChanged" then
		if self:IsRuneforgeCrafting() then
			self:Reset();
		elseif self:IsRuneforgeUpgrading() then
			local runeforgeFrame = self:GetRuneforgeFrame();
			local item = runeforgeFrame:GetItem();
			if item == nil then
				self:Reset();
			else
				local info = runeforgeFrame:GetRuneforgeComponentInfo();
				self.FirstSlot:SetItem(info.modifiers[1]);
				self.SecondSlot:SetItem(info.modifiers[2]);
			end
		end
	else
		self:UpdateEnabledState();
	end
end

function RuneforgeModifierFrameMixin:Reset()
	self:CloseSelector();
	self.FirstSlot:SetItem(nil);
	self.SecondSlot:SetItem(nil);
	self:UpdateEnabledState();
end

function RuneforgeModifierFrameMixin:CloseSelector()
	self.Selector:Close();
end

function RuneforgeModifierFrameMixin:GetModifiers()
	local modifiers = {};

	local firstItemID = self.FirstSlot:GetItemID();
	if firstItemID then
		table.insert(modifiers, firstItemID);
	end

	local secondItemID = self.SecondSlot:GetItemID();
	if secondItemID then
		table.insert(modifiers, secondItemID);
	end

	return modifiers;
end

function RuneforgeModifierFrameMixin:OnSlotSelected(slot)
	if self.Selector:GetSelectedButton() == slot then
		self.Selector:Close();
	else
		self.Selector:Open(slot);
		self.Selector:Show();
		PlaySound(SOUNDKIT.UI_RUNECARVING_OPEN_SELECTION_SUB_WINDOW);
	end
end

function RuneforgeModifierFrameMixin:UpdateEnabledState()
	local isUpgrading = self:IsRuneforgeUpgrading();
	local previousItemsValid = (self:GetRuneforgeFrame():GetItem() ~= nil) and (self:GetRuneforgeFrame():GetPowerID() ~= nil);
	local numModifierTypes = self:GetRuneforgeFrame():GetNumAvailableModifierTypes();
	local errorText = RUNEFORGE_LEGENDARY_ERROR_INSUFFICIENT_MODIFIERS;
	local errorDescription = RUNEFORGE_LEGENDARY_ERROR_INSUFFICIENT_MODIFIERS_DESCRIPTION;

	local firstSlotHasError = not isUpgrading and (numModifierTypes < 1);
	self.FirstSlot:SetSelectable(not isUpgrading and previousItemsValid, firstSlotHasError and errorText or nil, firstSlotHasError and errorDescription or nil);

	local secondSlotEnabled = (self.SecondSlot:GetItem() ~= nil) or (self.FirstSlot:GetItem() ~= nil);
	local secondSlotHasError = not isUpgrading and (numModifierTypes < 2);
	self.SecondSlot:SetSelectable(not isUpgrading and previousItemsValid and secondSlotEnabled, secondSlotHasError and errorText or nil, secondSlotHasError and errorDescription or nil);
end

function RuneforgeModifierFrameMixin:SetModifierSlot(slot, itemID)
	local isFirstSlot = slot == 1;
	local selectedButton = isFirstSlot and self.FirstSlot or self.SecondSlot;
	local otherButton = isFirstSlot and self.SecondSlot or self.FirstSlot;

	if otherButton:GetItemID() == itemID then
		otherButton:SetItem(nil);
	end

	local oldItemID = selectedButton:GetItemID();
	selectedButton:SetItem(itemID);

	local runeforgeFrame = self:GetRuneforgeFrame();
	runeforgeFrame:TriggerEvent(RuneforgeFrameMixin.Event.ModifiersChanged);

	if itemID ~= nil then
		if oldItemID == nil then
			runeforgeFrame:FlashRunes();
		end

		if not runeforgeFrame:IsRuneforgeUpgrading() then
			if isFirstSlot then
				PlaySound(SOUNDKIT.UI_RUNECARVING_SELECT_UPPER_RUNE);
			else
				PlaySound(SOUNDKIT.UI_RUNECARVING_SELECT_LOWER_RUNE);
			end
		end
	end
end

function RuneforgeModifierFrameMixin:SetModifierTooltip(tooltip, slot, itemID)
	local modifiers = { itemID };
	local isFirstSlot = slot == 1;
	local otherButton = isFirstSlot and self.SecondSlot or self.FirstSlot;
	local otherItemID = otherButton:GetItemID();
	if otherItemID then
		table.insert(modifiers, otherItemID);
	end

	local baseItem, powerID = self:GetRuneforgeFrame():GetLegendaryCraftInfo();
	local addedModifierIndex = 1;
	local name, description = C_LegendaryCrafting.GetRuneforgeModifierInfo(baseItem, powerID, addedModifierIndex, modifiers);

	local wrap = true;
	GameTooltip_SetTitle(tooltip, name, HIGHLIGHT_FONT_COLOR, wrap);

	for _, str in ipairs(description) do
		GameTooltip_AddNormalLine(tooltip, str, wrap);
	end
end
