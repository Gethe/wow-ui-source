
RuneforgeModifierSlotMixin = {};

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
end

function RuneforgeModifierSlotMixin:OnEnter()
	local itemID = self:GetItemID();
	if itemID then
		GameTooltip:SetOwner(self);
		self:GetModifierFrame():SetModifierTooltip(GameTooltip, self:GetID(), itemID);
		GameTooltip:Show();
	end
end

function RuneforgeModifierSlotMixin:OnLeave()
	GameTooltip_Hide();
end

function RuneforgeModifierSlotMixin:OnClick(buttonName)
	local modifierFrame = self:GetModifierFrame();
	if buttonName == "RightButton" then
		modifierFrame:SetModifierSlot(self:GetID(), nil);
		modifierFrame:CloseSelector();
		GameTooltip:Hide();
	else
		modifierFrame:OnSlotSelected(self);
	end
end

function RuneforgeModifierSlotMixin:OnEnable()
	local alpha = (self:GetItem() == nil) and 1 or 0;
	self:GetNormalTexture():SetAlpha(alpha);
	self:GetPushedTexture():SetAlpha(alpha);
end

function RuneforgeModifierSlotMixin:OnDisable()
	self:GetNormalTexture():SetAlpha(0);
	self:GetPushedTexture():SetAlpha(0);
end

function RuneforgeModifierSlotMixin:SetItem(item)
	local hasItem = item ~= nil;
	self.SelectedTexture:SetShown(hasItem);

	local alpha = (self:IsEnabled() and not hasItem) and 1 or 0;
	self:GetNormalTexture():SetAlpha(alpha);
	self:GetPushedTexture():SetAlpha(alpha);

	ItemButtonMixin.SetItem(self, item);
end

function RuneforgeModifierSlotMixin:SetArrowShown(shown)
	self.Arrow:SetShown(shown);
end

function RuneforgeModifierSlotMixin:GetModifierFrame()
	return self:GetParent();
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
		self.icon:SetDesaturation(false);
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

	count = count or ItemUtil.GetOptionalReagentCount(self:GetItemID());
	if count <= 0 then
		return RuneforgeModifierSelectionState.Unavailable;
	end

	return RuneforgeModifierSelectionState.Available;
end

function RuneforgeModifierSelectionMixin:RefreshState(count)
	self:SetState(self:GetState(count));
end

function RuneforgeModifierSelectionMixin:SetModifierItem(itemID, count, selectedInThisSlot, selectedInOtherSlot)
	count = count or ItemUtil.GetOptionalReagentCount(itemID);

	self.selectedInThisSlot = selectedInThisSlot;
	self.selectedInOtherSlot = selectedInOtherSlot;
	self:SetItem(itemID);
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

	local modifierItemIDs = self:GetParent():GetRuneforgeFrame():GetModifierSelections();

	local reagentCounts = {};
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
		selection:SetModifierItem(itemID, reagentCounts[itemID], selectedInThisSlot, selectedInOtherSlot);
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
	self:UnregisterRefreshMethod(self.Refresh);
end

function RuneforgeModifierFrameMixin:Refresh(eventName)
	if eventName == "BaseItemChanged" then
		self:Reset();
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
	modifiers[self.FirstSlot:GetID()] = self.FirstSlot:GetItemID();
	modifiers[self.SecondSlot:GetID()] = self.SecondSlot:GetItemID();
	return modifiers;
end

function RuneforgeModifierFrameMixin:OnSlotSelected(slot)
	if self.Selector:GetSelectedButton() == slot then
		self.Selector:Close();
	else
		self.Selector:Open(slot);
		self.Selector:Show();
	end
end

function RuneforgeModifierFrameMixin:UpdateEnabledState()
	local enabled = self:GetRuneforgeFrame():GetPowerID() ~= nil;
	self.FirstSlot:SetEnabled(enabled);

	local secondSlotEnabled = (self.SecondSlot:GetItem() ~= nil) or (self.FirstSlot:GetItem() ~= nil);
	self.SecondSlot:SetEnabled(enabled and secondSlotEnabled);
end

function RuneforgeModifierFrameMixin:SetModifierSlot(slot, itemID)
	local isFirstSlot = slot == 1;
	local selectedButton = isFirstSlot and self.FirstSlot or self.SecondSlot;
	local otherButton = isFirstSlot and self.SecondSlot or self.FirstSlot;

	if otherButton:GetItemID() == itemID then
		otherButton:SetItem(nil);
	end

	selectedButton:SetItem(itemID);

	self:GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.ModifiersChanged);
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
	GameTooltip_AddNormalLine(tooltip, description, wrap);
end
