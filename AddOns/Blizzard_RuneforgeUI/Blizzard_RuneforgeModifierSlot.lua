
RuneforgeModifierSlotMixin = {};

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
	if buttonName == "RightButton" then
		self:GetParent():SetModifierSlot(self:GetID(), nil);
	else
		self:GetParent():OnSlotSelected(self);
	end
end

function RuneforgeModifierSlotMixin:GetModifierFrame()
	return self:GetParent();
end


RuneforgeModifierSelectionMixin = {};

local RuneforgeModifierSelectionState = {
	Available = 1,
	Unavailable = 2,
	Selected = 3,
};

function RuneforgeModifierSelectionMixin:SetState(state)
	if state == RuneforgeModifierSelectionState.Available then
		self:SetAlpha(1.0);
		self:SetEnabled(true);
	elseif state == RuneforgeModifierSelectionState.Selected then
		self:SetAlpha(0.5);
		self:SetEnabled(false);
	elseif state == RuneforgeModifierSelectionState.Unavailable then
		self:SetAlpha(0.2);
		self:SetEnabled(false);
	end
end

function RuneforgeModifierSelectionMixin:GetState(count)
	if self.selected then
		return RuneforgeModifierSelectionState.Selected;
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

function RuneforgeModifierSelectionMixin:SetModifierItem(itemID, count, selected)
	count = count or ItemUtil.GetOptionalReagentCount(itemID);

	self.selected = selected;
	self:SetItem(itemID);
	self:RefreshState(count);
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
	ResizeLayoutMixin.OnLoad(self);

	self.selectionPool = CreateFramePool("ItemButton", self, "RuneforgeModifierSelectionTemplate");
end

function RuneforgeModifierSelectorFrameMixin:GenerateSelections()
	self.selectionPool:ReleaseAll();

	local modifierItemIDs = self:GetParent():GetRuneforgeFrame():GetModifierSelections();

	local reagentCounts = {};
	local selectedMap = tInvert(self:GetParent():GetModifiers());

	local function ModifierSortFunction(lhsItemID, rhsItemID)
		reagentCounts[lhsItemID] = reagentCounts[lhsItemID] or ItemUtil.GetOptionalReagentCount(lhsItemID);
		reagentCounts[rhsItemID] = reagentCounts[rhsItemID] or ItemUtil.GetOptionalReagentCount(rhsItemID);
		local lhsAvailable = reagentCounts[lhsItemID] > 0;
		local rhsAvailable = reagentCounts[rhsItemID] > 0;
		if lhsAvailable ~= rhsAvailable then
			return lhsAvailable;
		end

		local lhsSelected = selectedMap[lhsItemID] ~= nil;
		local rhsSelected = selectedMap[rhsItemID] ~= nil;
		if lhsSelected ~= rhsSelected then
			return not lhsSelected;
		end

		return lhsItemID < rhsItemID;
	end
	
	table.sort(modifierItemIDs, ModifierSortFunction);

	local previousSelection = nil;
	for i, itemID in ipairs(modifierItemIDs) do
		local selection = self.selectionPool:Acquire();
		if not previousSelection then
			selection:SetPoint("TOPLEFT", 5, -5);
		else
			selection:SetPoint("TOPLEFT", previousSelection, "BOTTOMLEFT", 0, -5);
		end

		selection:SetModifierItem(itemID, reagentCounts[itemID], selectedMap[itemID] ~= nil);
		selection:Show();

		previousSelection = selection;
	end

	self:MarkDirty();
end

function RuneforgeModifierSelectorFrameMixin:Open(button)
	self:ClearAllPoints();
	self:SetPoint("RIGHT", button, "LEFT");
	self.selectedButton = button;
	self:GenerateSelections();
end

function RuneforgeModifierSelectorFrameMixin:Close()
	self.selectedButton = nil;
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
	self:GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);
	self:UpdateEnabledState();
end

function RuneforgeModifierFrameMixin:OnHide()
	self:GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end

function RuneforgeModifierFrameMixin:OnBaseItemChanged()
	self:Reset();
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
	table.insert(modifiers, self.FirstSlot:GetItemID());
	table.insert(modifiers, self.SecondSlot:GetItemID());
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
	local enabled = self:GetRuneforgeFrame():GetItem() ~= nil;
	self.FirstSlot:SetEnabled(enabled);
	self.SecondSlot:SetEnabled(enabled);
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

	local baseItem, powerID, _, itemLevelTierIndex = self:GetRuneforgeFrame():GetLegendaryCraftInfo();
	local addedModifierIndex = 1;
	local name, description = C_LegendaryCrafting.GetRuneforgeModifierInfo(baseItem, powerID, itemLevelTierIndex, addedModifierIndex, modifiers);

	local wrap = true;
	GameTooltip_SetTitle(tooltip, name, HIGHLIGHT_FONT_COLOR, wrap);
	GameTooltip_AddNormalLine(tooltip, description, wrap);
end
