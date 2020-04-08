
RuneforgeDropDownButtonMixin = CreateFromMixins(UIDropDownCustomMenuEntryMixin);

function RuneforgeDropDownButtonMixin:Set(runeforgeDropDownMenu, tierIndex, leftText, rightText, selected)
	self.runeforgeDropDownMenu = runeforgeDropDownMenu;
	self.tierIndex = tierIndex;

	self.LeftText:SetText(leftText);
	self.RightText:SetText(rightText);
	self.Check:SetShown(selected);
end

function RuneforgeDropDownButtonMixin:SetSelected(selected)
	self.Check:SetShown(selected);
end

function RuneforgeDropDownButtonMixin:GetTierIndex()
	return self.tierIndex;
end

function RuneforgeDropDownButtonMixin:OnMouseDown()
	local point, relative, relativePoint, x, y = self.LeftText:GetPoint();
	self.originalLeftPoint = { point, relative, relativePoint, x, y };
	self.LeftText:SetPoint(point, relative, relativePoint, x + 1, y - 1);

	local point, relative, relativePoint, x, y = self.RightText:GetPoint();
	self.originalRightPoint = { point, relative, relativePoint, x, y };
	self.RightText:SetPoint(point, relative, relativePoint, x + 1, y - 1);
end

function RuneforgeDropDownButtonMixin:OnMouseUp()
	self.LeftText:SetPoint(unpack(self.originalLeftPoint));
	self.RightText:SetPoint(unpack(self.originalRightPoint));
end

function RuneforgeDropDownButtonMixin:OnHide()
	if self.runeforgeDropDownMenu then
		self.runeforgeDropDownMenu:ReleaseDropDownButton(self);
	end
end


RuneforgeItemLevelSelectorMixin = CreateFromMixins(RuneforgeSystemMixin);

function RuneforgeItemLevelSelectorMixin:Reset()
	return self.DropDownMenu:Reset();
end

function RuneforgeItemLevelSelectorMixin:GetItemLevelTier()
	return self.DropDownMenu:GetItemLevelTier();
end

function RuneforgeItemLevelSelectorMixin:GetItemLevelTierIndex()
	return self.DropDownMenu:GetItemLevelTierIndex();
end

function RuneforgeItemLevelSelectorMixin:GetItemLevelTiers()
	return self:GetRuneforgeFrame():GetItemLevelTiers();
end


RuneforgeItemLevelSelectorDropDownMenuMixin = {};

function RuneforgeItemLevelSelectorDropDownMenuMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, 120, 10);
	UIDropDownMenu_JustifyText(self, "LEFT", 10);

	self.dropDownButtonPool = CreateFramePool("BUTTON", self, "RuneforgeDropDownButtonTemplate");
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:OnShow()
	UIDropDownMenu_Initialize(self, RuneforgeItemLevelSelectorDropDownMenuMixin.Initialize);
	self:SetItemLevelTierIndex(nil);

	self:GetParent():GetRuneforgeFrame():RegisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self.OnBaseItemChanged, self);
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:OnHide()
	UIDropDownMenu_Initialize(self, RuneforgeItemLevelSelectorDropDownMenuMixin.Initialize);
	self:SetItemLevelTierIndex(nil);

	self:GetParent():GetRuneforgeFrame():UnregisterCallback(RuneforgeFrameMixin.Event.BaseItemChanged, self);
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:OnBaseItemChanged()
	self:SetItemLevelTierIndex(nil);
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:Initialize()
	self.dropDownButtonPool:ReleaseAll();

	self.itemLevelTiers = self:GetParent():GetItemLevelTiers();
	if not self.itemLevelTiers then
		self:SetItemLevelTierIndex(nil);
		return;
	end

	for i, itemLevelTier in ipairs(self.itemLevelTiers) do
		local dropDownButton = self.dropDownButtonPool:Acquire();
		dropDownButton:Set(self, i, itemLevelTier.itemLevel, RuneforgeUtil.GetCostsString(itemLevelTier.costs));
		dropDownButton:SetScript("OnClick", GenerateClosure(self.SetItemLevelTierIndex, self, i));

		local selected = self.itemLevelTierIndex == i;
		dropDownButton:SetSelected(selected);

		local info = UIDropDownMenu_CreateInfo();
		info.customFrame = dropDownButton;
		UIDropDownMenu_AddButton(info);
	end
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:ReleaseDropDownButton(button)
	self.dropDownButtonPool:Release(button);
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:SetItemLevelTierIndex(tierIndex)
	self.itemLevelTierIndex = tierIndex;

	if tierIndex == nil then
		UIDropDownMenu_SetText(self, RUNEFORGE_LEGENDARY_ITEM_LEVEL_SELECTOR_NONE);
	else
		UIDropDownMenu_SetText(self, self:GetItemLevelTier().itemLevel);
	end

	self:SetEnabled(self:GetParent():GetItemLevelTiers() ~= nil);

	CloseDropDownMenus();

	self:GetParent():GetRuneforgeFrame():TriggerEvent(RuneforgeFrameMixin.Event.ItemLevelTierChanged);
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:UpdateDropDownSelection()
	for dropDownButton in self.dropDownButtonPool:EnumerateActive() do
		dropDownButton:SetSelected(dropDownButton:GetTierIndex() == self.itemLevelTierIndex);
	end
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:GetItemLevelTierIndex()
	return self.itemLevelTierIndex;
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:GetItemLevelTier()
	return self.itemLevelTierIndex and self.itemLevelTiers[self.itemLevelTierIndex] or nil;
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:SetEnabled(enabled)
	if enabled then
		UIDropDownMenu_EnableDropDown(self);
	else
		UIDropDownMenu_DisableDropDown(self);
	end
end

function RuneforgeItemLevelSelectorDropDownMenuMixin:Reset()
	self:SetItemLevelTierIndex(nil);
end
